"""The 5-step flow: Speak + Snap (draft from uploads) -> AI Builds It -> You Approve (one tap) -> Goes Live."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from ai.pricing import parse_spoken_price
from workers.jobs import build_product, ondc_sync
from workers.queue import enqueue

from .. import audit
from ..db import get_db
from ..domain import pricing_service, publishing
from ..domain.media import completed_upload
from ..models import Artisan, Product, ProductMedia, SyncJob, User
from ..schemas import AnswerIn, DraftCreate, PriceAdjust, ProductEdit
from ..security import acting_artisan, current_user, operator_for, require_roles
from ..serializers import product_full

router = APIRouter(prefix="/products", tags=["products"])


def _own(db: Session, product_id: str, artisan: Artisan) -> Product:
    p = db.get(Product, product_id)
    if not p or p.artisan_id != artisan.id:
        raise HTTPException(404, "product not found")
    return p


@router.post("/drafts")
def create_draft(body: DraftCreate, user: User = Depends(require_roles("artisan", "operator")),
                 artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    """Create a listing from one spoken description + photo(s). Idempotent per device capture."""
    existing = db.execute(select(Product).where(Product.idempotency_key == body.idempotency_key)).scalar_one_or_none()
    if existing:
        return product_full(db, existing)
    if not body.audio_upload_id and not body.device_transcript and not body.photo_upload_ids:
        raise HTTPException(400, "need at least a voice description or a photo")
    op = operator_for(user, db)
    p = Product(artisan_id=artisan.id, status="queued", language=body.language, idempotency_key=body.idempotency_key,
                created_via="kiosk" if op else "app", operator_id=op.id if op else None,
                captured_offline_at=body.captured_offline_at, device_edited_fields=body.edits or {},
                attributes={"device_transcript": body.device_transcript,
                            "answers": [a.model_dump() for a in body.answers]})
    db.add(p)
    db.flush()
    if body.audio_upload_id:
        up = completed_upload(db, body.audio_upload_id, user, "audio")
        db.add(ProductMedia(product_id=p.id, kind="audio", url=up.storage_key, sha256=up.sha256))
    for i, pid in enumerate(body.photo_upload_ids):
        up = completed_upload(db, pid, user, "photo")
        db.add(ProductMedia(product_id=p.id, kind="original", url=up.storage_key, sha256=up.sha256, position=i))
    answers = []
    for a in body.answers:
        d = a.model_dump()
        if a.upload_id:
            d["media_key"] = completed_upload(db, a.upload_id, user, "audio").storage_key
        answers.append(d)
    p.attributes = {**p.attributes, "answers": answers}
    db.add(SyncJob(device_id=body.device_id, idempotency_key=body.idempotency_key, result_ref=p.id,
                   status="processing"))
    audit.record(db, "product.captured", "product", p.id, {"via": p.created_via, "offline": bool(body.captured_offline_at)},
                 user.id)
    db.commit()
    enqueue(build_product, p.id)
    db.refresh(p)
    return product_full(db, p)


@router.get("/mine")
def my_products(lang: str | None = None, artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    rows = db.execute(select(Product).where(Product.artisan_id == artisan.id).order_by(Product.created_at.desc())).scalars().all()
    return [product_full(db, p, lang) for p in rows]


@router.get("/{product_id}")
def get_product(product_id: str, lang: str | None = None, artisan: Artisan = Depends(acting_artisan),
                db: Session = Depends(get_db)):
    return product_full(db, _own(db, product_id, artisan), lang)


@router.get("/{product_id}/build")
def build_status(product_id: str, artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    p = _own(db, product_id, artisan)
    return {"status": p.status, "pipeline": p.pipeline, "needs_review_fields": p.needs_review_fields}


@router.post("/{product_id}/answers")
def add_answers(product_id: str, answers: list[AnswerIn], user: User = Depends(current_user),
                artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    """Voice answers to the AI's follow-up questions ('What is it made of?' ...). Re-runs extraction + price."""
    p = _own(db, product_id, artisan)
    stored = list((p.attributes or {}).get("answers", []))
    for a in answers:
        d = a.model_dump()
        if a.upload_id:
            d["media_key"] = completed_upload(db, a.upload_id, user, "audio").storage_key
        stored = [s for s in stored if s["field"] != a.field] + [d]
    p.attributes = {**(p.attributes or {}), "answers": stored}
    p.status = "processing"
    db.commit()
    enqueue(build_product, p.id, ["asr", "nlu", "listing", "translation", "price", "certificate"])
    return {"status": "processing"}


@router.patch("/{product_id}")
def edit_product(product_id: str, body: ProductEdit, artisan: Artisan = Depends(acting_artisan),
                 db: Session = Depends(get_db)):
    """Artisan edits (from the device). Device wins for these fields on later AI re-runs."""
    p = _own(db, product_id, artisan)
    edits = body.model_dump(exclude_none=True)
    for k, v in edits.items():
        setattr(p, k, v)
    p.device_edited_fields = {**(p.device_edited_fields or {}), **{k: v for k, v in edits.items() if k != "quantity"}}
    p.needs_review_fields = [f for f in p.needs_review_fields if f not in edits]
    db.commit()
    return product_full(db, p)


@router.post("/{product_id}/price")
def change_price(product_id: str, body: PriceAdjust, artisan: Artisan = Depends(acting_artisan),
                 db: Session = Depends(get_db)):
    """'Change price' by voice ('make it 1,600') or number. The breakdown shows exactly what moves."""
    p = _own(db, product_id, artisan)
    price = body.price or (parse_spoken_price(body.spoken) if body.spoken else None)
    if not price:
        raise HTTPException(422, "could not understand a price")
    q = pricing_service.adjust_price(db, p, price)
    db.commit()
    return pricing_service.as_dict(q)


@router.post("/{product_id}/retake")
def retake_photo(product_id: str, photo_upload_ids: list[str], user: User = Depends(current_user),
                 artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    p = _own(db, product_id, artisan)
    for m in list(p.media):
        if m.kind in ("original", "enhanced", "enhanced_4x5", "thumb"):
            db.delete(m)
    for i, uid_ in enumerate(photo_upload_ids):
        up = completed_upload(db, uid_, user, "photo")
        db.add(ProductMedia(product_id=p.id, kind="original", url=up.storage_key, sha256=up.sha256, position=i))
    p.needs_review_fields = [f for f in p.needs_review_fields if f != "photo"]
    p.status = "processing"
    db.commit()
    enqueue(build_product, p.id, ["image", "certificate"])
    return {"status": "processing"}


@router.post("/{product_id}/rerecord")
def rerecord(product_id: str, audio_upload_id: str | None = None, device_transcript: str | None = None,
             user: User = Depends(current_user), artisan: Artisan = Depends(acting_artisan),
             db: Session = Depends(get_db)):
    p = _own(db, product_id, artisan)
    for m in list(p.media):
        if m.kind == "audio":
            db.delete(m)
    if audio_upload_id:
        up = completed_upload(db, audio_upload_id, user, "audio")
        db.add(ProductMedia(product_id=p.id, kind="audio", url=up.storage_key, sha256=up.sha256))
    p.attributes = {**(p.attributes or {}), "device_transcript": device_transcript}
    p.device_edited_fields = {}
    p.status = "processing"
    db.commit()
    enqueue(build_product, p.id, ["asr", "nlu", "listing", "translation", "price", "certificate"])
    return {"status": "processing"}


@router.post("/{product_id}/approve")
def approve(product_id: str, user: User = Depends(current_user), artisan: Artisan = Depends(acting_artisan),
            db: Session = Depends(get_db)):
    """Step 4, one tap: publish to the storefront, issue the signed certificate, queue ONDC catalog sync."""
    p = _own(db, product_id, artisan)
    if p.status in ("queued", "processing"):
        raise HTTPException(409, "still building — please wait")
    if p.status == "live":
        return product_full(db, p)
    if not pricing_service.current_quote(db, p.id):
        pricing_service.quote_product(db, p, artisan)
    publishing.publish(db, p, user.id)
    db.commit()
    enqueue(ondc_sync, p.id)
    db.refresh(p)
    return product_full(db, p)


@router.post("/{product_id}/unpublish")
def unpublish(product_id: str, user: User = Depends(current_user), artisan: Artisan = Depends(acting_artisan),
              db: Session = Depends(get_db)):
    p = _own(db, product_id, artisan)
    publishing.unpublish(db, p, "artisan unpublished", user.id)
    db.commit()
    enqueue(ondc_sync, p.id)
    return {"status": p.status}
