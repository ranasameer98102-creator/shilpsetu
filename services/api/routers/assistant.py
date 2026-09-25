"""Shilpi, the assistant: greeting card (streak, daily goal, badges, craft of the day) and chat."""
from __future__ import annotations

from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from ai import assistant as A
from ai import crafts

from .. import runtime_settings
from ..config import get_settings
from ..db import get_db
from ..models import Artisan, AssistantDay, Event, Order, OrderItem, Product, User
from ..security import optional_user
from .artisans import dashboard
from .storefront import _cards, _live

router = APIRouter(prefix="/assistant", tags=["assistant"])
IST = timezone(timedelta(hours=5, minutes=30))
HELPLINE = "+91 80000 00000"


def _today() -> date:
    return datetime.now(IST).date()


def _lang(lang: str | None) -> str:
    return "hi" if lang == "hi" else "en"


def _artisan(db: Session, user: User | None) -> Artisan | None:
    if not user or user.role != "artisan":
        return None
    return db.execute(select(Artisan).where(Artisan.user_id == user.id)).scalar_one_or_none()


def _mark_active(db: Session, user: User | None) -> None:
    if user and not db.get(AssistantDay, (user.id, _today().isoformat())):
        db.add(AssistantDay(user_id=user.id, day=_today().isoformat()))
        db.commit()


def _streak(db: Session, user: User, artisan: Artisan | None) -> int:
    days = {date.fromisoformat(d) for (d,) in db.execute(select(AssistantDay.day).where(AssistantDay.user_id == user.id))}
    if artisan:
        days |= {c.astimezone(IST).date() if c.tzinfo else c.date() for (c,) in
                 db.execute(select(Product.created_at).where(Product.artisan_id == artisan.id))}
    d, n = _today(), 0
    if d not in days:
        d -= timedelta(days=1)  # today not done yet: the streak so far still counts
    while d in days:
        n += 1
        d -= timedelta(days=1)
    return n


def _artisan_stats(db: Session, user: User, a: Artisan) -> dict:
    dash = dashboard(a, db)
    start = datetime.combine(_today(), datetime.min.time(), IST)
    listed_today = db.execute(select(func.count()).select_from(Product).where(
        Product.artisan_id == a.id, Product.created_at >= start)).scalar_one()
    by_status = dash["products_by_status"]
    live = by_status.get("live", 0)
    sold = db.execute(select(func.count()).select_from(OrderItem).where(OrderItem.artisan_id == a.id)).scalar_one()
    best = db.execute(select(func.max(Product.rating_avg)).where(Product.artisan_id == a.id)).scalar_one() or 0
    streak = _streak(db, user, a)
    return {"wage": int(runtime_settings.fair_wage_for(db, a.state)), "earned_month": dash["earned_this_month"],
            "orders_month": dash["orders_paid_this_month"], "open_orders": dash["open_orders"], "live": live,
            "sold": sold, "best_rating": best, "streak": streak, "listed_today": listed_today,
            "verified": a.verification_status == "verified", "name": a.name_native or a.name}


BADGES = [  # key, icon, en, hi, test
    ("first_listing", "rocket_launch", "First listing", "पहला सामान", lambda s: s["live"] >= 1),
    ("five_listings", "inventory", "5 crafts online", "5 शिल्प ऑनलाइन", lambda s: s["live"] >= 5),
    ("first_sale", "celebration", "First sale", "पहली बिक्री", lambda s: s["sold"] >= 1),
    ("five_star", "star", "5-star maker", "5 सितारा कारीगर", lambda s: s["best_rating"] >= 4.8),
    ("streak_7", "local_fire_department", "7-day streak", "7 दिन की स्ट्रीक", lambda s: s["streak"] >= 7),
    ("verified", "verified", "Verified artisan", "सत्यापित कारीगर", lambda s: s["verified"]),
]


def _craft_of_day(lang: str) -> dict | None:
    keys = sorted(crafts.CRAFTS)
    return crafts.craft_story(keys[_today().toordinal() % len(keys)], lang)


@router.get("/greeting")
def greeting(lang: str | None = None, user: User | None = Depends(optional_user), db: Session = Depends(get_db)):
    """What the mascot says when a home screen opens, plus streak, daily goal and badges for artisans."""
    lang = _lang(lang)
    _mark_active(db, user)
    hour = datetime.now(IST).hour
    hello = A._t(lang, "Good morning" if hour < 12 else "Good afternoon" if hour < 17 else "Good evening",
                 "सुप्रभात" if hour < 12 else "नमस्ते" if hour < 17 else "शुभ संध्या")
    a = _artisan(db, user)
    if a:
        s = _artisan_stats(db, user, a)
        if s["open_orders"]:
            msg = A._t(lang, f"{hello}, {a.name}! {s['open_orders']} order(s) are waiting - let's pack them.",
                       f"{hello}, {s['name']}! {s['open_orders']} ऑर्डर इंतज़ार में हैं - चलिए पैक करें।")
            mood = "cheer"
        elif not s["listed_today"]:
            msg = A._t(lang, f"{hello}, {a.name}! Today's goal: add one new craft. It takes 30 seconds.",
                       f"{hello}, {s['name']}! आज का लक्ष्य: एक नया सामान जोड़ें। सिर्फ़ 30 सेकंड लगते हैं।")
            mood = "wave"
        else:
            msg = A._t(lang, f"Goal done for today, {a.name}! Your crafts are reaching buyers across India.",
                       f"आज का लक्ष्य पूरा, {s['name']}! आपका सामान पूरे भारत के ख़रीदारों तक पहुँच रहा है।")
            mood = "cheer"
        return {"name": A.NAME[lang], "mood": mood, "message": msg, "suggestions": A.suggestions("artisan", lang),
                "streak": s["streak"], "goal": {"done": min(s["listed_today"], 1), "target": 1},
                "badges": [{"key": k, "icon": ic, "label": hi if lang == "hi" else en, "earned": bool(test(s))}
                           for k, ic, en, hi, test in BADGES],
                "craft_of_day": None}
    craft = _craft_of_day(lang)
    msg = A._t(lang, f"{hello}! I'm {A.NAME[lang]}. Today's craft is {craft['name']} from {craft['region']}.",
               f"{hello}! मैं {A.NAME[lang]} हूँ। आज का शिल्प है {craft['name']} ({craft['region']})।")
    return {"name": A.NAME[lang], "mood": "wave", "message": msg, "suggestions": A.suggestions("buyer", lang),
            "streak": _streak(db, user, None) if user else 0, "goal": None, "badges": [], "craft_of_day": craft}


class ChatIn(BaseModel):
    message: str = Field(min_length=1, max_length=500)
    lang: str | None = None
    history: list[dict] = Field(default_factory=list, max_length=12)


def _search(db: Session, q: str, lang: str, limit: int = 6) -> list[dict]:
    like = f"%{q.lower()}%"
    rows = db.execute(_live().where(or_(func.lower(Product.title).like(like), func.lower(Product.category).like(like),
                                        func.lower(Artisan.craft_type).like(like)))
                      .order_by(Product.rating_avg.desc().nullslast()).limit(limit)).scalars().all()
    return _cards(db, rows, lang)


@router.post("/chat")
def chat(body: ChatIn, user: User | None = Depends(optional_user), db: Session = Depends(get_db)):
    lang = _lang(body.lang or (user.language if user else None))
    role = "artisan" if _artisan(db, user) else (user.role if user and user.role == "operator" else "buyer")
    intent = A.detect(body.message, role)
    facts: dict = {"helpline": HELPLINE}
    a = _artisan(db, user)
    if a:
        facts["stats"] = _artisan_stats(db, user, a)
    if intent.craft:
        facts["craft"] = crafts.craft_story(intent.craft, lang)
        facts["craft_query"] = crafts.craft_story(intent.craft, "en")["name"].split()[0]
        facts["products"] = _search(db, facts["craft_query"], lang)
    if intent.name == "gifts":
        stmt = _live().where(Product.price <= intent.budget)
        rows = db.execute(stmt.order_by(Product.rating_avg.desc().nullslast(), Product.price).limit(6)).scalars().all()
        facts["products"] = _cards(db, rows, lang)
        if not rows:
            facts["cheapest"] = _cards(db, db.execute(_live().order_by(Product.price).limit(6)).scalars().all(), lang)
    elif intent.name == "find" and intent.query:
        facts["products"] = _search(db, intent.query, lang)
    elif intent.name == "track_order" and user:
        o = db.execute(select(Order).where(Order.buyer_id == user.id).order_by(Order.created_at.desc())
                       .limit(1)).scalar_one_or_none()
        if o:
            facts["order"] = {"id": o.id, "status": o.status}
    elif intent.name == "what_sells":
        since = datetime.now(timezone.utc) - timedelta(days=60)
        facts["top_categories"] = [c for (c, _n) in db.execute(
            select(Product.category, func.count()).join(Event, Event.product_id == Product.id)
            .where(Event.type.in_(["add_to_cart", "order"]), Event.ts >= since)
            .group_by(Product.category).order_by(func.count().desc()).limit(3))]
    reply = A.respond(intent, lang, role, facts)
    llm = A.get_assistant(get_settings().assistant_provider)
    if llm:
        try:
            reply = llm.polish(body.message, lang, role, body.history, reply, facts)
        except Exception as e:  # keep answering from the rule-based engine
            A.log.warning("assistant LLM failed, using rule-based answer: %s", e)
    _mark_active(db, user)
    return {"reply": reply.text, "mood": reply.mood, "suggestions": reply.suggestions, "actions": reply.actions,
            "products": reply.products, "intent": intent.name}
