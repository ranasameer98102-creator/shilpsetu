"""Order lifecycle, notifications to artisans, and the per-artisan payout ledger ('every rupee explained').

The listed price already includes shipping & packing (shown in the price breakdown), so buyers see one price
and the artisan's net = price - platform fee - logistics = the 'goes to the artisan' amount shown at listing.
"""
from __future__ import annotations

from collections import defaultdict

from fastapi import HTTPException
from sqlalchemy.orm import Session

from api import audit, runtime_settings
from api.models import Event, LedgerEntry, Order, OrderItem, Payment, Payout, PriceQuote, Product, now

from . import pricing_service
from .logistics import get_logistics
from .payments import get_payments

TRANSITIONS = {
    "placed": {"accepted", "declined", "cancelled"},
    "accepted": {"packed", "cancelled"},
    "packed": {"shipped", "cancelled"},
    "shipped": {"delivered"},
    "delivered": {"returned"},
    "declined": set(),
    "cancelled": set(),
    "returned": set(),
}


def _history(order: Order, status: str, actor: str | None, note: str | None = None) -> None:
    order.history = [*(order.history or []), {"status": status, "at": now().isoformat(), "by": actor, "note": note}]


def create_order(db: Session, buyer_id: str | None, lines: list[tuple[str, int]], address: dict,
                 payment_method: str = "upi", channel: str = "app", ondc_transaction_id: str | None = None,
                 prepaid_externally: bool = False) -> tuple[Order, dict | None]:
    if not lines:
        raise HTTPException(400, "cart is empty")
    order = Order(buyer_id=buyer_id, channel=channel, ondc_transaction_id=ondc_transaction_id, address=address,
                  payment_method=payment_method, status="placed")
    subtotal, max_days = 0.0, 0
    logistics = get_logistics()
    for product_id, qty in lines:
        p = db.get(Product, product_id, with_for_update=True)  # no overselling when two buyers race
        if not p or p.status != "live":
            raise HTTPException(409, f"product {product_id} is not available")
        if qty < 1 or p.quantity < qty:
            raise HTTPException(409, f"only {p.quantity} left of '{p.title}'")
        q = pricing_service.current_quote(db, p.id)
        p.quantity -= qty
        order.items.append(OrderItem(product_id=p.id, artisan_id=p.artisan_id, quantity=qty, unit_price=p.price,
                                     price_quote_id=q.id if q else None))
        subtotal += p.price * qty
        ex = (p.attributes or {}).get("extraction", {})
        max_days = max(max_days, logistics.quote(p.category or "Other", ex.get("weight_g"), p.artisan.state,
                                                 address.get("state"))["days"])
        db.add(Event(type="order", product_id=p.id, buyer_id=buyer_id, meta={"qty": qty, "price": p.price,
                                                                            "channel": channel}))
    order.subtotal = subtotal
    order.logistics_fee = 0.0  # included in item prices (see price breakdown)
    order.total = subtotal
    order.delivery_estimate_days = max_days + 2  # + artisan packing time
    _history(order, "placed", buyer_id, channel)
    db.add(order)
    db.flush()

    checkout = None
    provider = runtime_settings.provider(db, "payment")
    if prepaid_externally:
        db.add(Payment(order_id=order.id, provider="ondc", amount=order.total, status="paid"))
    elif payment_method == "cod":
        db.add(Payment(order_id=order.id, provider="cod", amount=order.total, status="cod_pending"))
    else:
        gw = get_payments(provider)
        po = gw.create_order(order.total, order.id)
        db.add(Payment(order_id=order.id, provider=gw.name, provider_order_id=po["id"], amount=order.total,
                       status="created"))
        checkout = po
    audit.record(db, "order.placed", "order", order.id, {"total": order.total, "channel": channel}, buyer_id)
    notify_artisans_new_order(db, order)
    db.flush()
    return order, checkout


def notify_artisans_new_order(db: Session, order: Order) -> None:
    from notify import service as notify

    city = order.address.get("city") or order.address.get("state") or "a buyer"
    for item in order.items:
        p = db.get(Product, item.product_id)
        q = pricing_service.current_quote(db, p.id)
        share = (q.artisan_share_amount if q else p.price) * item.quantity
        params = {"buyer_city": city, "title": p.short_title or p.title, "qty": item.quantity,
                  "amount": f"{item.unit_price * item.quantity:,.0f}", "share": f"{share:,.0f}"}
        notify.send(db, p.artisan.user, "new_order", params, channels=("sms", "ivr"), ivr_key="order_alert",
                    ivr_params={"title": params["title"], "amount": int(item.unit_price * item.quantity),
                                "share": int(share)},
                    meta={"order_id": order.id})


def transition(db: Session, order: Order, new_status: str, actor_id: str | None, note: str | None = None) -> Order:
    if new_status not in TRANSITIONS.get(order.status, set()):
        raise HTTPException(409, f"cannot move order from {order.status} to {new_status}")
    order.status = new_status
    _history(order, new_status, actor_id, note)
    if new_status == "shipped":
        order.tracking = get_logistics().create_shipment(order.id)
    if new_status in ("declined", "cancelled"):
        for item in order.items:
            db.get(Product, item.product_id).quantity += item.quantity
        for pay in db.query(Payment).filter_by(order_id=order.id).all():
            pay.status = "refund_pending" if pay.status == "paid" else "void"
    if new_status == "delivered":
        for pay in db.query(Payment).filter_by(order_id=order.id, status="cod_pending").all():
            pay.status = "cod_collected"
        settle(db, order)
    if new_status == "returned":
        for item in order.items:
            db.add(Event(type="return", product_id=item.product_id, buyer_id=order.buyer_id, meta={}))
    audit.record(db, f"order.{new_status}", "order", order.id, {"note": note}, actor_id)
    if order.buyer_id:
        from notify import service as notify
        from api.models import User

        notify.send(db, db.get(User, order.buyer_id), "order_status", {"order": order.id[:8], "status": new_status})
    db.flush()
    return order


def settle(db: Session, order: Order) -> list[Payout]:
    """On delivery: ledger entries per artisan (sale, platform fee, logistics) and a payout of the net."""
    from notify import service as notify

    per_artisan: dict[str, dict] = defaultdict(lambda: {"gross": 0.0, "commission": 0.0, "logistics": 0.0})
    for item in order.items:
        q = db.get(PriceQuote, item.price_quote_id) if item.price_quote_id else None
        gross = item.unit_price * item.quantity
        pct = (q.inputs.get("commission_pct") if q else runtime_settings.get(db, "commission_pct")) or 0
        lines = {l["key"]: l["amount"] for l in (q.breakdown or {}).get("lines", [])} if q else {}
        acc = per_artisan[item.artisan_id]
        acc["gross"] += gross
        acc["commission"] += round(gross * pct / 100, 2)
        acc["logistics"] += lines.get("logistics", 0) * item.quantity
    payouts = []
    for artisan_id, acc in per_artisan.items():
        net = round(acc["gross"] - acc["commission"] - acc["logistics"], 2)
        payout = Payout(artisan_id=artisan_id, order_id=order.id, gross=acc["gross"], commission=acc["commission"],
                        logistics=acc["logistics"], net=net, status="paid")
        db.add(payout)
        db.flush()
        ref = order.id[:8]
        db.add_all([
            LedgerEntry(artisan_id=artisan_id, order_id=order.id, kind="sale", amount=acc["gross"],
                        memo=f"Sale, order {ref}"),
            LedgerEntry(artisan_id=artisan_id, order_id=order.id, kind="commission", amount=-acc["commission"],
                        memo="ShilpSetu platform fee"),
            LedgerEntry(artisan_id=artisan_id, order_id=order.id, kind="logistics", amount=-acc["logistics"],
                        memo="Shipping & packing"),
            LedgerEntry(artisan_id=artisan_id, order_id=order.id, payout_id=payout.id, kind="payout", amount=-net,
                        memo="Transferred to your bank / UPI"),
        ])
        from api.models import Artisan

        a = db.get(Artisan, artisan_id)
        notify.send(db, a.user, "payout", {"net": f"{net:,.0f}", "order": ref, "gross": f"{acc['gross']:,.0f}",
                                           "commission": f"{acc['commission']:,.0f}",
                                           "logistics": f"{acc['logistics']:,.0f}"})
        payouts.append(payout)
    return payouts
