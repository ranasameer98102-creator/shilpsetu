"""Background jobs: AI listing build, ONDC catalog sync, and the nightly learning loop (price + ranking)."""
from __future__ import annotations

import logging
from collections import Counter
from datetime import datetime, timezone

import numpy as np
from sqlalchemy import func, select

from ai import pricing as P
from ai import ranking as R
from api import audit, runtime_settings
from api.db import session_factory
from api.models import (Artisan, Event, ModelVersion, OndcSync, OrderItem, PriceQuote, Product, ProductMedia,
                        SyncJob)

log = logging.getLogger(__name__)


def build_product(product_id: str, only: list[str] | None = None) -> None:
    from api.domain import pipeline

    db = session_factory()()
    try:
        pipeline.run_safely(db, product_id, set(only) if only else None)
        job = db.execute(select(SyncJob).where(SyncJob.result_ref == product_id)).scalar_one_or_none()
        if job:
            job.status = "done"
            db.commit()
    finally:
        db.close()


def ondc_sync(product_id: str) -> None:
    from ondc_adapter.bpp import sync_product

    db = session_factory()()
    try:
        sync_product(db, db.get(Product, product_id))
        db.commit()
    finally:
        db.close()


def ondc_sync_pending() -> int:
    db = session_factory()()
    try:
        ids = [s.product_id for s in db.query(OndcSync).filter(OndcSync.status.in_(["queued", "failed"])).all()]
    finally:
        db.close()
    for pid in ids:
        ondc_sync(pid)
    return len(ids)


def _aware(dt: datetime) -> datetime:
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


def retrain_market(db) -> ModelVersion:
    from api.domain.pricing_service import register_market_model

    X_syn, y_syn = P.synthetic_comparables()
    rows = db.execute(select(OrderItem, PriceQuote).join(PriceQuote, OrderItem.price_quote_id == PriceQuote.id)).all()
    X_sales, y_sales = [], []
    returned = {e.product_id for e in db.query(Event).filter(Event.type == "return").all()}
    for oi, q in rows:
        if oi.product_id in returned:
            continue  # a returned sale is not evidence of the market accepting that price
        i = q.inputs
        X_sales.append(P.features(i.get("category", "Other"), i.get("material_cost_used", 0), i.get("hours_used", 8),
                                  bool(i.get("gi_craft")), i.get("complexity", 1.0), i.get("weight_g")))
        y_sales.append(oi.unit_price)
    X = np.vstack([X_syn] + ([np.array(X_sales)] if X_sales else []))
    y = np.concatenate([y_syn] + ([np.array(y_sales)] if y_sales else []))
    w = np.concatenate([np.ones(len(y_syn)), np.full(len(y_sales), 5.0)])  # real sales count more
    n = db.execute(select(func.count()).select_from(ModelVersion).where(ModelVersion.kind == "market")).scalar_one()
    version = f"market-v{n + 1}"
    model = P.MarketModel.train(X, y, version, sample_weight=w)
    # holdout-free sanity metric: median absolute % error of p50 on the sales we have (or synthetic)
    Xe, ye = (np.array(X_sales), np.array(y_sales)) if len(y_sales) >= 5 else (X_syn[:200], y_syn[:200])
    preds = np.array([model.predict(list(x)).mid for x in Xe])
    mape = float(np.median(np.abs(preds - ye) / ye))
    row = register_market_model(db, model, {"median_ape": round(mape, 4), "eval_rows": int(len(ye))},
                                {"comparables": int(len(y_syn)), "sales": int(len(y_sales))})
    audit.record(db, "model.trained", "model", version, row.metrics)
    return row


def product_signals(db) -> list[R.ProductSignals]:
    views = Counter()
    conv = Counter()
    for t, pid, c in db.execute(select(Event.type, Event.product_id, func.count()).group_by(Event.type, Event.product_id)):
        if t == "view":
            views[pid] += c
        elif t in ("add_to_cart", "order"):
            conv[pid] += c
    sales_by_artisan = Counter(dict(db.execute(select(OrderItem.artisan_id, func.count()).group_by(OrderItem.artisan_id)).all()))
    enhanced = {pid for (pid,) in db.execute(select(ProductMedia.product_id).where(ProductMedia.kind == "enhanced"))}
    now = datetime.now(timezone.utc)
    out = []
    for p in db.query(Product).filter(Product.status == "live").all():
        a: Artisan = p.artisan
        q = db.execute(select(PriceQuote).where(PriceQuote.product_id == p.id, PriceQuote.is_current)).scalars().first()
        out.append(R.ProductSignals(
            product_id=p.id, price=p.price or 0, market_mid=(q.market_mid if q else p.price) or 1,
            rating=p.rating_avg or 0, reviews=p.rating_count or 0, verified=a.verification_status == "verified",
            gi=bool(a.gi_tag or (p.attributes or {}).get("extraction", {}).get("gi_craft")),
            enhanced_photo=p.id in enhanced, age_days=(now - _aware(p.published_at or p.created_at)).days,
            views=views[p.id], conversions=conv[p.id], artisan_age_days=(now - _aware(a.created_at)).days,
            artisan_sales=sales_by_artisan[a.id]))
    return out


def retrain_ranking(db) -> ModelVersion:
    signals = product_signals(db)
    n = db.execute(select(func.count()).select_from(ModelVersion).where(ModelVersion.kind == "ranking")).scalar_one()
    version = f"ranking-v{n + 1}"
    model = R.RankingModel.train(signals, version)
    fairness = runtime_settings.get(db, "fairness_boost")
    for s in signals:
        db.get(Product, s.product_id).rank_score = R.score(model, s, fairness)
    db.query(ModelVersion).filter(ModelVersion.kind == "ranking").update({"is_active": False})
    row = ModelVersion(id=version, kind="ranking", params={"coef": dict(zip(R.FEATURES, model.coef)),
                                                          "intercept": model.intercept, "learned": model.trained},
                       trained_on={"products": len(signals), "views": sum(s.views for s in signals),
                                   "conversions": sum(s.conversions for s in signals)},
                       metrics={}, is_active=True)
    db.add(row)
    db.flush()
    return row


def retrain() -> dict:
    """Nightly learning loop: buyer views / carts / orders / returns / sale prices -> new model versions."""
    db = session_factory()()
    try:
        m = retrain_market(db)
        r = retrain_ranking(db)
        db.commit()
        return {"market": m.id, "ranking": r.id, "market_metrics": m.metrics, "ranking_trained_on": r.trained_on}
    finally:
        db.close()
