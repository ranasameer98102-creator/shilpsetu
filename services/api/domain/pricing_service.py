"""Model registry + pricing for products. Every quote records the model version that produced it."""
from __future__ import annotations

import logging
import threading

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from ai import pricing as P
from api import runtime_settings
from api.config import get_settings
from api.models import Artisan, ModelVersion, PriceQuote, Product

log = logging.getLogger("shilpsetu")
_lock = threading.Lock()
_loaded: dict[str, P.MarketModel] = {}


def active_market_model(db: Session) -> P.MarketModel:
    row = db.execute(select(ModelVersion).where(ModelVersion.kind == "market", ModelVersion.is_active)).scalar_one_or_none()
    if row is None:
        return bootstrap_market_model(db)
    with _lock:
        if row.id not in _loaded:
            _loaded[row.id] = P.MarketModel.load(get_settings().data_dir / row.path)
        return _loaded[row.id]


def register_market_model(db: Session, model: P.MarketModel, metrics: dict, trained_on: dict) -> ModelVersion:
    rel = f"models/{model.version}.joblib"
    model.save(get_settings().data_dir / rel)
    db.execute(update(ModelVersion).where(ModelVersion.kind == "market").values(is_active=False))
    row = ModelVersion(id=model.version, kind="market", path=rel, metrics=metrics, trained_on=trained_on,
                       params={"algo": "HistGradientBoostingRegressor(quantile p20/p50/p80)", "features": P.FEATURES},
                       is_active=True)
    db.merge(row)
    db.flush()
    with _lock:
        _loaded[model.version] = model
    return row


def bootstrap_market_model(db: Session) -> P.MarketModel:
    X, y = P.synthetic_comparables()
    model = P.MarketModel.train(X, y, "market-v1")
    register_market_model(db, model, {"note": "bootstrap on seed comparables"},
                          {"comparables": int(len(y)), "sales": 0})
    return model


def _inputs(db: Session, product: Product, artisan: Artisan) -> P.PriceInputs:
    a = product.attributes or {}
    ex = a.get("extraction", {})
    cfg = runtime_settings.get_all(db)
    return P.PriceInputs(
        category=product.category or ex.get("category") or "Other",
        material_cost=ex.get("material_cost"),
        hours=ex.get("time_hours"),
        wage_per_hour=runtime_settings.fair_wage_for(db, artisan.state),
        commission_pct=float(cfg["commission_pct"]),
        techniques=ex.get("technique", []),
        gi_craft=ex.get("gi_craft") or artisan.gi_tag,
        weight_g=ex.get("weight_g"),
        state=artisan.state,
    )


def quote_product(db: Session, product: Product, artisan: Artisan) -> PriceQuote:
    inp = _inputs(db, product, artisan)
    hours = inp.hours or P.TYPICAL_HOURS.get(inp.category, 12)
    material = inp.material_cost if inp.material_cost is not None else 300
    try:
        market = active_market_model(db).predict(P.features(inp.category, material, hours, bool(inp.gi_craft),
                                                            P.complexity_of(inp.techniques), inp.weight_g))
    except (ImportError, OSError) as e:  # e.g. the ML runtime is blocked on this machine: fair-wage cost-plus still works
        log.warning("market model unavailable, pricing without it: %s", e)
        market = None
    q = P.quote(inp, market)
    return _store(db, product, q, "model")


def _store(db: Session, product: Product, q: dict, source: str) -> PriceQuote:
    db.execute(update(PriceQuote).where(PriceQuote.product_id == product.id).values(is_current=False))
    row = PriceQuote(
        product_id=product.id, model_version=q["model_version"], inputs=q["inputs"],
        breakdown={"lines": q["breakdown"], "fair_floor": q["fair_floor"], "compare_at": q["compare_at"],
                   "effective_hourly_wage": q["effective_hourly_wage"], "warnings": q.get("warnings", [])},
        market_low=q["market_low"], market_high=q["market_high"], market_mid=q["market_mid"],
        recommended=q["recommended"], final_price=q["final_price"], artisan_share_amount=q["artisan_share_amount"],
        artisan_share_pct=q["artisan_share_pct"], source=source, is_current=True,
    )
    db.add(row)
    product.price = q["final_price"]
    product.compare_at_price = q["compare_at"]
    db.flush()
    return row


def current_quote(db: Session, product_id: str) -> PriceQuote | None:
    return db.execute(select(PriceQuote).where(PriceQuote.product_id == product_id, PriceQuote.is_current)
                      .order_by(PriceQuote.created_at.desc()).limit(1)).scalar_one_or_none()


def as_dict(q: PriceQuote) -> dict:
    b = q.breakdown or {}
    return {
        "recommended": q.recommended, "final_price": q.final_price, "fair_floor": b.get("fair_floor"),
        "market_low": q.market_low, "market_mid": q.market_mid, "market_high": q.market_high,
        "compare_at": b.get("compare_at"), "artisan_share_amount": q.artisan_share_amount,
        "artisan_share_pct": q.artisan_share_pct, "effective_hourly_wage": b.get("effective_hourly_wage"),
        "breakdown": b.get("lines", []), "inputs": q.inputs, "model_version": q.model_version,
        "warnings": b.get("warnings", []),
    }


def adjust_price(db: Session, product: Product, new_price: float, source: str = "artisan_adjusted") -> PriceQuote:
    cur = current_quote(db, product.id)
    if cur is None:
        cur = quote_product(db, product, product.artisan)
    q = P.adjust(as_dict(cur), new_price)
    # keep the original market comparison visible to buyers
    q["compare_at"] = max(as_dict(cur)["compare_at"] or 0, P.round_price(new_price * 1.2))
    return _store(db, product, q, source)
