"""Buyer storefront: feed sections, search with filters, product detail (fair price + certificate)."""
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import and_, func, or_, select
from sqlalchemy.orm import Session, selectinload

from ai.lexicon import CATEGORIES

from ..db import get_db
from ..domain import pricing_service
from ..models import Artisan, Event, PriceQuote, Product, User
from ..security import optional_user
from ..serializers import artisan_public, product_card, product_full

router = APIRouter(prefix="/storefront", tags=["storefront"])


def _live():
    return select(Product).join(Artisan, Product.artisan_id == Artisan.id).where(Product.status == "live") \
        .options(selectinload(Product.media), selectinload(Product.artisan))


def _shares(db: Session, ids: list[str]) -> dict:
    if not ids:
        return {}
    return dict(db.execute(select(PriceQuote.product_id, PriceQuote.artisan_share_pct)
                           .where(PriceQuote.product_id.in_(ids), PriceQuote.is_current)).all())


def _cards(db: Session, rows: list[Product], lang: str | None) -> list[dict]:
    shares = _shares(db, [p.id for p in rows])
    return [product_card(p, lang, shares.get(p.id)) for p in rows]


@router.get("/feed")
def feed(lang: str | None = None, state: str | None = Query(None, description="buyer's state for 'Near you'"),
         db: Session = Depends(get_db)):
    ranked = _live().order_by(Product.rank_score.desc(), Product.published_at.desc())
    sections = [
        {"key": "fresh", "title": "Fresh from the loom & wheel",
         "items": _cards(db, db.execute(_live().order_by(Product.published_at.desc()).limit(10)).scalars().all(), lang)},
        {"key": "women_led", "title": "Women-led collectives",
         "items": _cards(db, db.execute(ranked.where(Artisan.gender == "female").limit(10)).scalars().all(), lang)},
        {"key": "gi", "title": "GI-tagged crafts",
         "items": _cards(db, db.execute(ranked.where(Artisan.gi_tag.is_not(None)).limit(10)).scalars().all(), lang)},
    ]
    if state:
        sections.append({"key": "near_you", "title": "Near you",
                         "items": _cards(db, db.execute(ranked.where(Artisan.state == state).limit(10)).scalars().all(), lang)})
    cats = db.execute(select(Product.category, func.count()).where(Product.status == "live")
                      .group_by(Product.category)).all()
    states = db.execute(select(Artisan.state, Artisan.cluster, func.count()).join(Product, Product.artisan_id == Artisan.id)
                        .where(Product.status == "live").group_by(Artisan.state, Artisan.cluster)).all()
    return {"sections": [s for s in sections if s["items"]],
            "categories": [{"name": c, "count": n} for c, n in cats if c],
            "clusters": [{"state": s, "cluster": c, "count": n} for s, c, n in states if s]}


@router.get("/search")
def search(q: str | None = None, category: str | None = None, state: str | None = None,
           min_price: float | None = None, max_price: float | None = None, verified_only: bool = False,
           gi_only: bool = False, women_led: bool = False,
           sort: Literal["relevance", "price_asc", "price_desc", "newest"] = "relevance",
           lang: str | None = None, limit: int = Query(40, le=100), offset: int = 0, db: Session = Depends(get_db)):
    stmt = _live()
    if q:
        like = f"%{q}%"
        stmt = stmt.where(or_(Product.title.ilike(like), Product.description.ilike(like), Product.category.ilike(like),
                              Artisan.name.ilike(like), Artisan.cluster.ilike(like), Artisan.craft_type.ilike(like)))
    if category:
        stmt = stmt.where(Product.category == category)
    if state:
        stmt = stmt.where(Artisan.state == state)
    if min_price is not None:
        stmt = stmt.where(Product.price >= min_price)
    if max_price is not None:
        stmt = stmt.where(Product.price <= max_price)
    if verified_only:
        stmt = stmt.where(Artisan.verification_status == "verified")
    if gi_only:
        stmt = stmt.where(Artisan.gi_tag.is_not(None))
    if women_led:
        stmt = stmt.where(Artisan.gender == "female")
    order = {"relevance": (Product.rank_score.desc(), Product.published_at.desc()),
             "price_asc": (Product.price.asc(),), "price_desc": (Product.price.desc(),),
             "newest": (Product.published_at.desc(),)}[sort]
    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(stmt.order_by(*order).limit(limit).offset(offset)).scalars().all()
    return {"total": total, "items": _cards(db, rows, lang)}


@router.get("/filters")
def filters(db: Session = Depends(get_db)):
    states = [s for (s,) in db.execute(select(Artisan.state).join(Product, Product.artisan_id == Artisan.id)
                                        .where(Product.status == "live").distinct()) if s]
    lo, hi = db.execute(select(func.min(Product.price), func.max(Product.price)).where(Product.status == "live")).one()
    return {"categories": CATEGORIES, "states": sorted(states), "price_range": [lo or 0, hi or 0],
            "sorts": ["relevance", "price_asc", "price_desc", "newest"]}


@router.get("/products/{product_id}")
def product_detail(product_id: str, lang: str | None = None, user: User | None = Depends(optional_user),
                   db: Session = Depends(get_db)):
    p = db.get(Product, product_id)
    if not p or p.status != "live":
        raise HTTPException(404, "product not available")
    data = product_full(db, p, lang)
    for k in ("transcript", "pipeline", "needs_review_fields"):
        data.pop(k, None)
    if data["price_quote"]:
        data["price_quote"].pop("inputs", None)
    others = db.execute(_live().where(Product.artisan_id == p.artisan_id, Product.id != p.id).limit(6)).scalars().all()
    data["more_from_artisan"] = _cards(db, others, lang)
    data["artisan"]["live_products"] = db.execute(select(func.count()).select_from(Product).where(
        Product.artisan_id == p.artisan_id, Product.status == "live")).scalar_one()
    db.add(Event(type="view", product_id=p.id, buyer_id=user.id if user else None, meta={"lang": lang}))
    db.commit()
    return data
