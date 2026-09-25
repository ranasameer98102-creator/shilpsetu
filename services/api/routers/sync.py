"""Device <-> server reconciliation for the offline queue, and a what-if price preview."""
from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.orm import Session

from ai import pricing as P

from .. import runtime_settings
from ..db import get_db
from ..domain import pricing_service
from ..models import Product, SyncJob, User
from ..security import current_user

router = APIRouter(tags=["sync", "pricing"])


@router.get("/sync/status")
def sync_status(device_id: str, keys: str = Query("", description="comma-separated idempotency keys"),
                user: User = Depends(current_user), db: Session = Depends(get_db)):
    """For each queued capture on the device: Queued / Processing / Needs review / Ready / Live, plus the product id."""
    wanted = [k for k in keys.split(",") if k]
    stmt = select(SyncJob).where(SyncJob.device_id == device_id)
    if wanted:
        stmt = stmt.where(SyncJob.idempotency_key.in_(wanted))
    out = {}
    for job in db.execute(stmt).scalars():
        p = db.get(Product, job.result_ref) if job.result_ref else None
        out[job.idempotency_key] = {"product_id": job.result_ref, "status": p.status if p else job.status,
                                    "title": p.title if p else None, "price": p.price if p else None}
    return out


class PricePreviewIn(BaseModel):
    category: str
    material_cost: float | None = None
    hours: float | None = None
    state: str | None = None
    techniques: list[str] = []
    gi_craft: str | None = None
    weight_g: float | None = None


@router.post("/pricing/preview")
def price_preview(body: PricePreviewIn, db: Session = Depends(get_db)):
    """Transparent what-if: how a fair price is built from these inputs (used by kiosk operators and the admin)."""
    cfg = runtime_settings.get_all(db)
    inp = P.PriceInputs(category=body.category, material_cost=body.material_cost, hours=body.hours,
                        wage_per_hour=runtime_settings.fair_wage_for(db, body.state),
                        commission_pct=float(cfg["commission_pct"]), techniques=body.techniques,
                        gi_craft=body.gi_craft, weight_g=body.weight_g, state=body.state)
    model = pricing_service.active_market_model(db)
    market = model.predict(P.features(body.category, body.material_cost or 300,
                                      body.hours or P.TYPICAL_HOURS.get(body.category, 12), bool(body.gi_craft),
                                      P.complexity_of(body.techniques), body.weight_g))
    db.commit()
    return P.quote(inp, market)


@router.get("/pricing/{product_id}")
def product_price(product_id: str, db: Session = Depends(get_db)):
    """Public 'How this price is built' for a live listing."""
    q = pricing_service.current_quote(db, product_id)
    p = db.get(Product, product_id)
    if not q or not p or p.status != "live":
        return {"available": False}
    d = pricing_service.as_dict(q)
    d.pop("inputs", None)
    return {"available": True, **d}
