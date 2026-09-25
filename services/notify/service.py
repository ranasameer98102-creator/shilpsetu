"""Send SMS / IVR notifications and run the helpdesk IVR menu. Every message is stored in `notifications`."""
from __future__ import annotations

import logging
from datetime import datetime, timezone

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from api import runtime_settings
from api.config import get_settings
from api.models import Artisan, HelpdeskCallback, LedgerEntry, Notification, Order, OrderItem, Product, User

from . import templates as T
from .providers import get_gateway

log = logging.getLogger(__name__)


def send(db: Session, user: User | None, template: str, params: dict, channels: tuple[str, ...] = ("sms",),
         ivr_key: str | None = None, ivr_params: dict | None = None, meta: dict | None = None) -> list[Notification]:
    out = []
    if user is None or not user.phone:
        return out
    lang = user.language or "hi"
    for ch in channels:
        provider = runtime_settings.provider(db, "sms" if ch == "sms" else "ivr")
        gw = get_gateway(provider)
        if ch == "sms":
            body = T.sms(template, lang, **params)
        else:
            body = T.ivr(ivr_key or template, lang, **(ivr_params or params))
        n = Notification(user_id=user.id, channel=ch, template=template, language=lang, to=user.phone, body=body,
                         provider=gw.name, meta=meta or {})
        try:
            if ch == "sms":
                n.provider_ref = gw.send_sms(user.phone, body)
            else:
                cb = f"{get_settings().public_base_url}/api/v1/notify/ivr/order-response?" \
                     f"order_id={(meta or {}).get('order_id', '')}&lang={lang}"
                n.provider_ref = gw.place_call(user.phone, [body], lang, cb)
            n.status = "sent"
        except Exception as e:  # never let a gateway failure break the business flow
            log.warning("notify %s via %s failed: %s", ch, gw.name, e)
            n.status = "failed"
            n.meta = {**n.meta, "error": str(e)[:300]}
        db.add(n)
        out.append(n)
    db.flush()
    return out


# ------------------------------------------------------------------ IVR

def _artisan_for_phone(db: Session, phone_hash: str) -> tuple[User | None, Artisan | None]:
    user = db.execute(select(User).where(User.phone_hash == phone_hash)).scalar_one_or_none()
    artisan = db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one_or_none() if user else None
    return user, artisan


def latest_orders(db: Session, artisan_id: str, limit: int = 3) -> list[dict]:
    rows = db.execute(
        select(OrderItem, Order, Product).join(Order, OrderItem.order_id == Order.id)
        .join(Product, OrderItem.product_id == Product.id)
        .where(OrderItem.artisan_id == artisan_id).order_by(Order.created_at.desc()).limit(limit)
    ).all()
    return [{"title": p.short_title or p.title, "qty": oi.quantity, "amount": int(oi.unit_price * oi.quantity),
             "status": o.status, "order_id": o.id} for oi, o, p in rows]


def month_earnings(db: Session, artisan_id: str) -> tuple[float, int]:
    start = datetime.now(timezone.utc).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    total = db.execute(select(func.coalesce(func.sum(LedgerEntry.amount), 0)).where(
        LedgerEntry.artisan_id == artisan_id, LedgerEntry.created_at >= start,
        LedgerEntry.kind.in_(["sale", "commission", "logistics"]))).scalar_one()
    orders = db.execute(select(func.count(func.distinct(LedgerEntry.order_id))).where(
        LedgerEntry.artisan_id == artisan_id, LedgerEntry.created_at >= start, LedgerEntry.kind == "sale")).scalar_one()
    return float(total), int(orders)


def ivr_session(db: Session, phone_hash: str, digits: str) -> dict:
    """Stateless helpdesk IVR. `digits` is everything pressed so far: [language][menu choice].
    Returns prompts to speak, the language, whether to gather another digit, and whether the call ends."""
    user, artisan = _artisan_for_phone(db, phone_hash)
    if not digits:
        lang = user.language if user else "hi"
        return {"language": lang, "prompts": [T.ivr("welcome", lang)], "gather": True, "done": False}
    lang = T.IVR_LANGS.get(digits[0])
    if not lang:
        return {"language": "hi", "prompts": [T.ivr("invalid", "hi"), T.ivr("welcome", "hi")], "gather": True,
                "done": False, "reset": True}
    if user and user.language != lang:
        user.language = lang
    if len(digits) == 1:
        return {"language": lang, "prompts": [T.ivr("menu", lang)], "gather": True, "done": False}
    choice = digits[1]
    if choice == "1":
        orders = latest_orders(db, artisan.id) if artisan else []
        prompts = [T.ivr("order_item", lang, **o) for o in orders] or [T.ivr("no_orders", lang)]
    elif choice == "2":
        amount, n = month_earnings(db, artisan.id) if artisan else (0.0, 0)
        prompts = [T.ivr("earnings", lang, amount=int(amount), orders=n)]
    elif choice == "3":
        db.add(HelpdeskCallback(user_id=user.id if user else None, language=lang, reason="IVR callback request"))
        db.flush()
        prompts = [T.ivr("callback", lang)]
    else:
        return {"language": lang, "prompts": [T.ivr("invalid", lang), T.ivr("menu", lang)], "gather": True,
                "done": False}
    return {"language": lang, "prompts": prompts, "gather": False, "done": True}
