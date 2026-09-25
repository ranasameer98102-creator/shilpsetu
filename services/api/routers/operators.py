"""Assisted kiosk mode: CSC / SHG operators onboard artisans and capture products on their behalf."""
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .. import audit, certs
from ..crypto import lookup_hash
from ..db import get_db
from ..domain.media import completed_upload
from ..models import Artisan, Certificate, Operator, Product, User
from ..schemas import OperatorArtisanCreate
from ..security import require_roles
from ..serializers import artisan_public
from .artisans import apply_profile
from .auth import normalize_phone

router = APIRouter(prefix="/operators", tags=["operators"])


def _operator(user: User, db: Session) -> Operator:
    op = db.execute(select(Operator).where(Operator.user_id == user.id)).scalar_one_or_none()
    if not op:
        op = Operator(user_id=user.id, name=user.display_name)
        db.add(op)
        db.flush()
    return op


@router.get("/me")
def me(user: User = Depends(require_roles("operator")), db: Session = Depends(get_db)):
    op = _operator(user, db)
    db.commit()
    return {"id": op.id, "kind": op.kind, "csc_id": op.csc_id, "shg_id": op.shg_id, "name": op.name, "region": op.region}


@router.patch("/me")
def update_me(body: dict, user: User = Depends(require_roles("operator")), db: Session = Depends(get_db)):
    op = _operator(user, db)
    for f in ("kind", "csc_id", "shg_id", "name", "region"):
        if f in body:
            setattr(op, f, body[f])
    db.commit()
    return {"ok": True}


@router.get("/artisans")
def my_artisans(user: User = Depends(require_roles("operator")), db: Session = Depends(get_db)):
    op = _operator(user, db)
    rows = db.execute(select(Artisan).where(Artisan.onboarded_by_operator_id == op.id).order_by(Artisan.name)).scalars().all()
    counts = dict(db.execute(select(Product.artisan_id, func.count()).where(
        Product.artisan_id.in_([a.id for a in rows])).group_by(Product.artisan_id)).all()) if rows else {}
    return [{**artisan_public(a), "products": counts.get(a.id, 0)} for a in rows]


@router.post("/artisans")
def onboard_artisan(body: OperatorArtisanCreate, user: User = Depends(require_roles("operator")),
                    db: Session = Depends(get_db)):
    """Onboard an artisan who may not own a smartphone. The artisan's spoken consent is recorded on the kiosk."""
    op = _operator(user, db)
    if not body.consent.voice and not body.consent_audio_upload_id:
        raise HTTPException(400, "record the artisan's spoken consent first")
    art_user = None
    if body.phone:
        phone = normalize_phone(body.phone)
        art_user = db.execute(select(User).where(User.phone_hash == lookup_hash(phone))).scalar_one_or_none()
        if art_user is None:
            art_user = User(role="artisan", phone=phone, phone_hash=lookup_hash(phone), language=body.language,
                            display_name=body.name)
            db.add(art_user)
            db.flush()
    a = Artisan(user_id=art_user.id if art_user else None, name=body.name, onboarded_by_operator_id=op.id,
                operator_attestation=body.attestation, csc_id=body.csc_id or op.csc_id)
    db.add(a)
    apply_profile(db, a, body, user)
    if body.consent_audio_upload_id:
        key = completed_upload(db, body.consent_audio_upload_id, user, "audio").storage_key
        a.consent_flags = {**a.consent_flags, "consent_audio_key": key, "captured_by_operator": op.id}
    db.flush()
    audit.record(db, "artisan.onboarded_by_operator", "artisan", a.id, {"operator": op.id}, user.id)
    db.commit()
    return artisan_public(a)


@router.get("/stats")
def stats(user: User = Depends(require_roles("operator")), db: Session = Depends(get_db)):
    op = _operator(user, db)
    artisans = db.execute(select(func.count()).select_from(Artisan).where(Artisan.onboarded_by_operator_id == op.id)).scalar_one()
    by_status = dict(db.execute(select(Product.status, func.count()).where(Product.operator_id == op.id)
                                .group_by(Product.status)).all())
    return {"artisans_onboarded": artisans, "products_captured": sum(by_status.values()), "by_status": by_status}


@router.get("/tags.pdf")
def print_tags(product_ids: str = Query(..., description="comma-separated"), size: str = "label",
               user: User = Depends(require_roles("operator", "admin")), db: Session = Depends(get_db)):
    """Batch-print certificate tags for an exhibition session (one page per item)."""
    ids = [x for x in product_ids.split(",") if x]
    rows = db.execute(select(Certificate).where(Certificate.product_id.in_(ids), Certificate.revoked_at.is_(None))).scalars().all()
    if not rows:
        raise HTTPException(404, "no live certificates for those products")
    return Response(certs.pdf_many(rows, size), media_type="application/pdf",
                    headers={"Content-Disposition": 'inline; filename="shilpsetu-tags.pdf"'})
