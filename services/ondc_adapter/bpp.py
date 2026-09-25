"""Seller Network Participant (BPP) endpoints: search, select, init, confirm, status, cancel.

Beckn is asynchronous: each call is ACKed immediately and the result is POSTed to the buyer app's
`bap_uri` as on_search / on_select / ... . In mock mode the callback is delivered in-process to the
mock BAP (see mock_gateway.py) so the whole ONDC round-trip can be demoed with no registration.
"""
from __future__ import annotations

import json
import logging
import uuid
from datetime import datetime, timezone

import httpx
from fastapi import APIRouter, BackgroundTasks, Depends, Header, HTTPException, Request
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from api import runtime_settings
from api.config import get_settings
from api.db import get_db, session_factory
from api.models import OndcSync, Order, Product, now

from . import catalog, signing

log = logging.getLogger(__name__)
router = APIRouter(prefix="/ondc", tags=["ondc"])

ACK = {"message": {"ack": {"status": "ACK"}}}
NACK = lambda code, msg: {"message": {"ack": {"status": "NACK"}}, "error": {"type": "DOMAIN-ERROR", "code": code, "message": msg}}  # noqa: E731

STATE = {"placed": "Created", "accepted": "Accepted", "packed": "In-progress", "shipped": "In-progress",
         "delivered": "Completed", "declined": "Cancelled", "cancelled": "Cancelled", "returned": "Completed"}
FULFILMENT_STATE = {"placed": "Pending", "accepted": "Pending", "packed": "Packed", "shipped": "Order-picked-up",
                    "delivered": "Order-delivered", "declined": "Cancelled", "cancelled": "Cancelled",
                    "returned": "Order-delivered"}


def _context(ctx: dict, action: str) -> dict:
    s = get_settings()
    return {**ctx, "action": action, "bpp_id": s.ondc_subscriber_id, "bpp_uri": s.ondc_subscriber_uri,
            "message_id": ctx.get("message_id") or uuid.uuid4().hex,
            "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")}


def deliver(action: str, payload: dict) -> None:
    """POST the callback to the BAP. Mock BAP URIs are dispatched in-process."""
    bap_uri = payload["context"].get("bap_uri", "")
    if "/ondc-mock/bap" in bap_uri:
        from . import mock_gateway

        mock_gateway.receive(action, payload)
        return
    body = json.dumps(payload).encode()
    try:
        httpx.post(bap_uri.rstrip("/") + f"/{action}", content=body, timeout=15,
                   headers={"Content-Type": "application/json", "Authorization": signing.auth_header(body)})
    except httpx.HTTPError as e:
        log.warning("ONDC callback %s to %s failed: %s", action, bap_uri, e)


def _verify(request_body: bytes, authorization: str | None) -> None:
    if get_settings().ondc_mode == "mock":
        return
    # Production: look up the BAP's public key in the ONDC registry by keyId and verify.
    # The sandbox registry lookup is left to deployment configuration; reject unsigned calls.
    if not authorization:
        raise HTTPException(401, "missing Beckn Authorization signature")


def _run(fn, *args):
    db = session_factory()()
    try:
        fn(db, *args)
        db.commit()
    except Exception:
        log.exception("ONDC handler failed")
        db.rollback()
    finally:
        db.close()


# ------------------------------------------------------------------ handlers

def handle_search(db: Session, body: dict) -> dict:
    intent = body.get("message", {}).get("intent", {})
    term = ((intent.get("item") or {}).get("descriptor") or {}).get("name", "")
    stmt = select(Product).where(Product.status == "live")
    if term:
        like = f"%{term}%"
        stmt = stmt.where(or_(Product.title.ilike(like), Product.description.ilike(like), Product.category.ilike(like)))
    products = db.execute(stmt.limit(50)).scalars().all()
    return {"context": _context(body["context"], "on_search"), "message": {"catalog": catalog.catalog(db, products)}}


def _quote(db: Session, items: list[dict]) -> tuple[list[dict], dict, list[str]]:
    breakup, total, errors, out_items = [], 0.0, [], []
    for it in items:
        p = db.get(Product, it["id"])
        qty = int(((it.get("quantity") or {}).get("count")) or 1)
        if not p or p.status != "live" or p.quantity < qty:
            errors.append(it["id"])
            continue
        line = p.price * qty
        total += line
        out_items.append({"id": p.id, "fulfillment_id": "F1", "quantity": {"count": qty}})
        breakup.append({"@ondc/org/item_id": p.id, "@ondc/org/item_quantity": {"count": qty}, "title": p.title,
                        "@ondc/org/title_type": "item", "price": {"currency": "INR", "value": f"{line:.2f}"}})
    breakup.append({"@ondc/org/item_id": "F1", "title": "Delivery charges", "@ondc/org/title_type": "delivery",
                    "price": {"currency": "INR", "value": "0.00"}})
    return out_items, {"price": {"currency": "INR", "value": f"{total:.2f}"}, "breakup": breakup, "ttl": "P1D"}, errors


def handle_select(db: Session, body: dict) -> dict:
    order = body["message"]["order"]
    items, quote, errors = _quote(db, order.get("items", []))
    resp = {"context": _context(body["context"], "on_select"),
            "message": {"order": {"provider": order.get("provider"), "items": items, "quote": quote,
                                  "fulfillments": [{"id": "F1", "type": "Delivery", "@ondc/org/category": "Standard Delivery",
                                                    "@ondc/org/TAT": "P6D", "state": {"descriptor": {"code": "Serviceable"}}}]}}}
    if errors:
        resp["error"] = {"type": "DOMAIN-ERROR", "code": "40002", "message": f"items unavailable: {errors}"}
    return resp


def handle_init(db: Session, body: dict) -> dict:
    order = body["message"]["order"]
    items, quote, _ = _quote(db, order.get("items", []))
    return {"context": _context(body["context"], "on_init"),
            "message": {"order": {**order, "items": items, "quote": quote,
                                  "payment": {**(order.get("payment") or {}), "@ondc/org/settlement_basis": "delivery",
                                              "@ondc/org/settlement_window": "P1D",
                                              "@ondc/org/buyer_app_finder_fee_type": "percent",
                                              "@ondc/org/buyer_app_finder_fee_amount": "3"}}}}


def handle_confirm(db: Session, body: dict) -> dict:
    from api.domain.orders import create_order

    ctx = body["context"]
    o = body["message"]["order"]
    existing = db.execute(select(Order).where(Order.ondc_transaction_id == ctx["transaction_id"])).scalar_one_or_none()
    if existing is None:
        end = ((o.get("fulfillments") or [{}])[0].get("end") or {})
        loc = end.get("location", {}).get("address", {})
        address = {"name": (end.get("contact") or {}).get("name") or loc.get("name"), "line1": loc.get("building", ""),
                   "city": loc.get("city", ""), "state": loc.get("state", ""), "pincode": loc.get("area_code", ""),
                   "phone": (end.get("contact") or {}).get("phone")}
        paid = (o.get("payment") or {}).get("status") == "PAID"
        lines = [(it["id"], int(((it.get("quantity") or {}).get("count")) or 1)) for it in o.get("items", [])]
        existing, _ = create_order(db, None, lines, address, payment_method="upi" if paid else "cod",
                                   channel="ondc", ondc_transaction_id=ctx["transaction_id"], prepaid_externally=paid)
    return {"context": _context(ctx, "on_confirm"), "message": {"order": _order_view(existing, o)}}


def _order_view(order: Order, src: dict | None = None) -> dict:
    return {
        "id": order.id, "state": STATE[order.status],
        "provider": (src or {}).get("provider") or {"id": order.items[0].artisan_id if order.items else ""},
        "items": [{"id": i.product_id, "quantity": {"count": i.quantity}, "fulfillment_id": "F1"} for i in order.items],
        "quote": {"price": {"currency": "INR", "value": f"{order.total:.2f}"}},
        "fulfillments": [{"id": "F1", "type": "Delivery", "state": {"descriptor": {"code": FULFILMENT_STATE[order.status]}},
                          "tracking": bool(order.tracking), "@ondc/org/tracking_url": (order.tracking or {}).get("tracking_url")}],
        "created_at": order.created_at.isoformat(), "updated_at": now().isoformat(),
    }


def handle_status(db: Session, body: dict) -> dict:
    oid = body["message"].get("order_id")
    order = db.get(Order, oid) or db.execute(select(Order).where(
        Order.ondc_transaction_id == body["context"]["transaction_id"])).scalar_one_or_none()
    if not order:
        return {"context": _context(body["context"], "on_status"), **NACK("40004", "order not found")}
    return {"context": _context(body["context"], "on_status"), "message": {"order": _order_view(order)}}


def handle_cancel(db: Session, body: dict) -> dict:
    from api.domain.orders import transition

    order = db.get(Order, body["message"].get("order_id"))
    if order and order.status in ("placed", "accepted", "packed"):
        transition(db, order, "cancelled", None, f"ONDC cancel: {body['message'].get('cancellation_reason_id')}")
    return {"context": _context(body["context"], "on_cancel"),
            "message": {"order": _order_view(order) if order else {}}}


HANDLERS = {"search": handle_search, "select": handle_select, "init": handle_init, "confirm": handle_confirm,
            "status": handle_status, "cancel": handle_cancel}


def process(db: Session, action: str, body: dict) -> dict:
    """Run a handler and deliver the on_* callback. Used by the HTTP endpoints and the mock gateway."""
    result = HANDLERS[action](db, body)
    db.flush()
    deliver(f"on_{action}", result)
    return result


@router.post("/{action}")
async def beckn_endpoint(action: str, request: Request, background: BackgroundTasks,
                         authorization: str | None = Header(default=None)):
    if action not in HANDLERS:
        raise HTTPException(404, "unsupported Beckn action")
    raw = await request.body()
    _verify(raw, authorization)
    body = json.loads(raw)
    if not body.get("context", {}).get("transaction_id"):
        return NACK("10000", "context.transaction_id required")
    background.add_task(_run, process, action, body)
    return ACK


# ------------------------------------------------------------------ catalog sync

def sync_product(db: Session, product: Product) -> OndcSync:
    """Push an incremental catalog update for one listing (zero quantity when unpublished)."""
    sync = db.query(OndcSync).filter_by(product_id=product.id).one_or_none() or OndcSync(product_id=product.id)
    db.add(sync)
    sync.attempts = (sync.attempts or 0) + 1
    payload = catalog.catalog(db, [product])
    sync.last_payload = payload
    mode = runtime_settings.provider(db, "ondc")
    try:
        if mode != "mock":
            s = get_settings()
            body = json.dumps({"context": {"domain": s.ondc_domain, "action": "on_search", "city": s.ondc_city,
                                           "core_version": "1.2.0", "bpp_id": s.ondc_subscriber_id,
                                           "bpp_uri": s.ondc_subscriber_uri, "transaction_id": uuid.uuid4().hex,
                                           "message_id": uuid.uuid4().hex,
                                           "timestamp": datetime.now(timezone.utc).isoformat()},
                               "message": {"catalog": payload}}).encode()
            r = httpx.post(s.ondc_gateway_url.rstrip("/") + "/on_search", content=body, timeout=20,
                           headers={"Content-Type": "application/json", "Authorization": signing.auth_header(body)})
            r.raise_for_status()
        else:
            from . import mock_gateway

            mock_gateway.index_catalog(payload)
        sync.status = "removed" if product.status != "live" else "synced"
        sync.last_error = None
    except Exception as e:
        sync.status = "failed"
        sync.last_error = str(e)[:500]
    db.flush()
    return sync
