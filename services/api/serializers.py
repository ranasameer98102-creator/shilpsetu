"""Model -> JSON shapes shared by routers."""
from __future__ import annotations

from sqlalchemy.orm import Session

from ai import crafts
from ai import lexicon as L
from .domain import pricing_service
from .models import Artisan, Product
from .storage import media_url


def artisan_public(a: Artisan) -> dict:
    consent = a.consent_flags or {}
    return {
        "id": a.id, "name": a.name, "name_native": a.name_native, "village": a.village, "district": a.district,
        "state": a.state, "craft_type": a.craft_type, "years_practice": a.years_practice,
        "story_text": a.story_text, "story_translations": a.story_translations or {},
        "story_audio_url": media_url(a.story_audio_url) if consent.get("voice") else None,
        "photo_url": media_url(a.photo_url) if consent.get("photo") else None,
        "pehchan_verified": a.pehchan_verified, "verification_status": a.verification_status,
        "shg_name": a.shg_name, "cluster": a.cluster, "gi_tag": a.gi_tag,
        "verified": a.verification_status == "verified",
    }


def _media(p: Product) -> list[dict]:
    return [{"kind": m.kind, "url": media_url(m.url), "width": m.width, "height": m.height, "position": m.position}
            for m in sorted(p.media, key=lambda m: (m.position, m.kind)) if m.kind != "answer_audio"]


def _image(p: Product, kind: str) -> str | None:
    for pref in (kind, "enhanced", "original"):
        m = next((m for m in sorted(p.media, key=lambda m: m.position) if m.kind == pref), None)
        if m:
            return media_url(m.url)
    return None


def localized(p: Product, lang: str | None) -> tuple[str | None, str | None]:
    t = (p.translations or {}).get(lang or "en") if lang else None
    if t and t.get("title"):
        return t["title"], t.get("description")
    return p.title, p.description


def category_label(p: Product, lang: str | None) -> str | None:
    t = (p.translations or {}).get(lang or "en") if lang else None
    return (t or {}).get("category") or p.category


def product_card(p: Product, lang: str | None = None, share_pct: float | None = None) -> dict:
    title, _ = localized(p, lang)
    a = p.artisan
    loc = ", ".join(x for x in [a.district or a.village, a.state] if x)
    return {
        "id": p.id, "title": title, "price": p.price, "compare_at_price": p.compare_at_price,
        "category": p.category, "category_label": category_label(p, lang), "thumb": _image(p, "thumb"), "image": _image(p, "enhanced"),
        "rating_avg": p.rating_avg, "rating_count": p.rating_count,
        "verified": a.verification_status == "verified", "gi": bool(a.gi_tag or (p.attributes or {}).get("extraction", {}).get("gi_craft")),
        "location": loc, "artisan_name": a.name, "artisan_share_pct": share_pct, "state": a.state,
        "women_led": a.gender == "female",
    }


def product_full(db: Session, p: Product, lang: str | None = None) -> dict:
    q = pricing_service.current_quote(db, p.id)
    cert = p.certificate
    title, desc = localized(p, lang)
    return {
        "id": p.id, "status": p.status, "title": title, "short_title": p.short_title, "description": desc,
        "category": p.category, "category_label": category_label(p, lang), "tags": p.tags or [],
        "translations": p.translations or {}, "language": p.language,
        "transcript": p.transcript, "attributes": {k: v for k, v in (p.attributes or {}).items()
                                                   if k not in ("answers",)},
        "quantity": p.quantity, "price": p.price, "compare_at_price": p.compare_at_price,
        "needs_review_fields": p.needs_review_fields or [], "pipeline": p.pipeline or {}, "media": _media(p),
        "price_quote": pricing_service.as_dict(q) if q else None,
        "certificate": {"id": cert.id, "qr_url": cert.qr_url, "issued_at": cert.issued_at.isoformat(),
                        "revoked": bool(cert.revoked_at), "sha256": cert.sha256} if cert else None,
        "created_via": p.created_via, "published_at": p.published_at,
        "rating_avg": p.rating_avg, "rating_count": p.rating_count,
        "artisan": artisan_public(p.artisan),
        "details": product_details(p, lang),
        "craft": crafts.craft_story(
            crafts.craft_key((p.attributes or {}).get("extraction", {}).get("technique", []), p.artisan.craft_type),
            (lang or "en") if (lang or "en") in ("en", "hi") else "en"),
        "location": ", ".join(x for x in [p.artisan.district or p.artisan.village, p.artisan.state] if x)
                    + (" • GI-linked cluster" if (p.artisan.gi_tag or (p.attributes or {}).get("extraction", {}).get("gi_craft")) else ""),
    }


_DETAIL_LABELS = {
    "en": {"technique": "Technique", "materials": "Materials", "colors": "Colours", "time": "Time to make",
           "size": "Size", "weight": "Weight", "care": "Care", "category": "Category", "hours": "{n} hours",
           "days": "about {n} days", "gi": "GI tag"},
    "hi": {"technique": "तकनीक", "materials": "सामग्री", "colors": "रंग", "time": "बनाने में समय", "size": "आकार",
           "weight": "वज़न", "care": "देखभाल", "category": "श्रेणी", "hours": "{n} घंटे", "days": "लगभग {n} दिन",
           "gi": "GI टैग"},
}


def product_details(p: Product, lang: str | None = None) -> list[dict]:
    """Label/value rows for the product page: technique, materials, colours, time, size, weight, care."""
    lang = lang if lang in _DETAIL_LABELS else "en"
    lab = _DETAIL_LABELS[lang]
    ex = (p.attributes or {}).get("extraction", {})

    def names(table: dict, keys: list[str]) -> str:
        return ", ".join(table[k].get(lang) or table[k]["en"] for k in keys if k in table)

    rows: list[dict] = []
    if p.category:
        rows.append({"key": "category", "label": lab["category"],
                     "value": L.CATEGORY_LABELS.get(p.category, {}).get(lang, p.category)})
    for key, table, field in (("technique", L.TECHNIQUES, "technique"), ("materials", L.MATERIALS, "materials"),
                              ("colors", L.COLORS, "colors")):
        v = names(table, ex.get(field) or [])
        if v:
            rows.append({"key": key, "label": lab[key], "value": v})
    hours = ex.get("time_hours")
    if hours:
        v = lab["hours"].format(n=int(hours)) if hours < 16 else lab["days"].format(n=round(hours / 8))
        rows.append({"key": "time", "label": lab["time"], "value": v})
    dims = ex.get("dimensions_cm") or {}
    if dims:
        rows.append({"key": "size", "label": lab["size"],
                     "value": " × ".join(f"{v:g} cm" for v in dims.values())})
    if ex.get("weight_g"):
        rows.append({"key": "weight", "label": lab["weight"], "value": f"{ex['weight_g']:g} g"})
    gi = ex.get("gi_craft") or (p.artisan.gi_tag if p.artisan else None)
    if gi:
        rows.append({"key": "gi", "label": lab["gi"], "value": gi})
    care = L.CARE.get(p.category or "Other", L.CARE["Other"])
    rows.append({"key": "care", "label": lab["care"], "value": care.get(lang) or care["en"]})
    return rows
