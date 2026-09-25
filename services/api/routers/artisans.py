import re
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from ai import speech
from ai.lexicon import PLACES, STATES
from ai.nlu import _parse_numbers, _tokens

from .. import audit, runtime_settings
from ..db import get_db
from ..domain.media import completed_upload
from ..models import Artisan, LedgerEntry, Order, OrderItem, Payout, Product, Upload, User, now
from ..schemas import ArtisanProfileIn, ArtisanVoiceProfileIn
from ..security import acting_artisan, current_user, require_roles
from ..serializers import artisan_public, product_card
from ..storage import get_storage, media_url

router = APIRouter(prefix="/artisans", tags=["artisans"])


def apply_profile(db: Session, a: Artisan, body: ArtisanProfileIn, user: User) -> Artisan:
    for f in ("name", "name_native", "village", "district", "state", "craft_type", "years_practice", "story_text",
              "shg_name", "csc_id", "cluster", "gi_tag", "gender"):
        v = getattr(body, f)
        if v is not None:
            setattr(a, f, v)
    if body.pehchan_id:
        a.pehchan_id = re.sub(r"\D", "", body.pehchan_id) or body.pehchan_id
        a.pehchan_verified = False  # requires admin/API confirmation
    for key_field, attr in (("story_audio_key", "story_audio_url"), ("photo_key", "photo_url")):
        up_id = getattr(body, key_field)
        if up_id:
            setattr(a, attr, completed_upload(db, up_id, user).storage_key)
    a.consent_flags = {**(a.consent_flags or {}), **body.consent.model_dump(exclude_none=True),
                       "recorded_at": now().isoformat()}
    if a.story_text:
        translate_story(db, a, user.language)
    return a


def translate_story(db: Session, a: Artisan, lang: str) -> None:
    provider = runtime_settings.provider(db, "translation")
    out = {lang: {"text": a.story_text, "source": "artisan"}}
    for target in ("en", "hi"):
        if target != lang:
            text, ok = speech.translate(db, provider, a.story_text, lang, target)
            out[target] = {"text": text, "source": provider, "needs_review": not ok}
    a.story_translations = out


@router.get("/me")
def my_profile(artisan: Artisan = Depends(acting_artisan)):
    return {**artisan_public(artisan), "consent_flags": artisan.consent_flags,
            "pehchan_linked": bool(artisan.pehchan_id)}


@router.put("/me")
def upsert_profile(body: ArtisanProfileIn, user: User = Depends(require_roles("artisan")), db: Session = Depends(get_db)):
    a = db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one_or_none()
    if a is None:
        a = Artisan(user_id=user.id, name=body.name)
        db.add(a)
    apply_profile(db, a, body, user)
    user.display_name = a.name
    audit.record(db, "artisan.profile_saved", "artisan", a.id or "new", {"consent": a.consent_flags}, user.id)
    db.commit()
    return artisan_public(a)


def _answer_text(db: Session, user: User, value: str, lang: str) -> tuple[str, str | None]:
    up = db.get(Upload, value)
    if up and up.owner_user_id == user.id and up.status == "complete":
        t = speech.transcribe(db, runtime_settings.provider(db, "asr"), get_storage().get(up.storage_key), lang,
                              up.content_type)
        return t.text, up.storage_key
    return value, None


@router.post("/me/voice-profile")
def voice_profile(body: ArtisanVoiceProfileIn, user: User = Depends(require_roles("artisan")),
                  db: Session = Depends(get_db)):
    """Zero typing: each profile field answered by voice. Story audio is kept as-is and also transcribed."""
    fields, story_audio = {}, None
    for f, v in body.answers.items():
        text, key = _answer_text(db, user, v, body.language)
        fields[f] = text.strip()
        if f == "story":
            story_audio = key
    prof = ArtisanProfileIn(name=fields.get("name") or "Artisan", consent=body.consent)
    prof.name_native = fields.get("name") if body.language != "en" else None
    prof.village = fields.get("village")
    prof.district = fields.get("district")
    state = fields.get("state") or ""
    prof.state = next((s for s in STATES if s.lower() in state.lower()), None) or \
        next((st for place, (_, st) in PLACES.items() if place in (state + " " + (prof.village or "")).lower()), state or None)
    prof.craft_type = fields.get("craft_type")
    nums = _parse_numbers(_tokens(fields.get("years_practice", "")))
    prof.years_practice = int(nums[0][2]) if nums else None
    prof.story_text = fields.get("story")
    if fields.get("pehchan_id"):
        digits = "".join(str(int(v)) for _, _, v in _parse_numbers(_tokens(fields["pehchan_id"])))
        prof.pehchan_id = digits or fields["pehchan_id"]
    a = db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one_or_none()
    if a is None:
        a = Artisan(user_id=user.id, name=prof.name)
        db.add(a)
    apply_profile(db, a, prof, user)
    if story_audio:
        a.story_audio_url = story_audio
    user.display_name = a.name
    db.commit()
    return {**artisan_public(a), "heard": fields}


@router.get("/me/dashboard")
def dashboard(artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    start = datetime.now(timezone.utc).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    counts = dict(db.execute(select(Product.status, func.count()).where(Product.artisan_id == artisan.id)
                             .group_by(Product.status)).all())
    earned = db.execute(select(func.coalesce(func.sum(Payout.net), 0), func.count())
                        .where(Payout.artisan_id == artisan.id, Payout.created_at >= start)).one()
    open_orders = db.execute(select(func.count(func.distinct(Order.id))).join(OrderItem, OrderItem.order_id == Order.id)
                             .where(OrderItem.artisan_id == artisan.id, Order.status.in_(["placed", "accepted", "packed"]))).scalar_one()
    month = int(earned[0])
    return {
        "artisan": artisan_public(artisan), "products_by_status": counts, "open_orders": open_orders,
        "earned_this_month": month, "orders_paid_this_month": earned[1],
        "spoken_summary": {
            "en": f"This month you earned ₹{month:,} from {earned[1]} orders.",
            "hi": f"इस महीने आपने {earned[1]} ऑर्डर से ₹{month:,} कमाए।",
        },
    }


@router.get("/me/ledger")
def ledger(artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    """Payout ledger: gross, platform fee, logistics, net — every rupee explained."""
    entries = db.execute(select(LedgerEntry).where(LedgerEntry.artisan_id == artisan.id)
                         .order_by(LedgerEntry.created_at.desc())).scalars().all()
    payouts = db.execute(select(Payout).where(Payout.artisan_id == artisan.id).order_by(Payout.created_at.desc())).scalars().all()
    tot = {k: sum(e.amount for e in entries if e.kind == k) for k in ("sale", "commission", "logistics", "payout")}
    return {
        "totals": {"gross": tot["sale"], "commission": -tot["commission"], "logistics": -tot["logistics"],
                   "net": tot["sale"] + tot["commission"] + tot["logistics"], "paid_out": -tot["payout"],
                   "share_pct": round(100 * (tot["sale"] + tot["commission"] + tot["logistics"]) / tot["sale"], 1) if tot["sale"] else None},
        "payouts": [{"id": p.id, "order_id": p.order_id, "gross": p.gross, "commission": p.commission,
                     "logistics": p.logistics, "net": p.net, "status": p.status, "at": p.created_at.isoformat()} for p in payouts],
        "entries": [{"kind": e.kind, "amount": e.amount, "memo": e.memo, "order_id": e.order_id,
                     "at": e.created_at.isoformat()} for e in entries],
    }


@router.get("/me/export")
def export_my_data(user: User = Depends(require_roles("artisan")), db: Session = Depends(get_db)):
    """DPDP Act 2023: data principal's right to access — everything we hold about the artisan."""
    a = db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one()
    products = db.execute(select(Product).where(Product.artisan_id == a.id)).scalars().all()
    audit.record(db, "artisan.data_exported", "artisan", a.id, {}, user.id)
    db.commit()
    return {
        "user": {"id": user.id, "phone": user.phone, "language": user.language, "created_at": user.created_at},
        "artisan": {**artisan_public(a), "pehchan_id": a.pehchan_id, "gender": a.gender, "consent_flags": a.consent_flags,
                    "story_audio": media_url(a.story_audio_url)},
        "products": [{"id": p.id, "title": p.title, "status": p.status, "transcript": p.transcript,
                      "media": [media_url(m.url) for m in p.media]} for p in products],
        "ledger": ledger(a, db),
    }


@router.delete("/me")
def delete_my_data(user: User = Depends(require_roles("artisan")), db: Session = Depends(get_db)):
    """DPDP Act 2023: erasure. Media and PII are deleted; financial records are kept anonymised (legal retention)."""
    a = db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one()
    storage = get_storage()
    for p in db.execute(select(Product).where(Product.artisan_id == a.id)).scalars():
        for m in p.media:
            storage.delete(m.url)
        p.status = "unpublished"
        p.transcript = None
        if p.certificate and not p.certificate.revoked_at:
            from ..domain.publishing import revoke_certificate

            revoke_certificate(db, p.certificate, "artisan requested deletion", user.id)
    for key in (a.story_audio_url, a.photo_url):
        if key:
            storage.delete(key)
    a.name, a.name_native, a.village, a.story_text, a.story_audio_url, a.photo_url = "Deleted artisan", None, None, None, None, None
    a.pehchan_id, a.gender, a.story_translations, a.consent_flags = None, None, {}, {"withdrawn_at": now().isoformat()}
    user.phone, user.phone_hash, user.deleted_at, user.display_name = None, None, now(), None
    audit.record(db, "artisan.data_deleted", "artisan", a.id, {}, user.id)
    db.commit()
    return {"deleted": True}


@router.get("/{artisan_id}")
def public_profile(artisan_id: str, db: Session = Depends(get_db)):
    a = db.get(Artisan, artisan_id)
    if not a or a.name == "Deleted artisan":
        raise HTTPException(404, "artisan not found")
    products = db.execute(select(Product).where(Product.artisan_id == a.id, Product.status == "live")).scalars().all()
    return {**artisan_public(a), "products": [product_card(p) for p in products]}
