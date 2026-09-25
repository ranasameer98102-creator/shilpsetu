"""SMS / IVR webhooks: missed-call helpdesk menu, order accept/decline by key press or SMS reply."""
import base64
import hashlib
import hmac

from fastapi import APIRouter, Depends, Form, HTTPException, Request
from fastapi.responses import Response
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.orm import Session

from notify import service as notify
from notify import templates as T
from notify.providers import twiml

from ..crypto import lookup_hash
from ..db import get_db
from ..domain import orders as O
from ..models import Artisan, HelpdeskCallback, Order, OrderItem, User
from .. import runtime_settings
from ..config import get_settings
from ..security import current_user, require_roles
from .auth import normalize_phone

router = APIRouter(prefix="/notify", tags=["notify"])


async def verify_webhook(request: Request, db: Session = Depends(get_db)) -> None:
    """Telephony webhooks must come from the provider: a valid Twilio request signature, or the shared webhook
    token (`?token=`, for Exotel and others). Mock mode accepts local calls so the demo works without a phone line."""
    provider = runtime_settings.provider(db, "ivr" if "/ivr/" in request.url.path else "sms")
    if provider == "mock":
        return
    s = get_settings()
    if provider == "twilio" and s.twilio_auth_token:
        form = await request.form()
        payload = str(request.url) + "".join(f"{k}{form[k]}" for k in sorted(form.keys()))
        digest = hmac.new(s.twilio_auth_token.encode(), payload.encode(), hashlib.sha1).digest()
        if hmac.compare_digest(base64.b64encode(digest).decode(), request.headers.get("X-Twilio-Signature", "")):
            return
    if s.webhook_token and hmac.compare_digest(request.query_params.get("token", ""), s.webhook_token):
        return
    raise HTTPException(403, "webhook signature invalid")


def _as_twiml(result: dict, action: str) -> Response:
    xml = twiml(result["prompts"], result["language"], action if result.get("gather") else None)
    return Response(xml, media_type="application/xml")


@router.post("/ivr/incoming", dependencies=[Depends(verify_webhook)])
async def ivr_incoming(request: Request, db: Session = Depends(get_db)):
    """Telephony webhook (Twilio/Exotel form-encoded). `digits_so_far` travels in the callback URL."""
    form = await request.form()
    phone = normalize_phone(str(form.get("From", "")))
    so_far = request.query_params.get("d", "") + str(form.get("Digits", "") or "")
    result = notify.ivr_session(db, lookup_hash(phone), so_far)
    db.commit()
    nxt = "" if result.get("reset") else so_far
    return _as_twiml(result, f"/api/v1/notify/ivr/incoming?d={nxt}")


class IvrSimulate(BaseModel):
    phone: str
    digits: str = ""


@router.post("/ivr/simulate", dependencies=[Depends(require_roles("admin"))])
def ivr_simulate(body: IvrSimulate, db: Session = Depends(get_db)):
    """Admin / demo: walk the IVR menu without a phone line (e.g. digits='12' = Hindi, hear earnings)."""
    steps, transcript = "", []
    for i in range(len(body.digits) + 1):
        steps = body.digits[:i]
        r = notify.ivr_session(db, lookup_hash(normalize_phone(body.phone)), steps)
        transcript.append({"pressed": steps[-1] if steps else None, "language": r["language"], "prompts": r["prompts"]})
        if r["done"]:
            break
    db.commit()
    return {"transcript": transcript}


def _respond_to_order(db: Session, order_id: str, digit: str, actor: str) -> str:
    o = db.get(Order, order_id)
    if not o or o.status != "placed":
        return "invalid"
    O.transition(db, o, "accepted" if digit == "1" else "declined", actor, "via IVR/SMS")
    return "accepted" if digit == "1" else "declined"


@router.post("/ivr/order-response", dependencies=[Depends(verify_webhook)])
async def ivr_order_response(request: Request, order_id: str, lang: str = "hi", db: Session = Depends(get_db)):
    form = await request.form()
    digit = str(form.get("Digits", ""))
    outcome = _respond_to_order(db, order_id, digit, "ivr") if digit in ("1", "2") else "invalid"
    db.commit()
    return Response(twiml([T.ivr(outcome, lang)], lang), media_type="application/xml")


@router.post("/sms/incoming", dependencies=[Depends(verify_webhook)])
def sms_incoming(From: str = Form(...), Body: str = Form(...), db: Session = Depends(get_db)):
    """Artisan replies '1' / '2' to the new-order SMS to accept / decline their most recent pending order."""
    user = db.execute(select(User).where(User.phone_hash == lookup_hash(normalize_phone(From)))).scalar_one_or_none()
    artisan = db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one_or_none() if user else None
    digit = Body.strip()[:1]
    if not artisan or digit not in ("1", "2"):
        return {"ok": False}
    o = db.execute(select(Order).join(OrderItem, OrderItem.order_id == Order.id)
                   .where(OrderItem.artisan_id == artisan.id, Order.status == "placed")
                   .order_by(Order.created_at.desc()).limit(1)).scalar_one_or_none()
    outcome = _respond_to_order(db, o.id, digit, user.id) if o else "invalid"
    db.commit()
    return {"ok": outcome != "invalid", "outcome": outcome}


@router.post("/callback")
def request_callback(user: User = Depends(current_user), db: Session = Depends(get_db)):
    """In-app 'ask a helper to call me' — same helpdesk queue as IVR menu option 3."""
    db.add(HelpdeskCallback(user_id=user.id, language=user.language, reason="In-app callback request"))
    db.commit()
    return {"requested": True}
