"""NLU: turn a spoken description into structured attributes, then into a listing.

Providers:
  - RuleBasedNLU ("mock"): deterministic multilingual extractor + template listing writer. No keys needed,
    and it is also the fallback when a real provider fails.
  - ClaudeNLU ("claude"): Claude API with JSON-schema structured output.
"""
from __future__ import annotations

import json
import logging
import re
from dataclasses import dataclass, field

from . import lexicon as L

log = logging.getLogger(__name__)

_TOKEN_RE = re.compile(r"₹|\d[\d,]*(?:\.\d+)?|[A-Za-zऀ-෿᱐-᱿]+")
_INDIC_DIGITS = str.maketrans("०१२३४५६७८९০১২৩৪৫৬৭৮৯", "01234567890123456789")


def _has_latin(s: str) -> bool:
    return bool(re.search(r"[A-Za-z]", s))


def _find_all(text: str, table: dict) -> list[tuple[int, str]]:
    """Return (position, key) for every lexicon key found in text (earliest match per key)."""
    low = text.lower()
    hits = []
    for key, entry in table.items():
        best = None
        for form in entry["match"]:
            if _has_latin(form):
                m = re.search(r"(?<![A-Za-z])" + re.escape(form.lower()) + r"(?![A-Za-z])", low)
                pos = m.start() if m else -1
            else:
                # Indic scripts: must start a word; very short forms must also end one ("कप" not in "कपड़ा").
                right = r"(?![ऀ-෿])" if len(form) <= 3 else ""
                m = re.search(r"(?<![ऀ-෿])" + re.escape(form) + right, low)
                pos = m.start() if m else -1
            if pos >= 0 and (best is None or pos < best):
                best = pos
        if best is not None:
            hits.append((best, key))
    return sorted(hits)


def _tokens(text: str) -> list[str]:
    return _TOKEN_RE.findall(text.translate(_INDIC_DIGITS).lower())


def _unit_of(tok: str) -> str | None:
    for unit, forms in L.UNIT_WORDS.items():
        if tok in forms:
            return unit
    return None


def _parse_numbers(tokens: list[str]) -> list[tuple[int, int, float]]:
    """Find numbers (digits or spoken words). Returns (start_idx, end_idx_exclusive, value)."""
    out = []
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if re.fullmatch(r"\d[\d,]*(?:\.\d+)?", t):
            val = float(t.replace(",", ""))
            j = i + 1
            # "2 hazaar", "3 sau"
            if j < len(tokens) and L.NUMBER_WORDS.get(tokens[j]) in (100, 1000):
                val *= L.NUMBER_WORDS[tokens[j]]
                j += 1
            out.append((i, j, val))
            i = j
            continue
        if t in L.NUMBER_WORDS and t not in ("a", "an", "do"):  # "do" is also Hindi "give"; handled below
            total, current, j = 0.0, 0.0, i
            while j < len(tokens) and tokens[j] in L.NUMBER_WORDS:
                v = L.NUMBER_WORDS[tokens[j]]
                if v in (100, 1000):
                    current = (current or 1) * v
                    if v == 1000:
                        total, current = total + current, 0.0
                else:
                    current += v
                j += 1
            out.append((i, j, total + current))
            i = j
            continue
        if t == "do" and i + 1 < len(tokens) and _unit_of(tokens[i + 1]):
            out.append((i, i + 1, 2.0))
        i += 1
    return out


def _near(tokens: list[str], idx: int, cues: list[str], window: int = 6) -> bool:
    lo = max(0, idx - window)
    seg = " ".join(tokens[lo: idx + 3])
    return any(c in seg for c in cues)


@dataclass
class Extraction:
    product_type: str | None = None
    technique: list[str] = field(default_factory=list)
    materials: list[str] = field(default_factory=list)
    colors: list[str] = field(default_factory=list)
    dimensions_cm: dict = field(default_factory=dict)
    weight_g: float | None = None
    time_hours: float | None = None
    material_cost: float | None = None
    price_hint: float | None = None
    quantity: int | None = None
    region: dict = field(default_factory=dict)
    gi_craft: str | None = None
    category: str | None = None
    care_instructions: str | None = None
    confidence: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {k: v for k, v in self.__dict__.items()}


def extract(text: str) -> Extraction:
    ex = Extraction()
    if not text:
        return ex
    pt = [k for _, k in _find_all(text, L.PRODUCT_TYPES)]
    # "Kantha" names both the stitch and a quilt: a kantha *stole* or *saree* is that garment, not a quilt.
    if "quilt" in pt and len(pt) > 1:
        pt.remove("quilt")
    if pt:
        ex.product_type = pt[0]
    ex.technique = [k for _, k in _find_all(text, L.TECHNIQUES)]
    ex.materials = [k for _, k in _find_all(text, L.MATERIALS)]
    ex.colors = [k for _, k in _find_all(text, L.COLORS)]
    if "blue_pottery" in ex.technique and "blue" not in ex.colors:
        ex.colors.insert(0, "blue")
    if "blue_pottery" in ex.technique and "quartz" not in ex.materials:
        ex.materials.append("quartz")
    if "kantha" in ex.technique and ex.product_type == "quilt" and "quilt" not in text.lower():
        # "kantha" alone names the stitch, not necessarily a quilt
        pass

    tokens = _tokens(text)
    for start, end, val in _parse_numbers(tokens):
        unit = _unit_of(tokens[end]) if end < len(tokens) else None
        before = _unit_of(tokens[start - 1]) if start > 0 else None  # "₹ 300"
        if unit is None and before == "rupees":
            unit = "rupees"
        if unit in ("days", "hours", "weeks"):
            hours = val * {"days": 8, "hours": 1, "weeks": 48}[unit]
            ex.time_hours = (ex.time_hours or 0) + hours
        elif unit == "rupees" or (unit is None and _near(tokens, start, L.COST_CUES + L.PRICE_CUES, 4)):
            if _near(tokens, start, L.PRICE_CUES) and not _near(tokens, start, L.COST_CUES, 3):
                ex.price_hint = val
            else:
                ex.material_cost = (ex.material_cost or 0) + val
        elif unit in ("cm", "inch", "meters"):
            cm = val * {"cm": 1, "inch": 2.54, "meters": 100}[unit]
            key = "height"
            if _near(tokens, start, L.WIDTH_CUES, 4):
                key = "width"
            elif _near(tokens, start, L.LENGTH_CUES, 4) or unit == "meters":
                key = "length"
            ex.dimensions_cm[key] = round(cm, 1)
        elif unit in ("grams", "kg"):
            ex.weight_g = val * (1000 if unit == "kg" else 1)
        elif unit == "pieces" or _near(tokens, start, L.QTY_CUES, 3):
            ex.quantity = int(val)

    low = text.lower()
    for place, (city, state) in L.PLACES.items():
        if place in low:
            ex.region = {"city": city, "state": state}
            break
    for key in ex.technique:
        gi = L.TECHNIQUES[key].get("gi")
        if gi:
            ex.gi_craft = gi
            if not ex.region:
                ex.region = {"state": L.GI_CRAFTS.get(gi)}
            break

    ex.category = infer_category(ex)
    ex.care_instructions = L.CARE.get(ex.category, L.CARE["Other"])["en"]
    ex.confidence = {
        "product_type": 0.9 if ex.product_type else 0.0,
        "category": 0.9 if ex.product_type else (0.6 if ex.category != "Other" else 0.2),
        "materials": 0.8 if ex.materials else 0.0,
    }
    return ex


TECH_CATEGORY = {
    "dhokra": "Metalcraft", "handloom": "Textiles & Handloom", "block_print": "Textiles & Handloom",
    "ikat": "Textiles & Handloom", "bandhani": "Textiles & Handloom", "chikankari": "Textiles & Handloom",
    "kantha": "Textiles & Handloom", "embroidery": "Textiles & Handloom", "blue_pottery": "Pottery & Ceramics",
    "terracotta": "Pottery & Ceramics", "madhubani": "Paintings & Folk Art", "warli": "Paintings & Folk Art",
    "pattachitra": "Paintings & Folk Art", "channapatna": "Toys & Dolls",
    "gond": "Paintings & Folk Art", "kalamkari": "Paintings & Folk Art", "tanjore": "Paintings & Folk Art",
    "pichwai": "Paintings & Folk Art", "kalighat": "Paintings & Folk Art", "phulkari": "Textiles & Handloom",
    "banarasi": "Textiles & Handloom", "pashmina": "Textiles & Handloom", "kutch_embroidery": "Textiles & Handloom",
    "zardozi": "Textiles & Handloom", "bidri": "Metalcraft", "moradabad_brass": "Metalcraft", "meenakari": "Jewellery",
    "filigree": "Jewellery", "kondapalli": "Toys & Dolls", "saharanpur": "Woodcraft", "sandalwood": "Woodcraft",
    "longpi": "Pottery & Ceramics", "bankura": "Pottery & Ceramics", "sikki": "Bamboo & Cane",
    "assam_cane": "Bamboo & Cane", "kolhapuri": "Leather", "leather_puppet": "Leather",
    "mamallapuram": "Stone Craft", "marble_inlay": "Stone Craft", "kathputli": "Toys & Dolls",
    "papier_mache": "Home Décor", "navalgund": "Textiles & Handloom", "lac_craft": "Jewellery",
    "jute_craft": "Bamboo & Cane",
}
JEWELLERY_TECH = {"meenakari", "filigree", "lac_craft", "dhokra", "bidri"}
# Small items that can be made in any craft: a Warli coaster is folk art, a Bidri box is metalcraft.
FLEX_TYPES = {"coaster", "box", "bookmark", "keychain", "ornament", "magnet", "tray", "wall_hanging", "mask",
              "jewellery_box", "lamp", "figurine", "elephant", "horse"}


def infer_category(ex: Extraction) -> str:
    if ex.product_type in FLEX_TYPES:
        for t in ex.technique:
            if t in TECH_CATEGORY:
                return TECH_CATEGORY[t]
    if ex.product_type:
        cat = L.PRODUCT_TYPES[ex.product_type]["category"]
        # A horse or elephant in wood/clay is not metalcraft.
        if cat == "Metalcraft" and ex.materials and not {"brass", "bronze", "copper", "silver"} & set(ex.materials):
            if "wood" in ex.materials:
                return "Woodcraft"
            if "clay" in ex.materials or "terracotta" in ex.technique:
                return "Pottery & Ceramics"
            if "stone" in ex.materials or "marble" in ex.materials:
                return "Stone Craft"
        if "dhokra" in ex.technique:
            return "Metalcraft"
        if ex.product_type in ("toy", "doll") or "channapatna" in ex.technique:
            return "Toys & Dolls"
        return cat
    for t in ex.technique:
        if t in TECH_CATEGORY:
            return TECH_CATEGORY[t]
    mat_cat = {
        "cotton": "Textiles & Handloom", "silk": "Textiles & Handloom", "wool": "Textiles & Handloom",
        "clay": "Pottery & Ceramics", "brass": "Metalcraft", "bronze": "Metalcraft", "copper": "Metalcraft",
        "silver": "Jewellery", "beads": "Jewellery", "wood": "Woodcraft", "bamboo": "Bamboo & Cane",
        "cane": "Bamboo & Cane", "jute": "Bamboo & Cane", "leather": "Leather", "stone": "Stone Craft",
        "marble": "Stone Craft",
    }
    for m in ex.materials:
        if m in mat_cat:
            return mat_cat[m]
    return "Other"


# ---------------------------------------------------------------- follow-up questions

FOLLOW_UPS = {
    "product_type": {
        "en": "What is this item?", "hi": "यह कौन-सी चीज़ है?", "bn": "এটা কী জিনিস?", "mr": "ही कोणती वस्तू आहे?",
        "gu": "આ કઈ વસ્તુ છે?", "ta": "இது என்ன பொருள்?", "te": "ఇది ఏ వస్తువు?", "kn": "ಇದು ಯಾವ ವಸ್ತು?",
        "ml": "ഇത് എന്ത് വസ്തുവാണ്?", "or": "ଏହା କେଉଁ ଜିନିଷ?", "pa": "ਇਹ ਕਿਹੜੀ ਚੀਜ਼ ਹੈ?", "ur": "یہ کون سی چیز ہے؟",
        "as": "এইটো কি বস্তু?",
    },
    "materials": {
        "en": "What is it made of?", "hi": "यह किस चीज़ से बना है?", "bn": "এটা কী দিয়ে তৈরি?",
        "mr": "हे कशापासून बनवले आहे?", "gu": "આ શેમાંથી બનેલું છે?", "ta": "இது எதனால் செய்யப்பட்டது?",
        "te": "ఇది దేనితో తయారు చేశారు?", "kn": "ಇದನ್ನು ಯಾವುದರಿಂದ ಮಾಡಲಾಗಿದೆ?", "ml": "ഇത് എന്തുകൊണ്ടാണ് ഉണ്ടാക്കിയത്?",
        "or": "ଏହା କେଉଁଥିରେ ତିଆରି?", "pa": "ਇਹ ਕਿਸ ਚੀਜ਼ ਤੋਂ ਬਣਿਆ ਹੈ?", "ur": "یہ کس چیز سے بنا ہے؟",
        "as": "এইটো কিহেৰে তৈয়াৰী?",
    },
    "time_hours": {
        "en": "How many days did it take to make?", "hi": "इसे बनाने में कितने दिन लगे?",
        "bn": "এটা বানাতে কত দিন লেগেছে?", "mr": "हे बनवायला किती दिवस लागले?", "gu": "આ બનાવતાં કેટલા દિવસ લાગ્યા?",
        "ta": "இதைச் செய்ய எத்தனை நாட்கள் ஆனது?", "te": "దీన్ని తయారు చేయడానికి ఎన్ని రోజులు పట్టింది?",
        "kn": "ಇದನ್ನು ಮಾಡಲು ಎಷ್ಟು ದಿನ ಬೇಕಾಯಿತು?", "ml": "ഇത് ഉണ്ടാക്കാൻ എത്ര ദിവസം എടുത്തു?",
        "or": "ଏହା ତିଆରି କରିବାକୁ କେତେ ଦିନ ଲାଗିଲା?", "pa": "ਇਸਨੂੰ ਬਣਾਉਣ ਵਿੱਚ ਕਿੰਨੇ ਦਿਨ ਲੱਗੇ?",
        "ur": "اسے بنانے میں کتنے دن لگے؟", "as": "এইটো বনাবলৈ কিমান দিন লাগিল?",
    },
    "material_cost": {
        "en": "How much did the materials cost?", "hi": "सामान कितने रुपये का लगा?", "bn": "উপকরণে কত টাকা খরচ হয়েছে?",
        "mr": "साहित्याला किती रुपये लागले?", "gu": "સામાનમાં કેટલા રૂપિયા લાગ્યા?", "ta": "பொருட்களுக்கு எவ்வளவு செலவானது?",
        "te": "సామగ్రికి ఎంత ఖర్చయింది?", "kn": "ಸಾಮಗ್ರಿಗೆ ಎಷ್ಟು ಖರ್ಚಾಯಿತು?", "ml": "സാധനങ്ങൾക്ക് എത്ര രൂപ ചെലവായി?",
        "or": "ସାମଗ୍ରୀରେ କେତେ ଟଙ୍କା ଖର୍ଚ୍ଚ ହେଲା?", "pa": "ਸਮਾਨ ਉੱਤੇ ਕਿੰਨੇ ਰੁਪਏ ਲੱਗੇ?", "ur": "سامان پر کتنے روپے لگے؟",
        "as": "সামগ্ৰীত কিমান টকা খৰচ হ'ল?",
    },
}


def missing_fields(ex: Extraction | dict) -> list[str]:
    d = ex.to_dict() if isinstance(ex, Extraction) else ex
    missing = []
    if not d.get("product_type"):
        missing.append("product_type")
    if not d.get("materials"):
        missing.append("materials")
    if not d.get("time_hours"):
        missing.append("time_hours")
    if d.get("material_cost") is None:
        missing.append("material_cost")
    return missing


def follow_up_questions(ex: Extraction | dict, language: str) -> list[dict]:
    return [
        {"field": f, "text": FOLLOW_UPS[f].get(language, FOLLOW_UPS[f]["hi"]), "text_en": FOLLOW_UPS[f]["en"]}
        for f in missing_fields(ex)
    ]


def merge(base: Extraction, answer: Extraction) -> Extraction:
    """Merge a follow-up answer into the main extraction (answers only fill gaps / add)."""
    for k in ("technique", "materials", "colors"):
        for v in getattr(answer, k):
            if v not in getattr(base, k):
                getattr(base, k).append(v)
    for k in ("product_type", "weight_g", "time_hours", "material_cost", "price_hint", "quantity", "gi_craft"):
        if getattr(base, k) in (None, "", 0) and getattr(answer, k) not in (None, ""):
            setattr(base, k, getattr(answer, k))
    base.dimensions_cm = {**answer.dimensions_cm, **base.dimensions_cm}
    base.region = base.region or answer.region
    base.category = infer_category(base)
    base.care_instructions = L.CARE.get(base.category, L.CARE["Other"])["en"]
    return base


def answer_to_extraction(field_name: str, text: str) -> Extraction:
    """A bare number in reply to 'how many days' / 'how much did materials cost' should land in that slot."""
    ex = extract(text)
    nums = _parse_numbers(_tokens(text))
    if nums:
        val = nums[0][2]
        if field_name == "time_hours" and not ex.time_hours:
            unit = None
            end = nums[0][1]
            toks = _tokens(text)
            if end < len(toks):
                unit = _unit_of(toks[end])
            ex.time_hours = val * (1 if unit == "hours" else 8)
        elif field_name == "material_cost" and ex.material_cost is None:
            ex.material_cost = val
    return ex


# ---------------------------------------------------------------- listing generation (templates)

TEMPLATE_LANGS = ("en", "hi", "bn", "mr")


def _label(table: dict, key: str, lang: str) -> str:
    e = table[key]
    return e.get(lang) or e["en"]


def _join(items: list[str], lang: str) -> str:
    if not items:
        return ""
    if len(items) == 1:
        return items[0]
    conj = {"en": " and ", "hi": " और ", "bn": " ও ", "mr": " आणि "}.get(lang, ", ")
    return ", ".join(items[:-1]) + conj + items[-1]


_ADJECTIVE_TECHNIQUES = {"hand_painted", "carved", "embroidery", "woven_cane", "wheel_thrown", "block_print"}


def build_title(ex: Extraction, lang: str = "en") -> str:
    prod = _label(L.PRODUCT_TYPES, ex.product_type, lang) if ex.product_type else \
        {"en": "Handmade Craft", "hi": "हस्तनिर्मित शिल्प", "bn": "হাতে তৈরি শিল্প", "mr": "हस्तनिर्मित कलाकृती"}.get(lang, "Handmade Craft")
    ordered = sorted(ex.technique, key=lambda t: t not in _ADJECTIVE_TECHNIQUES)
    techs = [_label(L.TECHNIQUES, t, lang) for t in ordered[:2]]
    if lang == "en":
        parts = techs[:1]
        if len(techs) > 1:
            parts.append(techs[1])
        elif ex.colors and not ex.technique[1:]:
            # "Blue Pottery Blue Bowl" -> skip a colour the technique name already says
            color = next((c for c in ex.colors if L.COLORS[c]["en"].lower() not in " ".join(techs).lower()), None)
            if color:
                parts.append(_label(L.COLORS, color, lang))
        if not ex.technique and ex.materials:
            parts.append(_label(L.MATERIALS, ex.materials[0], lang))
        title = " ".join(parts + [prod])
        # "Hand-painted Blue Pottery Vase" reads better than "Hand-painted Blue Pottery Blue Vase"
        return re.sub(r"\s+", " ", title).strip()
    # Indic: technique + product (e.g. "हाथ से चित्रित ब्लू पॉटरी फूलदान")
    return " ".join(techs + ([_label(L.MATERIALS, ex.materials[0], lang)] if not techs and ex.materials else []) + [prod])


def build_description(ex: Extraction, artisan: dict, lang: str = "en") -> str:
    name = artisan.get("name") if lang == "en" else (artisan.get("name_native") or artisan.get("name"))
    place = ", ".join(p for p in [artisan.get("village") or ex.region.get("city"), artisan.get("state") or ex.region.get("state")] if p)
    prod = _label(L.PRODUCT_TYPES, ex.product_type, lang) if ex.product_type else None
    ordered = sorted(ex.technique, key=lambda t: t not in _ADJECTIVE_TECHNIQUES)
    # English stacks technique words like the title ("hand-painted blue pottery"); Indic templates list them.
    techs = " ".join(_label(L.TECHNIQUES, t, lang) for t in ordered) if lang == "en" else         _join([_label(L.TECHNIQUES, t, lang) for t in ordered], lang)
    mats = _join([_label(L.MATERIALS, m, lang) for m in ex.materials], lang)
    cols = _join([_label(L.COLORS, c, lang) for c in ex.colors], lang)
    days = round((ex.time_hours or 0) / 8, 1)
    years = artisan.get("years_practice")
    care = L.CARE.get(ex.category or "Other", L.CARE["Other"])
    s: list[str] = []
    if lang == "en":
        tech_txt = (techs + " ").replace("Dhokra ", "Dhokra lost-wax cast ") if techs else ""
        s.append(f"This {tech_txt.lower()}{(prod or 'piece').lower()} was made by hand by {name}"
                 f"{' in ' + place if place else ''}.")
        if mats:
            s.append(f"It is crafted from {mats.lower()}{' in shades of ' + cols.lower() if cols else ''}.")
        if days:
            s.append(f"Making it took about {days:g} day{'s' if days != 1 else ''} of skilled work.")
        if years:
            s.append(f"{name} has practised this craft for {years} years.")
        if ex.gi_craft:
            s.append(f"It belongs to the {ex.gi_craft} tradition, a Geographical Indication (GI) craft.")
        s.append("Every piece is one of a kind — small variations are the mark of the hand.")
        s.append(f"Care: {care['en']}")
    elif lang == "hi":
        s.append(f"यह {techs + ' ' if techs else ''}{prod or 'शिल्प'} है। इसे {name} ने{' ' + place + ' में' if place else ''} अपने हाथों से तैयार किया है।")
        if mats:
            s.append(f"इसमें {mats} का उपयोग हुआ है{'; रंग: ' + cols if cols else ''}।")
        if days:
            s.append(f"इसे बनाने में लगभग {days:g} दिन की कुशल मेहनत लगी।")
        if years:
            verb = "रहे" if artisan.get("gender") == "male" else "रही"
            s.append(f"{name} {years} वर्षों से यह शिल्प कर {verb} हैं।")
        if ex.gi_craft:
            s.append(f"यह {ex.gi_craft} परंपरा का हिस्सा है — एक भौगोलिक संकेत (GI) शिल्प।")
        s.append("हर टुकड़ा अनोखा है — छोटे-छोटे अंतर हाथ के काम की पहचान हैं।")
        s.append(f"देखभाल: {care['hi']}")
    elif lang == "bn":
        s.append(f"এই {techs + ' ' if techs else ''}{prod or 'শিল্পকর্ম'}টি {name}{' ' + place + '-এ' if place else ''} নিজের হাতে তৈরি করেছেন।")
        if mats:
            s.append(f"এটি {mats} দিয়ে তৈরি{'; রং: ' + cols if cols else ''}।")
        if days:
            s.append(f"এটি তৈরি করতে প্রায় {days:g} দিনের দক্ষ শ্রম লেগেছে।")
        if ex.gi_craft:
            s.append(f"এটি {ex.gi_craft} ঐতিহ্যের অংশ — একটি জিআই (GI) শিল্প।")
        s.append("প্রতিটি জিনিস অনন্য — ছোট ছোট পার্থক্যই হাতের কাজের পরিচয়।")
    elif lang == "mr":
        s.append(f"ही {techs + ' ' if techs else ''}{prod or 'कलाकृती'} {name} यांनी{' ' + place + ' येथे' if place else ''} स्वतःच्या हातांनी बनवली आहे।")
        if mats:
            s.append(f"ही {mats} पासून बनवली आहे{'; रंग: ' + cols if cols else ''}।")
        if days:
            s.append(f"ही बनवायला सुमारे {days:g} दिवसांचे कुशल काम लागले।")
        if ex.gi_craft:
            s.append(f"ही {ex.gi_craft} परंपरेचा भाग आहे — एक भौगोलिक मानांकन (GI) कला।")
        s.append("प्रत्येक वस्तू अनोखी आहे — लहान फरक हीच हस्तकलेची ओळख.")
    return " ".join(s)


def build_tags(ex: Extraction) -> list[str]:
    tags = ["handmade", "artisan-made"]
    tags += [L.TECHNIQUES[t]["en"].lower() for t in ex.technique]
    tags += [L.MATERIALS[m]["en"].lower() for m in ex.materials]
    tags += [L.COLORS[c]["en"].lower() for c in ex.colors]
    if ex.product_type:
        tags.append(L.PRODUCT_TYPES[ex.product_type]["en"].lower())
    if ex.gi_craft:
        tags += ["gi-tagged", ex.gi_craft.lower()]
    if ex.region.get("state"):
        tags.append(ex.region["state"].lower())
    if ex.category:
        tags.append(ex.category.lower())
    seen, out = set(), []
    for t in tags:
        if t not in seen:
            seen.add(t)
            out.append(t)
    return out


def generate_listing(ex: Extraction, artisan: dict) -> dict:
    title = build_title(ex, "en")
    return {
        "title": title,
        "short_title": title[:60],
        "seo_title": f"{title} | Handmade by {artisan.get('name', 'an Indian artisan')} | ShilpSetu",
        "description": build_description(ex, artisan, "en"),
        "category": ex.category or "Other",
        "tags": build_tags(ex),
    }


def template_translation(ex: Extraction, artisan: dict, lang: str) -> dict | None:
    if lang not in TEMPLATE_LANGS:
        return None
    return {"title": build_title(ex, lang), "description": build_description(ex, artisan, lang),
            "category": L.CATEGORY_LABELS.get(ex.category or "Other", {}).get(lang, ex.category)}


# ---------------------------------------------------------------- providers

class RuleBasedNLU:
    name = "mock"

    def analyze(self, transcript: str, language: str, artisan: dict) -> tuple[Extraction, dict]:
        ex = extract(transcript)
        return ex, generate_listing(ex, artisan)


LISTING_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["attributes", "listing"],
    "properties": {
        "attributes": {
            "type": "object",
            "additionalProperties": False,
            "required": ["product_type", "technique", "materials", "colors", "time_hours", "material_cost",
                         "quantity", "gi_craft", "category", "care_instructions", "dimensions_cm", "weight_g"],
            "properties": {
                "product_type": {"type": ["string", "null"]},
                "technique": {"type": "array", "items": {"type": "string"}},
                "materials": {"type": "array", "items": {"type": "string"}},
                "colors": {"type": "array", "items": {"type": "string"}},
                "time_hours": {"type": ["number", "null"]},
                "material_cost": {"type": ["number", "null"]},
                "quantity": {"type": ["integer", "null"]},
                "gi_craft": {"type": ["string", "null"]},
                "category": {"type": "string", "enum": L.CATEGORIES},
                "care_instructions": {"type": "string"},
                "dimensions_cm": {
                    "type": "object", "additionalProperties": False, "required": ["height", "width", "length"],
                    "properties": {k: {"type": ["number", "null"]} for k in ("height", "width", "length")},
                },
                "weight_g": {"type": ["number", "null"]},
            },
        },
        "listing": {
            "type": "object",
            "additionalProperties": False,
            "required": ["title", "short_title", "description", "tags", "title_native", "description_native"],
            "properties": {
                "title": {"type": "string"},
                "short_title": {"type": "string"},
                "description": {"type": "string"},
                "tags": {"type": "array", "items": {"type": "string"}},
                "title_native": {"type": "string"},
                "description_native": {"type": "string"},
            },
        },
    },
}

SYSTEM_PROMPT = """You help Indian artisans sell handmade crafts online. You receive what an artisan said \
about one product (transcribed speech, possibly in an Indian language, possibly with recognition errors) \
plus their profile. Extract the product's attributes and write a marketplace listing.

Rules:
- Only state facts the artisan said or that follow directly from the craft named. Never invent \
dimensions, prices, costs, time taken or materials; use null or empty lists when not said.
- time_hours: convert days to hours at 8 working hours per day.
- material_cost is in rupees and is the artisan's cost of materials, not the selling price.
- The English description should be warm and specific, credit the artisan by name and place, mention \
the technique and materials, and end with a one-line care instruction. 60-110 words.
- title_native / description_native: the same listing in the artisan's language (given as an ISO code), \
in its own script.
- The category must be one of the allowed values."""


class ClaudeNLU:
    name = "claude"

    def __init__(self, api_key: str, model: str):
        import anthropic

        self.client = anthropic.Anthropic(api_key=api_key or None)
        self.model = model

    def analyze(self, transcript: str, language: str, artisan: dict) -> tuple[Extraction, dict]:
        user = json.dumps({"artisan_language": language, "transcript": transcript, "artisan": artisan},
                          ensure_ascii=False)
        response = self.client.beta.messages.create(
            model=self.model,
            max_tokens=4000,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user}],
            output_config={"effort": "low", "format": {"type": "json_schema", "schema": LISTING_SCHEMA}},
            betas=["server-side-fallback-2026-07-01"],
            fallbacks="default",
        )
        if response.stop_reason in ("refusal", "max_tokens"):
            raise RuntimeError(f"LLM stopped: {response.stop_reason}")
        text = next(b.text for b in response.content if b.type == "text")
        data = json.loads(text)
        a = data["attributes"]
        # Map free-text model output back onto our lexicon keys where possible, keeping unknowns verbatim.
        rb = extract(" ".join([a.get("product_type") or ""] + a["technique"] + a["materials"] + a["colors"]))
        ex = Extraction(
            product_type=rb.product_type or None,
            technique=rb.technique,
            materials=rb.materials,
            colors=rb.colors,
            dimensions_cm={k: v for k, v in a["dimensions_cm"].items() if v},
            weight_g=a["weight_g"],
            time_hours=a["time_hours"],
            material_cost=a["material_cost"],
            quantity=a["quantity"],
            gi_craft=a["gi_craft"],
            category=a["category"],
            care_instructions=a["care_instructions"],
            region=extract(transcript).region,
            confidence={"product_type": 0.95, "category": 0.95, "materials": 0.9 if a["materials"] else 0.0},
        )
        lst = data["listing"]
        listing = {
            "title": lst["title"],
            "short_title": lst["short_title"][:60],
            "seo_title": f"{lst['title']} | Handmade by {artisan.get('name', 'an Indian artisan')} | ShilpSetu",
            "description": lst["description"],
            "category": a["category"],
            "tags": lst["tags"],
            "native": {"title": lst["title_native"], "description": lst["description_native"]},
        }
        return ex, listing


def get_nlu(provider: str):
    from api.config import get_settings

    s = get_settings()
    if provider == "claude":
        return ClaudeNLU(s.anthropic_api_key, s.llm_model)
    return RuleBasedNLU()
