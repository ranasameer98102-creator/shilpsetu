"""Cart, checkout, orders (buyer + artisan views), payments, reviews and marketplace events."""
import json

from fastapi import APIRouter, Depends, Header, HTTPException, Request
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .. import runtime_settings
from ..db import get_db
from ..domain import orders as O
from ..domain.logistics import get_logistics
from ..domain.payments import MockPayments, get_payments
from ..models import Artisan, CartItem, Event, Order, OrderItem, Payment, Product, Review, User
from ..schemas import CartLine, CheckoutIn, EventsIn, OrderStatusIn, PaymentConfirm, ReviewIn
from ..config import get_settings
from ..models import Operator
from ..security import acting_artisan, current_user, optional_user, require_roles
from ..serializers import product_card

router = APIRouter(tags=["commerce"])
# Artisans shop too (one phone number = one account); kiosk operators and admins do not.
shopper = require_roles("buyer", "artisan")


# ------------------------------------------------------------------ cart
def _cart(db: Session, buyer: User, lang: str | None = None) -> dict:
    rows = db.execute(select(CartItem, Product).join(Product, CartItem.product_id == Product.id)
                      .where(CartItem.buyer_id == buyer.id)).all()
    items = [{**product_card(p, lang), "quantity": ci.quantity, "line_total": (p.price or 0) * ci.quantity,
              "available": p.status == "live" and p.quantity >= ci.quantity} for ci, p in rows]
    return {"items": items, "subtotal": sum(i["line_total"] for i in items), "shipping": 0,
            "total": sum(i["line_total"] for i in items),
            "note": "Shipping & packing are already included in each item's fair price."}


@router.get("/cart")
def get_cart(lang: str | None = None, buyer: User = Depends(shopper), db: Session = Depends(get_db)):
    return _cart(db, buyer, lang)


@router.post("/cart")
def add_to_cart(line: CartLine, buyer: User = Depends(shopper), db: Session = Depends(get_db)):
    p = db.get(Product, line.product_id)
    if not p or p.status != "live":
        raise HTTPException(404, "product not available")
    seller = db.get(Artisan, p.artisan_id)
    if seller and seller.user_id == buyer.id:
        raise HTTPException(409, "this is your own product")
    ci = db.execute(select(CartItem).where(CartItem.buyer_id == buyer.id, CartItem.product_id == p.id)).scalar_one_or_none()
    if ci:
        ci.quantity = line.quantity
    else:
        db.add(CartItem(buyer_id=buyer.id, product_id=p.id, quantity=line.quantity))
    db.add(Event(type="add_to_cart", product_id=p.id, buyer_id=buyer.id, meta={"qty": line.quantity}))
    db.commit()
    return _cart(db, buyer)


@router.delete("/cart/{product_id}")
def remove_from_cart(product_id: str, buyer: User = Depends(shopper), db: Session = Depends(get_db)):
    db.query(CartItem).filter_by(buyer_id=buyer.id, product_id=product_id).delete()
    db.commit()
    return _cart(db, buyer)


@router.get("/delivery-estimate")
def delivery_estimate(product_id: str, state: str, db: Session = Depends(get_db)):
    p = db.get(Product, product_id)
    if not p:
        raise HTTPException(404, "product not found")
    q = get_logistics().quote(p.category or "Other", (p.attributes or {}).get("extraction", {}).get("weight_g"),
                              p.artisan.state, state)
    return {"days": q["days"] + 2, "carrier": q["carrier"], "shipping_included": True}


# ------------------------------------------------------------------ checkout & orders
def order_view(db: Session, o: Order, lang: str | None = None) -> dict:
    items = []
    for it in o.items:
        p = db.get(Product, it.product_id)
        items.append({"id": it.id, "product": product_card(p, lang), "quantity": it.quantity, "unit_price": it.unit_price,
                      "artisan_id": it.artisan_id,
                      "reviewed": db.execute(select(Review.id).where(Review.order_item_id == it.id)).first() is not None})
    pay = db.execute(select(Payment).where(Payment.order_id == o.id).order_by(Payment.created_at.desc())).scalars().first()
    tracking = dict(o.tracking or {})
    if tracking.get("awb"):
        tracking["events"] = get_logistics().track(tracking)
        if o.status in ("delivered", "returned"):
            done = next((h["at"] for h in reversed(o.history or []) if h["status"] == "delivered"), None)
            before = [e for e in tracking["events"] if not done or e["at"] <= done]
            tracking["events"] = before + [{"status": "Delivered", "at": done or o.created_at.isoformat()}]
    return {"id": o.id, "status": o.status, "channel": o.channel, "total": o.total, "subtotal": o.subtotal,
            "payment_method": o.payment_method, "payment_status": pay.status if pay else None,
            "delivery_estimate_days": o.delivery_estimate_days, "address": o.address, "history": o.history,
            "tracking": tracking, "items": items, "created_at": o.created_at.isoformat()}


@router.post("/checkout")
def checkout(body: CheckoutIn, buyer: User = Depends(shopper), db: Session = Depends(get_db)):
    lines = [(ci.product_id, ci.quantity) for ci in db.query(CartItem).filter_by(buyer_id=buyer.id).all()]
    order, payment = O.create_order(db, buyer.id, lines, body.address.model_dump(), body.payment_method)
    db.query(CartItem).filter_by(buyer_id=buyer.id).delete()
    db.commit()
    return {"order": order_view(db, order), "payment": payment}


@router.get("/orders")
def my_orders(lang: str | None = None, buyer: User = Depends(shopper), db: Session = Depends(get_db)):
    rows = db.execute(select(Order).where(Order.buyer_id == buyer.id).order_by(Order.created_at.desc())).scalars().all()
    return [order_view(db, o, lang) for o in rows]


def _sells(db: Session, user: User, o: Order) -> bool:
    """True if the user is the artisan on this order, or the kiosk operator who manages that artisan."""
    artisan_ids = {i.artisan_id for i in o.items}
    if user.role == "artisan":
        return db.execute(select(Artisan.id).where(Artisan.user_id == user.id)).scalar_one_or_none() in artisan_ids
    if user.role == "operator":
        op = db.execute(select(Operator).where(Operator.user_id == user.id)).scalar_one_or_none()
        if not op:
            return False
        managed = {a for (a,) in db.execute(select(Artisan.id).where(Artisan.onboarded_by_operator_id == op.id))}
        return bool(managed & artisan_ids)
    return False


@router.get("/orders/{order_id}")
def get_order(order_id: str, lang: str | None = None, user: User = Depends(current_user), db: Session = Depends(get_db)):
    o = db.get(Order, order_id)
    if not o:
        raise HTTPException(404, "order not found")
    if user.role != "admin" and o.buyer_id != user.id and not _sells(db, user, o):
        raise HTTPException(403, "not your order")
    return order_view(db, o, lang)


@router.get("/artisan/orders")
def artisan_orders(lang: str | None = None, artisan: Artisan = Depends(acting_artisan), db: Session = Depends(get_db)):
    ids = [oid for (oid,) in db.execute(select(OrderItem.order_id).where(OrderItem.artisan_id == artisan.id).distinct())]
    rows = db.execute(select(Order).where(Order.id.in_(ids)).order_by(Order.created_at.desc())).scalars().all() if ids else []
    return [order_view(db, o, lang) for o in rows]


ARTISAN_ACTIONS = {"accepted", "declined", "packed", "shipped"}
BUYER_ACTIONS = {"cancelled", "returned"}


@router.post("/orders/{order_id}/status")
def update_status(order_id: str, body: OrderStatusIn, user: User = Depends(current_user), db: Session = Depends(get_db)):
    """Artisans accept / decline (one tap or IVR key), pack and ship; buyers cancel; courier/admin mark delivered."""
    o = db.get(Order, order_id)
    if not o:
        raise HTTPException(404, "order not found")
    if user.role == "admin":
        pass
    elif user.role == "buyer":
        if o.buyer_id != user.id or body.status not in BUYER_ACTIONS:
            raise HTTPException(403, "not allowed")
    elif user.role in ("artisan", "operator"):
        if not _sells(db, user, o):
            raise HTTPException(403, "not your order")
        if body.status not in ARTISAN_ACTIONS:
            raise HTTPException(403, "not allowed")
    O.transition(db, o, body.status, user.id, body.note)
    db.commit()
    return order_view(db, o)


@router.post("/orders/{order_id}/courier-delivered")
def courier_webhook(order_id: str, x_webhook_token: str | None = Header(default=None),
                    user: User | None = Depends(optional_user), db: Session = Depends(get_db)):
    """Logistics-partner webhook: marks a shipped order delivered, which settles the artisan payout.
    Only the courier (shared webhook token) or an admin may call it."""
    token = get_settings().webhook_token
    if not ((token and x_webhook_token == token) or (user and user.role == "admin")):
        raise HTTPException(403, "courier webhook requires the webhook token or an admin")
    o = db.get(Order, order_id)
    if not o:
        raise HTTPException(404, "order not found")
    O.transition(db, o, "delivered", "courier", "delivery confirmed by logistics partner")
    db.commit()
    return order_view(db, o)


# ------------------------------------------------------------------ payments
@router.post("/payments/confirm")
def confirm_payment(body: PaymentConfirm, user: User = Depends(current_user), db: Session = Depends(get_db)):
    pay = db.execute(select(Payment).where(Payment.provider_order_id == body.provider_order_id)).scalar_one_or_none()
    if not pay:
        raise HTTPException(404, "payment not found")
    if not get_payments(pay.provider).verify_payment(body.provider_order_id, body.payment_id, body.signature):
        raise HTTPException(400, "payment signature invalid")
    pay.status, pay.provider_payment_id = "paid", body.payment_id
    db.commit()
    return {"status": "paid"}


@router.post("/payments/mock/{provider_order_id}/pay")
def mock_pay(provider_order_id: str, db: Session = Depends(get_db)):
    """Dev-only UPI sandbox: simulates the buyer completing payment and returns what the SDK would return."""
    if runtime_settings.provider(db, "payment") != "mock":
        raise HTTPException(404, "mock payments disabled")
    pid = "mock_pay_" + provider_order_id[-8:]
    return {"provider_order_id": provider_order_id, "payment_id": pid,
            "signature": MockPayments.sign_for_test(provider_order_id, pid)}


@router.post("/payments/webhook")
async def payment_webhook(request: Request, x_razorpay_signature: str | None = Header(default=None),
                          db: Session = Depends(get_db)):
    raw = await request.body()
    provider = runtime_settings.provider(db, "payment")
    if not get_payments(provider).verify_webhook(raw, x_razorpay_signature or ""):
        raise HTTPException(400, "bad signature")
    evt = json.loads(raw)
    entity = evt.get("payload", {}).get("payment", {}).get("entity", {})
    pay = db.execute(select(Payment).where(Payment.provider_order_id == entity.get("order_id"))).scalar_one_or_none()
    if pay and evt.get("event") == "payment.captured":
        pay.status, pay.provider_payment_id = "paid", entity.get("id")
        db.commit()
    return {"ok": True}


# ------------------------------------------------------------------ reviews & events
@router.post("/reviews")
def add_review(body: ReviewIn, buyer: User = Depends(shopper), db: Session = Depends(get_db)):
    it = db.get(OrderItem, body.order_item_id)
    if not it or it.order.buyer_id != buyer.id:
        raise HTTPException(404, "order item not found")
    if it.order.status != "delivered":
        raise HTTPException(409, "you can review after delivery")
    if db.execute(select(Review.id).where(Review.order_item_id == it.id)).first():
        raise HTTPException(409, "already reviewed")
    db.add(Review(order_item_id=it.id, product_id=it.product_id, buyer_id=buyer.id, rating=body.rating, text=body.text))
    db.flush()
    p = db.get(Product, it.product_id)
    avg, n = db.execute(select(func.avg(Review.rating), func.count()).where(Review.product_id == p.id)).one()
    # keep seeded historical ratings: blend with prior count/avg
    prior_n = (p.attributes or {}).get("seed_reviews", 0)
    prior_avg = (p.attributes or {}).get("seed_rating", 0)
    total = prior_n + n
    p.rating_avg = round(((prior_avg * prior_n) + float(avg) * n) / total, 2)
    p.rating_count = total
    db.commit()
    return {"rating_avg": p.rating_avg, "rating_count": p.rating_count}


@router.get("/reviews/{product_id}")
def list_reviews(product_id: str, db: Session = Depends(get_db)):
    rows = db.execute(select(Review).where(Review.product_id == product_id).order_by(Review.created_at.desc()).limit(50)).scalars()
    return [{"rating": r.rating, "text": r.text, "at": r.created_at.isoformat()} for r in rows]


@router.post("/events")
def track_events(body: EventsIn, user: User | None = Depends(optional_user), db: Session = Depends(get_db)):
    """Buyer views / add-to-cart / orders / returns — these retrain the price and ranking models."""
    for e in body.events:
        db.add(Event(type=e.type, product_id=e.product_id, buyer_id=user.id if user else None, meta=e.meta))
    db.commit()
    return {"accepted": len(body.events)}
