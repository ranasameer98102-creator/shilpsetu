"""Shilpi, the in-app assistant: a friendly, Duolingo-style guide for artisans and buyers.

The rule-based engine (default, offline, free) detects an intent from what the user said in English or Hindi and
answers from the app's own data. With ASSISTANT_PROVIDER=claude, Claude rewrites the answer conversationally in any
language, grounded in the same facts; the rule-based answer is the fallback.
"""
from __future__ import annotations

import json
import logging
import re
from dataclasses import dataclass, field

from . import crafts
from . import lexicon as L
from .nlu import _parse_numbers, _tokens, extract

log = logging.getLogger("shilpsetu")
NAME = {"en": "Shilpi", "hi": "शिल्पी"}


def _t(lang: str, en: str, hi: str) -> str:
    return hi if lang == "hi" else en


def _has(text: str, *words: str) -> bool:
    """Latin words match at a word start ("photo" -> "photos"); words of 3 letters or fewer must match whole."""
    low = text.lower()
    return any(re.search(rf"\b{re.escape(w)}" + (r"\b" if len(w) <= 3 else ""), low) if w.isascii() else w in text
               for w in words)


@dataclass
class Intent:
    name: str
    budget: int | None = None
    craft: str | None = None
    query: str | None = None


def detect(message: str, role: str) -> Intent:
    m = message.strip()
    ex = extract(m)
    craft = crafts.craft_key(ex.technique)
    numbers = [int(v) for _, _, v in _parse_numbers(_tokens(m))]
    if _has(m, "hello", "hi", "hey", "namaste", "नमस्ते", "नमस्कार", "हेलो") and len(m.split()) <= 3:
        return Intent("hello")
    if _has(m, "thank", "धन्यवाद", "शुक्रिया", "thanks"):
        return Intent("thanks")
    if role in ("artisan", "operator"):
        if _has(m, "photo", "picture", "फोटो", "तस्वीर", "फ़ोटो"):
            return Intent("photo_tips")
        if _has(m, "earn", "money", "payment", "payout", "कमाई", "पैसे", "पैसा", "भुगतान"):
            return Intent("earnings")
        if _has(m, "order", "ऑर्डर", "आर्डर"):
            return Intent("artisan_orders")
        if _has(m, "price", "cost", "fair", "दाम", "कीमत", "मूल्य"):
            return Intent("price_help")
        if _has(m, "streak", "goal", "badge", "लक्ष्य", "स्ट्रीक", "बैज"):
            return Intent("streak")
        if _has(m, "sell best", "sells", "demand", "popular", "trend", "क्या बिकता", "ज़्यादा बिक", "मांग"):
            return Intent("what_sells")
        if _has(m, "add", "list", "upload", "new product", "sell", "जोड़", "बेच", "नया सामान", "डाल"):
            return Intent("how_to_list")
        if _has(m, "help", "call", "helpline", "मदद", "सहायता"):
            return Intent("help")
    if craft and _has(m, "about", "history", "what is", "tell", "story", "made", "बताओ", "बताइए", "इतिहास",
                      "क्या है", "कैसे बन", "कहानी"):
        return Intent("craft_info", craft=craft)
    if role not in ("artisan", "operator"):
        if _has(m, "track", "my order", "order", "delivery", "ऑर्डर", "डिलीवरी"):
            return Intent("track_order")
        if _has(m, "gi tag", "gi", "geographical indication", "जीआई"):
            return Intent("gi_info")
        if _has(m, "certificate", "qr", "genuine", "authentic", "fake", "असली", "प्रमाण"):
            return Intent("certificate_info")
        if _has(m, "fair price", "why price", "expensive", "costly", "महंगा", "दाम क्यों"):
            return Intent("fair_price_info")
        if _has(m, "cheap", "cheapest", "affordable", "budget", "low price", "सस्ता", "सस्ते", "कम दाम"):
            return Intent("gifts", budget=numbers[0] if numbers else 400)
        if _has(m, "gift", "under", "below", "within", "less than", "तोहफ़ा", "तोहफा", "उपहार", "से कम", "तक", "गिफ्ट"):
            return Intent("gifts", budget=numbers[0] if numbers else 500, craft=craft)
        if craft or ex.product_type or _has(m, "show", "find", "want", "looking for", "दिखाओ", "चाहिए", "ढूंढ"):
            return Intent("find", craft=craft, query=_search_words(m, ex))
    if craft:
        return Intent("craft_info", craft=craft)
    return Intent("fallback")


def _search_words(m: str, ex) -> str:
    if ex.technique:
        return L.TECHNIQUES[ex.technique[0]]["en"]
    if ex.product_type:
        return L.PRODUCT_TYPES[ex.product_type]["en"]
    stop = {"show", "me", "find", "i", "want", "looking", "for", "some", "a", "an", "the", "please", "dikhao"}
    return " ".join(w for w in re.findall(r"\w+", m.lower()) if w not in stop)[:40]


@dataclass
class Reply:
    text: str
    mood: str = "happy"  # happy | cheer | think | wave
    suggestions: list[str] = field(default_factory=list)
    actions: list[dict] = field(default_factory=list)  # {label, route}
    products: list[dict] = field(default_factory=list)


BUYER_SUGGESTIONS = {
    "en": ["Gifts under ₹500", "Tell me about Madhubani", "What is a GI tag?", "Track my order"],
    "hi": ["₹500 से कम के तोहफ़े", "मधुबनी के बारे में बताओ", "GI टैग क्या है?", "मेरा ऑर्डर कहाँ है?"],
}
ARTISAN_SUGGESTIONS = {
    "en": ["How do I add a product?", "Photo tips", "How is my price decided?", "What sells best?"],
    "hi": ["नया सामान कैसे जोड़ें?", "फोटो कैसे खींचें?", "मेरा दाम कैसे तय होता है?", "क्या ज़्यादा बिकता है?"],
}


def suggestions(role: str, lang: str) -> list[str]:
    table = ARTISAN_SUGGESTIONS if role in ("artisan", "operator") else BUYER_SUGGESTIONS
    return table.get(lang, table["en"])


def respond(intent: Intent, lang: str, role: str, facts: dict) -> Reply:
    """Rule-based answer. `facts` carries whatever the router looked up (products, stats, orders, craft story)."""
    lang = "hi" if lang == "hi" else "en"
    name = NAME[lang]
    sug = suggestions(role, lang)
    i = intent.name
    if i == "hello":
        return Reply(_t(lang, f"Namaste! I'm {name}, your ShilpSetu helper. Ask me anything - by voice or typing.",
                        f"नमस्ते! मैं {name} हूँ, आपकी शिल्पसेतु सहायक। बोलकर या लिखकर कुछ भी पूछिए।"), "wave", sug)
    if i == "thanks":
        return Reply(_t(lang, "Happy to help! Come back any time.", "ख़ुशी हुई! कभी भी पूछिए।"), "cheer", sug)
    if i == "craft_info":
        c = facts.get("craft")
        if c:
            return Reply(f"{c['name']} ({c['region']}). {c['history']} {_t(lang, 'Did you know?', 'क्या आप जानते हैं?')} {c['fact']}",
                         "happy", sug,
                         [{"label": _t(lang, f"See {c['name']} crafts", f"{c['name']} देखें"),
                           "route": f"/store/search?q={facts.get('craft_query', c['name'])}"}], facts.get("products", []))
    if i == "gifts":
        items = facts.get("products", [])
        if items:
            return Reply(_t(lang, f"Here are handmade picks under ₹{intent.budget} - every one pays the artisan a fair wage.",
                            f"₹{intent.budget} से कम के ये हस्तनिर्मित तोहफ़े हैं - हर एक में कारीगर को उचित मज़दूरी मिलती है।"),
                         "cheer", sug, [{"label": _t(lang, "See all", "सब देखें"), "route": "/store/search?sort=price_asc"}], items)
        return Reply(_t(lang, f"I couldn't find anything under ₹{intent.budget} right now. Here are the most affordable pieces.",
                        f"अभी ₹{intent.budget} से कम कुछ नहीं मिला। ये सबसे किफ़ायती चीज़ें हैं।"), "think", sug,
                     [{"label": _t(lang, "Lowest prices", "सबसे कम दाम"), "route": "/store/search?sort=price_asc"}],
                     facts.get("cheapest", []))
    if i == "find":
        items = facts.get("products", [])
        if items:
            return Reply(_t(lang, f"I found these for \"{intent.query}\".", f"\"{intent.query}\" के लिए ये मिले।"), "happy", sug,
                         [{"label": _t(lang, "See all results", "सारे नतीजे"), "route": f"/store/search?q={intent.query}"}], items)
        return Reply(_t(lang, "I couldn't find that yet. Try a craft name like Madhubani, Dhokra or Pashmina.",
                        "वह अभी नहीं मिला। मधुबनी, ढोकरा या पश्मीना जैसा नाम बोलकर देखिए।"), "think", sug)
    if i == "track_order":
        o = facts.get("order")
        if o:
            return Reply(_t(lang, f"Your latest order #{o['id'][:8]} is {o['status']}.",
                            f"आपका पिछला ऑर्डर #{o['id'][:8]} अभी '{o['status']}' है।"), "happy", sug,
                         [{"label": _t(lang, "My orders", "मेरे ऑर्डर"), "route": "/store/orders"}])
        return Reply(_t(lang, "I don't see any orders yet. Log in and your orders will show up here.",
                        "अभी कोई ऑर्डर नहीं दिखा। लॉग इन करने पर आपके ऑर्डर यहाँ दिखेंगे।"), "think", sug,
                     [{"label": _t(lang, "My orders", "मेरे ऑर्डर"), "route": "/store/orders"}])
    if i == "gi_info":
        return Reply(_t(lang, "A GI (Geographical Indication) tag is a government mark that a craft comes from its home "
                              "region and is made the traditional way - like Madhubani paintings from Bihar or Kashmir "
                              "Pashmina. Look for the GI line on a product page.",
                        "GI (भौगोलिक संकेत) टैग सरकार का निशान है कि शिल्प अपने मूल इलाके से और पारंपरिक तरीके से बना है - जैसे बिहार की "
                        "मधुबनी या कश्मीरी पश्मीना। उत्पाद पेज पर GI लाइन देखिए।"), "happy", sug)
    if i == "certificate_info":
        return Reply(_t(lang, "Every live product has a signed QR certificate. Scan it and the app checks the digital "
                              "signature - it shows who made it, where, and that nobody changed the details.",
                        "हर उत्पाद के साथ डिजिटल हस्ताक्षर वाला QR प्रमाणपत्र होता है। स्कैन करने पर पता चलता है किसने, कहाँ बनाया और "
                        "जानकारी बदली नहीं गई।"), "happy", sug,
                     [{"label": _t(lang, "Scan a QR", "QR स्कैन करें"), "route": "/store/scan"}])
    if i == "fair_price_info":
        return Reply(_t(lang, "Prices start from the artisan's real costs - materials, hours at a fair wage, packing and "
                              "delivery - plus a small 4% platform fee. Open 'How this price is built' on any product to see every rupee.",
                        "दाम कारीगर की असली लागत से शुरू होता है - सामान, उचित मज़दूरी पर घंटे, पैकिंग और डिलीवरी - और सिर्फ़ 4% "
                        "प्लेटफ़ॉर्म फ़ीस। किसी भी उत्पाद पर 'दाम कैसे बना' खोलकर हर रुपया देखिए।"), "happy", sug)
    # ---- artisan intents
    s = facts.get("stats", {})
    if i == "how_to_list":
        return Reply(_t(lang, "It takes three steps: 1) take one photo, 2) say what it is, how long it took and what the "
                              "materials cost, 3) check the listing and tap Publish. I'll write the title, story and fair price.",
                        "तीन कदम: 1) एक फोटो खींचिए, 2) बोलिए यह क्या है, कितना समय लगा और सामान कितने का था, 3) देखकर 'लाइव करें' "
                        "दबाइए। नाम, कहानी और सही दाम मैं बना दूँगी।"), "cheer", sug,
                     [{"label": _t(lang, "Add a product", "सामान जोड़ें"), "route": "/artisan/capture"}])
    if i == "photo_tips":
        return Reply(_t(lang, "Photo tips: stand near a window for daylight, put the item in the middle, hold the phone "
                              "steady and fill most of the frame. Any background is fine - I clean it up for you.",
                        "फोटो टिप्स: खिड़की के पास दिन की रोशनी में खड़े हों, सामान बीच में रखें, फ़ोन स्थिर रखें और सामान से फ्रेम भरें। "
                        "पीछे कुछ भी हो - मैं साफ़ कर दूँगी।"), "happy", sug,
                     [{"label": _t(lang, "Take a photo", "फोटो खींचें"), "route": "/artisan/capture"}])
    if i == "price_help":
        return Reply(_t(lang, f"Your price covers your materials, your hours at at least ₹{s.get('wage', 100)} an hour, "
                              "tools, packing and delivery, plus a 4% platform fee. Anything above that goes to you. "
                              "You can always change the price before publishing.",
                        f"आपके दाम में सामान, कम से कम ₹{s.get('wage', 100)} प्रति घंटे की मज़दूरी, औज़ार, पैकिंग और डिलीवरी आती है, "
                        "और 4% फ़ीस। इससे ऊपर का सारा पैसा आपका है। लाइव करने से पहले आप दाम बदल सकते हैं।"), "happy", sug)
    if i == "earnings":
        return Reply(_t(lang, f"This month you earned ₹{s.get('earned_month', 0):,} from {s.get('orders_month', 0)} orders.",
                        f"इस महीने आपने {s.get('orders_month', 0)} ऑर्डर से ₹{s.get('earned_month', 0):,} कमाए।"),
                     "cheer" if s.get("earned_month") else "happy", sug,
                     [{"label": _t(lang, "My earnings", "मेरी कमाई"), "route": "/artisan/earnings"}])
    if i == "artisan_orders":
        n = s.get("open_orders", 0)
        return Reply(_t(lang, f"You have {n} order{'s' if n != 1 else ''} waiting." if n else "No orders waiting right now.",
                        f"आपके {n} ऑर्डर इंतज़ार में हैं।" if n else "अभी कोई ऑर्डर इंतज़ार में नहीं है।"),
                     "cheer" if n else "happy", sug,
                     [{"label": _t(lang, "Open orders", "ऑर्डर देखें"), "route": "/artisan/orders"}])
    if i == "streak":
        st = s.get("streak", 0)
        return Reply(_t(lang, f"You're on a {st}-day streak! Open ShilpSetu every day and list something new to keep it going.",
                        f"आपकी {st} दिन की लगातार स्ट्रीक है! रोज़ शिल्पसेतु खोलिए और कुछ नया जोड़िए।"), "cheer", sug)
    if i == "what_sells":
        top = facts.get("top_categories", [])
        if top:
            names = ", ".join(L.CATEGORY_LABELS.get(c, {}).get(lang, c) for c in top[:3])
            return Reply(_t(lang, f"Buyers are looking most at: {names}. Small, affordable pieces (under ₹500) also sell quickly.",
                            f"ख़रीदार सबसे ज़्यादा ये देख रहे हैं: {names}। ₹500 से कम की छोटी चीज़ें भी जल्दी बिकती हैं।"), "think", sug)
    if i == "help":
        return Reply(_t(lang, f"You can give a missed call to {facts.get('helpline', 'the helpline')} and we'll call you back, "
                              "or ask me here.",
                        f"{facts.get('helpline', 'हेल्पलाइन')} पर मिस्ड कॉल दीजिए, हम वापस कॉल करेंगे - या मुझसे यहीं पूछिए।"), "happy", sug,
                     [{"label": _t(lang, "Help videos", "मदद वीडियो"), "route": "/artisan/help"}])
    if role in ("artisan", "operator"):
        return Reply(_t(lang, "I can help you add products, take better photos, understand your price, and check orders "
                              "and earnings. Try one of these:",
                        "मैं सामान जोड़ने, अच्छी फोटो, दाम समझने और ऑर्डर-कमाई देखने में मदद कर सकती हूँ। इनमें से कुछ पूछिए:"),
                     "think", sug)
    return Reply(_t(lang, "I can find gifts for any budget, tell you the story of a craft, or check your order. Try:",
                    "मैं किसी भी बजट के तोहफ़े ढूंढ सकती हूँ, किसी शिल्प की कहानी बता सकती हूँ या ऑर्डर देख सकती हूँ। पूछिए:"),
                 "think", sug)


# ---------------------------------------------------------------- Claude (optional)

REPLY_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["reply", "suggestions"],
    "properties": {
        "reply": {"type": "string"},
        "suggestions": {"type": "array", "items": {"type": "string"}},
    },
}

SYSTEM_PROMPT = """You are Shilpi, the warm, encouraging assistant inside ShilpSetu, an Indian marketplace that helps \
rural artisans sell handmade crafts at fair prices. You talk like a friendly coach: short sentences, simple words, \
a little celebration when something goes well.

You will get the user's role (artisan or buyer), their language, their message, recent turns, and FACTS looked up \
from the app (products, prices, orders, earnings, craft history). Answer in the user's language and script, in at \
most 70 words, so it can be read aloud. Use only the FACTS for anything specific - never invent prices, products, \
orders or numbers. If the FACTS do not cover the question, say what you can help with instead. Do not use markdown.

Also give 2 to 4 short follow-up questions the user might tap next, in the same language."""


class ClaudeAssistant:
    def __init__(self, api_key: str, model: str):
        import anthropic

        self.client = anthropic.Anthropic(api_key=api_key or None)
        self.model = model

    def polish(self, message: str, lang: str, role: str, history: list[dict], draft: Reply, facts: dict) -> Reply:
        slim = {k: v for k, v in facts.items() if k not in ("products", "cheapest")}
        slim["products"] = [{"title": p.get("title"), "price": p.get("price"), "place": p.get("location")}
                            for p in (facts.get("products") or facts.get("cheapest") or [])[:6]]
        user = json.dumps({"role": role, "language": lang, "message": message, "recent_turns": history[-6:],
                           "facts": slim, "draft_answer": draft.text}, ensure_ascii=False, default=str)
        response = self.client.beta.messages.create(
            model=self.model,
            max_tokens=1500,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user}],
            output_config={"effort": "low", "format": {"type": "json_schema", "schema": REPLY_SCHEMA}},
            betas=["server-side-fallback-2026-07-01"],
            fallbacks="default",
        )
        if response.stop_reason in ("refusal", "max_tokens"):
            raise RuntimeError(f"LLM stopped: {response.stop_reason}")
        data = json.loads(next(b.text for b in response.content if b.type == "text"))
        return Reply(data["reply"], draft.mood, data["suggestions"][:4] or draft.suggestions, draft.actions, draft.products)


def get_assistant(provider: str):
    from api.config import get_settings

    s = get_settings()
    if provider == "claude" and s.anthropic_api_key:
        return ClaudeAssistant(s.anthropic_api_key, s.llm_model)
    return None
