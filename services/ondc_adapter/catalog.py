"""Map ShilpSetu listings to the ONDC retail (Beckn 1.2) catalog schema."""
from __future__ import annotations

from collections import defaultdict

from sqlalchemy.orm import Session

from api.config import get_settings
from api.models import Artisan, Product
from api.storage import media_url

ONDC_CATEGORY = {
    "Textiles & Handloom": "Handloom", "Pottery & Ceramics": "Pottery", "Metalcraft": "Metal Craft",
    "Woodcraft": "Wood Craft", "Bamboo & Cane": "Bamboo & Cane Craft", "Jewellery": "Handcrafted Jewellery",
    "Paintings & Folk Art": "Paintings", "Leather": "Leather Craft", "Stone Craft": "Stone Craft",
    "Toys & Dolls": "Toys", "Home Décor": "Home Decor", "Other": "Handicraft",
}


def item(db: Session, p: Product) -> dict:
    from api.domain.pricing_service import current_quote

    q = current_quote(db, p.id)
    images = [media_url(m.url) for m in sorted(p.media, key=lambda m: m.position) if m.kind == "enhanced"]
    ex = (p.attributes or {}).get("extraction", {})
    cert = p.certificate
    tags = [
        {"code": "origin", "list": [{"code": "country", "value": "IND"}]},
        {"code": "handicraft", "list": [
            {"code": "category", "value": ONDC_CATEGORY.get(p.category or "Other", "Handicraft")},
            {"code": "craft", "value": ", ".join(ex.get("technique", [])) or (p.artisan.craft_type or "")},
            {"code": "gi_tag", "value": ex.get("gi_craft") or p.artisan.gi_tag or ""},
            {"code": "artisan_share_pct", "value": f"{q.artisan_share_pct:.1f}" if q else ""},
            {"code": "provenance_certificate", "value": cert.qr_url if cert and not cert.revoked_at else ""},
        ]},
    ]
    return {
        "id": p.id,
        "descriptor": {
            "name": p.title, "short_desc": p.short_title or p.title, "long_desc": p.description or "",
            "images": images, "symbol": images[0] if images else "",
        },
        "price": {"currency": "INR", "value": f"{p.price:.2f}", "maximum_value": f"{(p.compare_at_price or p.price):.2f}"},
        "quantity": {"available": {"count": str(p.quantity if p.status == "live" else 0)},
                     "maximum": {"count": str(max(p.quantity, 0))}},
        "category_id": ONDC_CATEGORY.get(p.category or "Other", "Handicraft"),
        "fulfillment_id": "F1",
        "location_id": f"L-{p.artisan_id}",
        "@ondc/org/returnable": False,
        "@ondc/org/cancellable": True,
        "@ondc/org/available_on_cod": True,
        "@ondc/org/time_to_ship": "P3D",
        "@ondc/org/seller_pickup_return": False,
        "@ondc/org/contact_details_consumer_care": "ShilpSetu Helpdesk, help@shilpsetu.example, 1800-000-000",
        "tags": tags,
    }


def provider(db: Session, artisan: Artisan, products: list[Product]) -> dict:
    return {
        "id": artisan.id,
        "descriptor": {"name": artisan.shg_name or artisan.name, "short_desc": artisan.craft_type or "Artisan",
                       "long_desc": (artisan.story_text or "")[:500],
                       "images": [media_url(artisan.photo_url)] if artisan.photo_url and (artisan.consent_flags or {}).get("photo") else []},
        "locations": [{"id": f"L-{artisan.id}", "address": {"locality": artisan.village or "", "city": artisan.district or "",
                                                           "state": artisan.state or "", "country": "IND"}}],
        "fulfillments": [{"id": "F1", "type": "Delivery"}],
        "tags": [{"code": "serviceability", "list": [{"code": "location", "value": f"L-{artisan.id}"},
                                                      {"code": "category", "value": "Handicraft"},
                                                      {"code": "type", "value": "12"}, {"code": "val", "value": "IND"},
                                                      {"code": "unit", "value": "country"}]}],
        "items": [item(db, p) for p in products],
    }


def catalog(db: Session, products: list[Product]) -> dict:
    by_artisan: dict[str, list[Product]] = defaultdict(list)
    for p in products:
        by_artisan[p.artisan_id].append(p)
    s = get_settings()
    return {
        "bpp/descriptor": {"name": "ShilpSetu", "short_desc": "Fair-priced, provenance-verified crafts from Indian artisans",
                           "symbol": f"{s.public_base_url}/static/icon.png"},
        "bpp/providers": [provider(db, db.get(Artisan, aid), ps) for aid, ps in by_artisan.items()],
    }
