"""Admin / MoSJE dashboard API: verification, moderation, collective analytics, impact, settings, schemes, ONDC."""
import csv
import io
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import Response
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from workers.jobs import ondc_sync, ondc_sync_pending, retrain
from workers.queue import enqueue

from .. import audit, runtime_settings
from ..db import get_db
from ..domain import publishing
from ..models import (Artisan, AuditLog, Certificate, HelpdeskCallback, ModelVersion, Notification, OndcSync,
                      Operator, Order, OrderItem, PriceQuote, Product, SchemeLink, SyncJob, User)
from ..crypto import lookup_hash
from ..schemas import ModerateIn, OperatorCreate, RevokeIn, SchemeLinkIn, SettingsIn, VerifyArtisanIn
from ..security import require_roles
from ..serializers import artisan_public, product_card

router = APIRouter(prefix="/admin", tags=["admin"])
K_ANON = 2  # minimum artisans per exported cell; raise to 5+ at production scale
admin_only = require_roles("admin")

MARKET = {
    "export_growth_pct": 65, "export_growth_period": "2014-15 → 2024-25",
    "export_value_cr": 33123, "export_value_year": "FY 2024-25",
    "women_artisans_pct": 64, "women_handloom_weavers_pct": 71,
    "weavers_under_5000_pct": 66,
    "policy": "ONDC / DigiHaat — government is actively onboarding artisans and farmers onto open digital commerce",
    "framing": "None of this is a bet on the future — the market pull, the policy support and the export momentum "
               "already exist. What's missing is a way for individual artisans to actually reach it.",
    "sources": ["PIB, Dec 2025", "EPCH", "ONDC DigiHaat", "All-India Handloom Census 2019-20",
                "India Development Review"],
}


# ------------------------------------------------------------------ verification
@router.get("/verification-queue")
def verification_queue(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    rows = db.execute(select(Artisan).where(Artisan.verification_status == "pending").order_by(Artisan.created_at)).scalars().all()
    out = []
    for a in rows:
        op = db.get(Operator, a.onboarded_by_operator_id) if a.onboarded_by_operator_id else None
        out.append({**artisan_public(a), "pehchan_id": a.pehchan_id, "csc_id": a.csc_id,
                    "operator": {"name": op.name, "csc_id": op.csc_id, "attestation": a.operator_attestation} if op else None,
                    "consent_flags": a.consent_flags, "created_at": a.created_at.isoformat()})
    return out


@router.post("/artisans/{artisan_id}/verify")
def verify_artisan(artisan_id: str, body: VerifyArtisanIn, admin: User = Depends(admin_only), db: Session = Depends(get_db)):
    a = db.get(Artisan, artisan_id)
    if not a:
        raise HTTPException(404, "artisan not found")
    a.verification_status = body.status
    a.pehchan_verified = body.pehchan_verified and bool(a.pehchan_id)
    audit.record(db, f"artisan.{body.status}", "artisan", a.id, {"pehchan_verified": a.pehchan_verified,
                                                                  "note": body.note}, admin.id)
    db.commit()
    return artisan_public(a)


@router.get("/artisans")
def all_artisans(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    return [artisan_public(a) for a in db.execute(select(Artisan).order_by(Artisan.name)).scalars()]


# ------------------------------------------------------------------ moderation
@router.get("/listings")
def listings(status: str | None = None, _: User = Depends(admin_only), db: Session = Depends(get_db)):
    stmt = select(Product).order_by(Product.updated_at.desc()).limit(200)
    if status:
        stmt = stmt.where(Product.status == status)
    out = []
    for p in db.execute(stmt).scalars():
        sync = db.execute(select(OndcSync).where(OndcSync.product_id == p.id)).scalar_one_or_none()
        out.append({**product_card(p), "status": p.status, "needs_review_fields": p.needs_review_fields,
                    "moderation_flag": p.moderation_flag, "created_via": p.created_via,
                    "certificate_id": p.certificate.id if p.certificate else None,
                    "certificate_revoked": bool(p.certificate and p.certificate.revoked_at),
                    "ondc_status": sync.status if sync else None})
    return out


@router.post("/listings/{product_id}/moderate")
def moderate(product_id: str, body: ModerateIn, admin: User = Depends(admin_only), db: Session = Depends(get_db)):
    p = db.get(Product, product_id)
    if not p:
        raise HTTPException(404, "product not found")
    if body.action == "flag":
        p.moderation_flag = body.reason or "flagged"
    elif body.action == "unpublish":
        publishing.unpublish(db, p, body.reason or "moderation", admin.id)
        enqueue(ondc_sync, p.id)
    elif body.action == "republish":
        p.moderation_flag = None
        publishing.publish(db, p, admin.id)
        enqueue(ondc_sync, p.id)
    elif body.action == "edit":
        p.title = body.title or p.title
        p.description = body.description or p.description
    audit.record(db, f"listing.{body.action}", "product", p.id, {"reason": body.reason}, admin.id)
    db.commit()
    return {"status": p.status, "moderation_flag": p.moderation_flag}


@router.post("/certificates/{cert_id}/revoke")
def revoke(cert_id: str, body: RevokeIn, admin: User = Depends(admin_only), db: Session = Depends(get_db)):
    c = db.get(Certificate, cert_id)
    if not c:
        raise HTTPException(404, "certificate not found")
    publishing.revoke_certificate(db, c, body.reason, admin.id)
    db.commit()
    return {"revoked": True}


# ------------------------------------------------------------------ analytics
def _aware(dt):
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


def compute_analytics(db: Session) -> dict:
    artisans = db.execute(select(Artisan).where(Artisan.name != "Deleted artisan")).scalars().all()
    n_art = len(artisans)
    women = sum(1 for a in artisans if a.gender == "female")
    declared = sum(1 for a in artisans if a.gender in ("female", "male", "other"))
    live = db.execute(select(func.count()).select_from(Product).where(Product.status == "live")).scalar_one()
    by_status = dict(db.execute(select(Product.status, func.count()).group_by(Product.status)).all())
    orders = db.execute(select(Order).where(Order.status.not_in(["declined", "cancelled"]))).scalars().all()
    gmv = sum(o.total for o in orders)
    shares = db.execute(select(func.avg(PriceQuote.artisan_share_pct)).join(Product, Product.id == PriceQuote.product_id)
                        .where(PriceQuote.is_current, Product.status == "live")).scalar_one()
    top_crafts = db.execute(select(Product.category, func.count(), func.coalesce(func.sum(OrderItem.unit_price * OrderItem.quantity), 0))
                            .outerjoin(OrderItem, OrderItem.product_id == Product.id)
                            .where(Product.status == "live").group_by(Product.category)
                            .order_by(func.count().desc())).all()
    states = {}
    for a in artisans:
        s = states.setdefault(a.state or "Unknown", {"state": a.state or "Unknown", "artisans": 0, "women": 0,
                                                     "clusters": set(), "gmv": 0.0})
        s["artisans"] += 1
        s["women"] += a.gender == "female"
        if a.cluster:
            s["clusters"].add(a.cluster)
    for oi, a in db.execute(select(OrderItem, Artisan).join(Artisan, OrderItem.artisan_id == Artisan.id)).all():
        states.setdefault(a.state or "Unknown", {"state": a.state, "artisans": 0, "women": 0, "clusters": set(), "gmv": 0.0})
        states[a.state or "Unknown"]["gmv"] += oi.unit_price * oi.quantity
    heat = [{**s, "clusters": sorted(s["clusters"])} for s in states.values()]
    # Offline-sync health
    offline = db.execute(select(Product).where(Product.captured_offline_at.is_not(None))).scalars().all()
    lags = [(_aware(p.created_at) - _aware(p.captured_offline_at)).total_seconds() / 3600 for p in offline]
    to_live = [(_aware(p.published_at) - _aware(p.created_at)).total_seconds() / 60 for p in
               db.execute(select(Product).where(Product.published_at.is_not(None))).scalars()]
    jobs = dict(db.execute(select(SyncJob.status, func.count()).group_by(SyncJob.status)).all())
    ondc = dict(db.execute(select(OndcSync.status, func.count()).group_by(OndcSync.status)).all())
    via = dict(db.execute(select(Product.created_via, func.count()).group_by(Product.created_via)).all())
    return {
        "artisans_onboarded": n_art, "women_pct": round(100 * women / declared, 1) if declared else None,
        "verified_artisans": sum(1 for a in artisans if a.verification_status == "verified"),
        "listings_live": live, "listings_by_status": by_status,
        "orders": len(orders), "orders_via_ondc": sum(1 for o in orders if o.channel == "ondc"), "gmv": round(gmv, 2),
        "avg_artisan_share_pct": round(float(shares), 1) if shares else None,
        "top_crafts": [{"category": c, "listings": n, "gmv": float(g)} for c, n, g in top_crafts],
        "state_heatmap": sorted(heat, key=lambda s: -s["artisans"]),
        "captured_via": via,
        "offline_sync_health": {
            "captured_offline": len(offline),
            "median_hours_offline_before_sync": round(sorted(lags)[len(lags) // 2], 1) if lags else None,
            "median_minutes_capture_to_live": round(sorted(to_live)[len(to_live) // 2], 1) if to_live else None,
            "sync_jobs": jobs,
        },
        "ondc_sync": ondc,
    }


@router.get("/analytics")
def analytics(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    return compute_analytics(db)


@router.get("/analytics/export.csv")
def analytics_export(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    """Anonymised, aggregated collective analytics (a revenue stream for govt / bulk buyers): state x craft."""
    rows = db.execute(select(Artisan.state, Product.category, func.count(func.distinct(Artisan.id)),
                             func.count(func.distinct(Product.id)), func.avg(Product.price))
                      .join(Product, Product.artisan_id == Artisan.id).where(Product.status == "live")
                      .group_by(Artisan.state, Product.category)).all()
    buf = io.StringIO()
    w = csv.writer(buf)
    w.writerow(["state", "craft_category", "artisans", "live_listings", "avg_price_inr"])
    for s, c, a, n, avg in rows:
        # Small cells are merged into "(other)" so no single artisan's sales can be singled out.
        if a >= K_ANON:
            w.writerow([s, c, a, n, round(float(avg or 0), 0)])
        else:
            w.writerow([s, "(other)", "<" + str(K_ANON), n, ""])
    return Response(buf.getvalue(), media_type="text/csv",
                    headers={"Content-Disposition": 'attachment; filename="shilpsetu-collective-analytics.csv"'})


@router.get("/impact")
def impact(db: Session = Depends(get_db)):
    """Market opportunity (public numbers) + platform impact. Public: shown on the admin Impact page and README."""
    a = compute_analytics(db)
    return {"market": MARKET, "platform": {k: a[k] for k in ("artisans_onboarded", "women_pct", "listings_live",
                                                              "orders", "gmv", "avg_artisan_share_pct")}}


@router.post("/operators")
def create_operator(body: OperatorCreate, admin: User = Depends(admin_only), db: Session = Depends(get_db)):
    """Register a CSC / SHG kiosk operator (operators cannot self-register)."""
    from .auth import normalize_phone

    phone = normalize_phone(body.phone)
    user = db.execute(select(User).where(User.phone_hash == lookup_hash(phone))).scalar_one_or_none()
    if user and user.role != "operator":
        raise HTTPException(409, f"this number is already registered as {user.role}")
    if not user:
        user = User(role="operator", phone=phone, phone_hash=lookup_hash(phone), language=body.language,
                    display_name=body.name)
        db.add(user)
        db.flush()
    op = db.execute(select(Operator).where(Operator.user_id == user.id)).scalar_one_or_none() or Operator(user_id=user.id)
    op.kind, op.name, op.csc_id, op.shg_id, op.region = body.kind, body.name, body.csc_id, body.shg_id, body.region
    db.add(op)
    db.flush()
    audit.record(db, "operator.registered", "operator", op.id, {"kind": body.kind}, admin.id)
    db.commit()
    return {"id": op.id, "name": op.name, "kind": op.kind}


@router.get("/operators")
def operators(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    out = []
    for op in db.execute(select(Operator)).scalars():
        onboarded = db.execute(select(func.count()).select_from(Artisan).where(Artisan.onboarded_by_operator_id == op.id)).scalar_one()
        captured = dict(db.execute(select(Product.status, func.count()).where(Product.operator_id == op.id)
                                   .group_by(Product.status)).all())
        out.append({"id": op.id, "name": op.name, "kind": op.kind, "csc_id": op.csc_id, "shg_id": op.shg_id,
                    "region": op.region, "artisans_onboarded": onboarded, "products_captured": sum(captured.values()),
                    "products_live": captured.get("live", 0)})
    return out


# ------------------------------------------------------------------ settings & schemes
@router.get("/settings")
def get_settings_(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    return runtime_settings.get_all(db)


@router.put("/settings")
def put_settings(body: SettingsIn, admin: User = Depends(admin_only), db: Session = Depends(get_db)):
    changes = body.model_dump(exclude_none=True)
    for k, v in changes.items():
        runtime_settings.put(db, k, v)
    audit.record(db, "settings.updated", "settings", "global", changes, admin.id)
    db.commit()
    return runtime_settings.get_all(db)


@router.get("/schemes")
def schemes(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    links = db.execute(select(SchemeLink)).scalars().all()
    report = {}
    for s in ("NHDP", "CHCDS", "SFURTI"):
        mine = [l for l in links if l.scheme == s]
        clusters = {l.cluster for l in mine if l.cluster}
        artisan_ids = {l.artisan_id for l in mine if l.artisan_id}
        if clusters:
            artisan_ids |= {a for (a,) in db.execute(select(Artisan.id).where(Artisan.cluster.in_(clusters)))}
        gmv = db.execute(select(func.coalesce(func.sum(OrderItem.unit_price * OrderItem.quantity), 0))
                         .where(OrderItem.artisan_id.in_(artisan_ids))).scalar_one() if artisan_ids else 0
        report[s] = {"clusters": sorted(clusters), "artisans": len(artisan_ids), "gmv": float(gmv)}
    return {"links": [{"id": l.id, "scheme": l.scheme, "artisan_id": l.artisan_id, "cluster": l.cluster, "note": l.note}
                      for l in links], "report": report}


@router.post("/schemes")
def add_scheme(body: SchemeLinkIn, admin: User = Depends(admin_only), db: Session = Depends(get_db)):
    if not body.artisan_id and not body.cluster:
        raise HTTPException(400, "link an artisan or a cluster")
    db.add(SchemeLink(**body.model_dump()))
    audit.record(db, "scheme.linked", "scheme", body.scheme, body.model_dump(), admin.id)
    db.commit()
    return schemes(admin, db)


# ------------------------------------------------------------------ ONDC, notifications, models, audit
@router.get("/ondc")
def ondc_status(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    from ondc_adapter.mock_gateway import LOG, NETWORK_INDEX

    rows = db.execute(select(OndcSync, Product).join(Product, Product.id == OndcSync.product_id)
                      .order_by(OndcSync.updated_at.desc())).all()
    return {"mode": runtime_settings.provider(db, "ondc"),
            "listings": [{"product_id": p.id, "title": p.title, "status": s.status, "attempts": s.attempts,
                          "last_error": s.last_error, "updated_at": s.updated_at.isoformat()} for s, p in rows],
            "network_log": list(LOG)[:30], "indexed_on_network": len(NETWORK_INDEX)}


@router.post("/ondc/{product_id}/retry")
def ondc_retry(product_id: str, _: User = Depends(admin_only)):
    ondc_sync(product_id)
    return {"ok": True}


@router.post("/ondc/sync-all")
def ondc_sync_all(_: User = Depends(admin_only)):
    return {"synced": ondc_sync_pending()}


@router.get("/notifications")
def notifications(limit: int = 100, _: User = Depends(admin_only), db: Session = Depends(get_db)):
    rows = db.execute(select(Notification).order_by(Notification.created_at.desc()).limit(limit)).scalars()
    return [{"id": n.id, "channel": n.channel, "template": n.template, "language": n.language,
             "to": "••••••" + n.to[-4:] if n.to else None,
             "body": n.body, "provider": n.provider, "status": n.status, "at": n.created_at.isoformat()} for n in rows]


@router.get("/helpdesk")
def helpdesk(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    rows = db.execute(select(HelpdeskCallback).order_by(HelpdeskCallback.created_at.desc()).limit(100)).scalars()
    return [{"id": h.id, "user_id": h.user_id, "language": h.language, "reason": h.reason, "status": h.status,
             "at": h.created_at.isoformat()} for h in rows]


@router.get("/models")
def models(_: User = Depends(admin_only), db: Session = Depends(get_db)):
    rows = db.execute(select(ModelVersion).order_by(ModelVersion.created_at.desc())).scalars()
    usage = dict(db.execute(select(PriceQuote.model_version, func.count()).group_by(PriceQuote.model_version)).all())
    return [{"id": m.id, "kind": m.kind, "active": m.is_active, "metrics": m.metrics, "params": m.params,
             "trained_on": m.trained_on, "created_at": m.created_at.isoformat(), "quotes_priced": usage.get(m.id, 0)}
            for m in rows]


@router.post("/models/retrain")
def retrain_now(admin: User = Depends(admin_only)):
    return retrain()


@router.get("/audit")
def audit_log(limit: int = 100, _: User = Depends(admin_only), db: Session = Depends(get_db)):
    ok, bad = audit.verify_chain(db)
    rows = db.execute(select(AuditLog).order_by(AuditLog.id.desc()).limit(limit)).scalars()
    return {"chain_valid": ok, "first_bad_row": bad,
            "entries": [{"id": r.id, "ts": r.ts.isoformat(), "actor": r.actor_id, "action": r.action,
                         "entity": r.entity, "entity_id": r.entity_id, "data": r.data, "hash": r.hash[:16]} for r in rows]}
