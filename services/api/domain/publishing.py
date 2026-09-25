"""'You Approve' -> 'Goes Live': publish to the storefront, issue the signed certificate, queue ONDC sync."""
from __future__ import annotations

from sqlalchemy.orm import Session

from api import audit, certs
from api.models import Artisan, Certificate, OndcSync, Product, now, uid

from . import pricing_service


def certificate_payload(db: Session, product: Product, draft: bool = False, cert_id: str | None = None) -> dict:
    a: Artisan = product.artisan
    q = pricing_service.current_quote(db, product.id)
    ex = (product.attributes or {}).get("extraction", {})
    from ai import lexicon as L

    materials = [L.MATERIALS[m]["en"] if m in L.MATERIALS else m for m in ex.get("materials", [])]
    techniques = [L.TECHNIQUES[t]["en"] if t in L.TECHNIQUES else t for t in ex.get("technique", [])]
    original = next((m for m in sorted(product.media, key=lambda m: m.position) if m.kind == "original"), None)
    consent = a.consent_flags or {}
    location = ", ".join(p for p in [a.district or a.village, a.state] if p)
    gi = ex.get("gi_craft") or a.gi_tag
    return {
        "v": 1,
        "certificate_id": cert_id or ("draft" if draft else uid()),
        "listing_id": product.id,
        "product": {"title": product.title, "category": product.category},
        "artisan": {
            "id": a.id, "name": a.name, "name_native": a.name_native,
            "photo": a.photo_url if consent.get("photo") and a.photo_url else None,
            "pehchan_verified": bool(a.pehchan_verified),
            "verified": a.verification_status == "verified",
            "shg": a.shg_name,
        },
        "craft": " · ".join(techniques) or a.craft_type,
        "cluster": a.cluster,
        "gi": gi,
        "location": location + (" • GI-linked cluster" if gi else ""),
        "materials": materials,
        "story": (a.story_text or "")[:600],
        "story_audio": bool(a.story_audio_url and consent.get("voice")),
        "fair_price": {
            "price": q.final_price if q else product.price,
            "artisan_share_amount": q.artisan_share_amount if q else None,
            "artisan_share_pct": q.artisan_share_pct if q else None,
            "basis": [{"label": l["label"], "amount": l["amount"]} for l in (q.breakdown or {}).get("lines", [])] if q else [],
            "model_version": q.model_version if q else None,
        },
        "created_at": (product.captured_offline_at or product.created_at).isoformat(),
        "original_photo_sha256": original.sha256 if original else None,
        "issued_at": now().isoformat(),
        "issuer": "ShilpSetu",
        "key_id": certs.key_id(),
    }


def issue_certificate(db: Session, product: Product, actor_id: str | None = None) -> Certificate:
    existing = product.certificate
    if existing and not existing.revoked_at:
        return existing
    if existing:  # re-issue after revocation: replace the record, keep the audit trail
        db.delete(existing)
        db.flush()
    cid = uid()
    payload = certificate_payload(db, product, cert_id=cid)
    signature, digest = certs.sign(payload)
    cert = Certificate(id=cid, product_id=product.id, payload=payload, signature=signature, sha256=digest,
                       qr_url=certs.verify_url(cid, signature), key_id=payload["key_id"])
    db.add(cert)
    db.flush()
    audit.record(db, "certificate.issued", "certificate", cid, {"product_id": product.id, "sha256": digest},
                 actor_id)
    return cert


def revoke_certificate(db: Session, cert: Certificate, reason: str, actor_id: str | None) -> None:
    cert.revoked_at = now()
    cert.revoked_reason = reason
    audit.record(db, "certificate.revoked", "certificate", cert.id, {"reason": reason}, actor_id)


def publish(db: Session, product: Product, actor_id: str | None = None) -> Certificate:
    from notify import service as notify

    product.status = "live"
    product.published_at = product.published_at or now()
    cert = issue_certificate(db, product, actor_id)
    sync = db.query(OndcSync).filter_by(product_id=product.id).one_or_none()
    if sync is None:
        db.add(OndcSync(product_id=product.id, status="queued"))
    else:
        sync.status = "queued"
    audit.record(db, "product.published", "product", product.id, {"price": product.price}, actor_id)
    user = product.artisan.user
    q = pricing_service.current_quote(db, product.id)
    notify.send(db, user, "listing_live", {"title": product.short_title or product.title,
                                           "price": f"{product.price:,.0f}",
                                           "share": f"{(q.artisan_share_amount if q else product.price):,.0f}"})
    notify.send(db, user, "certificate_issued", {"title": product.short_title or product.title, "url": cert.qr_url})
    db.flush()
    return cert


def unpublish(db: Session, product: Product, reason: str, actor_id: str | None) -> None:
    product.status = "unpublished"
    product.moderation_flag = reason
    sync = db.query(OndcSync).filter_by(product_id=product.id).one_or_none()
    if sync:
        sync.status = "queued"  # the sync job will push a zero-quantity update to ONDC
    audit.record(db, "product.unpublished", "product", product.id, {"reason": reason}, actor_id)
