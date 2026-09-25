import hashlib
import logging
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .. import runtime_settings
from ..config import get_settings
from ..crypto import lookup_hash
from ..db import get_db
from ..models import Artisan, OtpChallenge, User
from ..schemas import OtpRequest, OtpRequested, OtpVerify, TokenOut
from ..security import create_token, current_user

router = APIRouter(prefix="/auth", tags=["auth"])
log = logging.getLogger("shilpsetu")

OTP_TTL = 600
OTP_MAX_PER_WINDOW = 5  # codes per phone number per 15 minutes


def normalize_phone(phone: str) -> str:
    digits = "".join(c for c in phone if c.isdigit())
    return "+91" + digits[-10:] if len(digits) >= 10 else phone


def _hash_code(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()


@router.post("/otp/request", response_model=OtpRequested)
def request_otp(body: OtpRequest, db: Session = Depends(get_db)):
    from notify import templates
    from notify.providers import get_gateway

    phone = normalize_phone(body.phone)
    window_start = datetime.now(timezone.utc) + timedelta(seconds=OTP_TTL) - timedelta(minutes=15)
    recent = db.execute(select(func.count()).select_from(OtpChallenge).where(
        OtpChallenge.phone_hash == lookup_hash(phone), OtpChallenge.expires_at > window_start)).scalar_one()
    if recent >= OTP_MAX_PER_WINDOW:
        raise HTTPException(429, "too many codes requested - please wait 15 minutes")
    code = f"{secrets.randbelow(1_000_000):06d}"
    ch = OtpChallenge(phone_hash=lookup_hash(phone), code_hash=_hash_code(code),
                      expires_at=datetime.now(timezone.utc) + timedelta(seconds=OTP_TTL))
    db.add(ch)
    provider = runtime_settings.provider(db, "sms")
    # Android SMS Retriever needs the app hash at the end of the message for OTP auto-read.
    get_gateway(provider).send_sms(phone, templates.sms("otp", body.language, code=code) + "\nShilpSetu/aB3xY7kLm9Q")
    db.commit()
    dev_otp = code if provider == "mock" else None
    if dev_otp and not get_settings().show_admin_otp:
        u = db.execute(select(User).where(User.phone_hash == lookup_hash(phone))).scalar_one_or_none()
        if u and u.role == "admin":  # public demo: admin codes only reach whoever can read the server log
            log.warning("admin OTP for ...%s: %s", phone[-4:], code)
            dev_otp = None
    return OtpRequested(challenge_id=ch.id, expires_in=OTP_TTL, dev_otp=dev_otp)


@router.post("/otp/verify", response_model=TokenOut)
def verify_otp(body: OtpVerify, db: Session = Depends(get_db)):
    phone = normalize_phone(body.phone)
    ph = lookup_hash(phone)
    ch = db.execute(select(OtpChallenge).where(OtpChallenge.phone_hash == ph, OtpChallenge.used.is_(False))
                    .order_by(OtpChallenge.expires_at.desc()).limit(1)).scalar_one_or_none()
    if not ch:
        raise HTTPException(400, "request a new code")
    exp = ch.expires_at if ch.expires_at.tzinfo else ch.expires_at.replace(tzinfo=timezone.utc)
    if exp < datetime.now(timezone.utc) or ch.attempts >= 5:
        raise HTTPException(400, "code expired, request a new one")
    ch.attempts += 1
    if not secrets.compare_digest(ch.code_hash, _hash_code(body.code)):
        db.commit()
        raise HTTPException(400, "wrong code")
    ch.used = True
    user = db.execute(select(User).where(User.phone_hash == ph, User.deleted_at.is_(None))).scalar_one_or_none()
    if user is None:
        if body.role in ("admin", "operator"):
            raise HTTPException(403, "admins and kiosk operators are registered by an administrator")
        user = User(role=body.role, phone=phone, phone_hash=ph, language=body.language or "hi")
        db.add(user)
        db.flush()
    elif body.language:
        user.language = body.language
    has_profile = db.execute(select(Artisan.id).where(Artisan.user_id == user.id)).first() is not None \
        if user.role == "artisan" else True
    db.commit()
    return TokenOut(access_token=create_token(user), user_id=user.id, role=user.role, has_profile=has_profile)


@router.get("/me")
def me(user: User = Depends(current_user)):
    return {"id": user.id, "role": user.role, "language": user.language, "display_name": user.display_name}


@router.patch("/me")
def update_me(body: dict, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if "language" in body:
        user.language = body["language"]
    if "display_name" in body:
        user.display_name = body["display_name"]
    db.merge(user)
    db.commit()
    return {"ok": True}
