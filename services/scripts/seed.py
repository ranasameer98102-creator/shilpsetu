"""Seed the demo: 47 artisans across India's major art forms (majority women), 2 kiosk operators, 80 products run through the
real AI pipeline, the exact mockup vase, certificates, orders/payouts, marketplace events and scheme tags.

    python -m scripts.seed            # seed an empty database
    python -m scripts.seed --reset    # SQLite dev only: wipe and reseed
    python -m scripts.seed --if-empty # used by docker-compose on start-up
"""
from __future__ import annotations

import argparse
import hashlib
import json
import random
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

from sqlalchemy import func, select

from api import models  # noqa: F401
from api.config import REPO_DIR, get_settings
from api.crypto import lookup_hash, sha256_bytes
from api.db import Base, get_engine, session_factory
from api.domain import orders as O
from api.domain import pipeline, pricing_service, publishing
from api.models import (Artisan, Event, Operator, Payment, Product, ProductMedia, SchemeLink, SyncJob, User, now)
from api.routers.artisans import translate_story
from api.storage import get_storage

SEED = REPO_DIR / "seed"


def log(msg: str) -> None:
    print(f"[seed] {msg}", flush=True)


def user(db, phone: str, role: str, language: str = "hi", name: str | None = None) -> User:
    u = db.execute(select(User).where(User.phone_hash == lookup_hash(phone))).scalar_one_or_none()
    if not u:
        u = User(role=role, phone=phone, phone_hash=lookup_hash(phone), language=language, display_name=name)
        db.add(u)
        db.flush()
    return u


def register_audio_transcripts() -> None:
    """Make the mock ASR recognise the demo clips (a real deployment sends them to Bhashini instead)."""
    path = SEED / "audio" / "transcripts.json"
    known = {}
    for fname, text, lang in (("demo_blue_pottery_vase.wav", "Blue pottery vase, hand-painted", "hi"),
                              ("demo_answer_three_days.wav", "Three days. Materials cost three hundred rupees.", "en")):
        f = SEED / "audio" / fname
        if f.exists():
            known[hashlib.sha256(f.read_bytes()).hexdigest()] = {"text": text, "language": lang, "file": fname}
    path.write_text(json.dumps(known, ensure_ascii=False, indent=2), encoding="utf-8")


def seed(db) -> None:
    random.seed(7)
    data = json.loads((SEED / "demo_data.json").read_text(encoding="utf-8"))
    storage = get_storage()
    register_audio_transcripts()
    from scripts.seed_images import generate

    generate(data["products"])

    admin = user(db, data["users"]["admin"]["phone"], "admin", "en", data["users"]["admin"]["name"])
    buyer = user(db, data["users"]["buyer"]["phone"], "buyer", "en", data["users"]["buyer"]["name"])
    ops = {}
    for o in data["operators"]:
        u = user(db, o["phone"], "operator", "hi", o["name"])
        op = Operator(user_id=u.id, kind=o["kind"], name=o["name"], csc_id=o.get("csc_id"), shg_id=o.get("shg_id"),
                      region=o["region"])
        db.add(op)
        db.flush()
        ops[o["key"]] = op

    artisans = {}
    for a in data["artisans"]:
        u = user(db, a["phone"], "artisan", a["language"], a["name"])
        created = now() - timedelta(days=10 if a.get("new_artisan") else random.randint(120, 400))
        art = Artisan(
            user_id=u.id, name=a["name"], name_native=a["name_native"], village=a["village"], district=a["district"],
            state=a["state"], craft_type=a["craft_type"], years_practice=a["years_practice"], gender=a["gender"],
            cluster=a["cluster"], gi_tag=a.get("gi_tag"), pehchan_id=a.get("pehchan_id"),
            pehchan_verified=bool(a.get("pehchan_id") and a["verified"]),
            verification_status="verified" if a["verified"] else "pending", story_text=a["story_text"],
            consent_flags={"voice": True, "photo": True, "location": True, "recorded_at": created.isoformat()},
            onboarded_by_operator_id=ops[a["operator"]].id if a.get("operator") else None,
            operator_attestation="Identity checked against Pehchan card; spoken consent recorded at kiosk"
            if a.get("operator") else None,
            created_at=created,
        )
        db.add(art)
        db.flush()
        translate_story(db, art, a["language"])
        artisans[a["key"]] = art
    db.commit()
    log(f"{len(artisans)} artisans, {len(ops)} operators")

    try:
        pricing_service.active_market_model(db)  # bootstrap market-v1
        db.commit()
    except (ImportError, OSError) as e:  # ML runtime blocked on this machine: fair-wage pricing still works
        db.rollback()
        log(f"market model unavailable ({e}); pricing from fair-wage cost only")

    t0 = time.time()
    products = {}
    for i, spec in enumerate(data["products"]):
        art = artisans[spec["artisan"]]
        captured = now() - timedelta(days=random.randint(3, 60), hours=random.randint(0, 20))
        p = Product(artisan_id=art.id, language=spec["language"], status="queued",
                    idempotency_key=f"seed-{spec['slug']}", captured_offline_at=captured if i % 3 == 0 else None,
                    created_via="kiosk" if art.onboarded_by_operator_id else "app",
                    operator_id=art.onboarded_by_operator_id,
                    # offline captures reach the server hours later, when the phone finds network
                    created_at=captured + timedelta(hours=random.randint(2, 30)) if i % 3 == 0 else captured,
                    attributes={"device_transcript": None if spec.get("audio") else spec["transcript"],
                                "answers": spec.get("answers", []),
                                # real photos already have a natural setting; drawn stand-ins get the cut-out look
                                "keep_background": bool(spec["image"].get("photo"))})
        db.add(p)
        db.flush()
        img = (SEED / "images" / f"{spec['slug']}.jpg").read_bytes()
        key = f"captures/seed/{spec['slug']}.jpg"
        storage.put(key, img, "image/jpeg")
        db.add(ProductMedia(product_id=p.id, kind="original", url=key, sha256=sha256_bytes(img), position=0))
        if spec.get("audio"):
            audio = (SEED / "audio" / spec["audio"]).read_bytes()
            akey = f"captures/seed/{spec['audio']}"
            storage.put(akey, audio, "audio/wav")
            db.add(ProductMedia(product_id=p.id, kind="audio", url=akey, sha256=sha256_bytes(audio)))
        db.add(SyncJob(device_id=f"seed-device-{spec['artisan']}", idempotency_key=p.idempotency_key,
                       result_ref=p.id, status="done"))
        db.commit()
        pipeline.run(db, p.id)
        db.refresh(p)
        demo = spec.get("demo")
        if demo:
            p.title = demo["title"]
            p.short_title = demo["title"]
            p.device_edited_fields = {"title": demo["title"]}
            p.translations = {**p.translations, "en": {**p.translations.get("en", {}), "title": demo["title"]},
                              "hi": {**p.translations.get("hi", {}), "title": "हाथ से चित्रित पॉटरी फूलदान"}}
            q = pricing_service.adjust_price(db, p, demo["price"], source="seed")
            q.breakdown = {**q.breakdown, "compare_at": demo["compare_at"]}
            p.compare_at_price = demo["compare_at"]
            spec["rating"] = [demo["rating"], demo["reviews"]]
        if spec.get("rating"):
            p.rating_avg, p.rating_count = spec["rating"]
            p.attributes = {**p.attributes, "seed_rating": spec["rating"][0], "seed_reviews": spec["rating"][1]}
        target = spec.get("status", "live")
        if target == "live":
            p.quantity = max(p.quantity, random.choice([1, 2, 3, 5]))
            publishing.publish(db, p, art.user_id)
            p.published_at = p.created_at + timedelta(minutes=random.randint(2, 40))
        db.commit()
        products[spec["slug"]] = p
        log(f"  {i + 1:2d}/{len(data['products'])} {p.status:12s} ₹{p.price or 0:>7,.0f}  {p.title}")
    log(f"pipeline for {len(products)} products in {time.time() - t0:.0f}s")

    # ONDC catalog sync for everything live
    from ondc_adapter.bpp import sync_product

    for p in products.values():
        if p.status == "live":
            sync_product(db, p)
    db.commit()

    # Marketplace history: views / carts feed the learning loop
    live = [p for p in products.values() if p.status == "live"]
    for p in live:
        views = random.randint(20, 160) + (p.rating_count or 0)
        for _ in range(views):
            db.add(Event(type="view", product_id=p.id, ts=now() - timedelta(hours=random.randint(1, 700))))
        for _ in range(views // random.randint(8, 15)):
            db.add(Event(type="add_to_cart", product_id=p.id, ts=now() - timedelta(hours=random.randint(1, 700))))
    db.commit()

    # Orders: three delivered this month for Meena (payout ledger demo), others across clusters, one waiting
    addr = {"name": "Asha Rao", "phone": "9000000001", "line1": "12 MG Road", "city": "Bengaluru",
            "state": "Karnataka", "pincode": "560001"}
    delivered = ["meena-plate", "meena-bowl", "meena-tile", "rina-saree-red", "sukhmati-horse", "gopal-vase",
                 "anjali-kantha-stole", "haripada-saree"]
    for slug in delivered:
        p = products[slug]
        p.quantity += 1
        o, _ = O.create_order(db, buyer.id, [(p.id, 1)], addr, payment_method="upi")
        db.query(Payment).filter_by(order_id=o.id).update({"status": "paid"})
        for st in ("accepted", "packed", "shipped", "delivered"):
            O.transition(db, o, st, art.user_id if (art := p.artisan) else None, "seed")
        db.commit()
    pending = products["gopal-bowls"]
    O.create_order(db, buyer.id, [(pending.id, 1)], {**addr, "city": "Pune", "state": "Maharashtra"}, "cod")
    db.commit()
    from ondc_adapter import mock_gateway

    mock_gateway.buyer_order(mock_gateway.BuyerOrder(product_id=products["sukhmati-elephant"].id), db)
    log("orders: 8 delivered, 1 awaiting artisan, 1 via ONDC")

    for c in data["clusters"]:
        db.add(SchemeLink(scheme=c["scheme"], cluster=c["name"], note=f"{c['gi']} cluster"))
    db.commit()

    from workers.jobs import retrain_ranking

    retrain_ranking(db)
    db.commit()
    log("ranking scores computed (fairness boost active for new artisans)")
    log("demo logins (OTP is shown on screen in mock SMS mode):")
    log(f"  admin    {data['users']['admin']['phone']}")
    log(f"  buyer    {data['users']['buyer']['phone']}")
    log(f"  artisan  {data['artisans'][0]['phone']}  (Meena Devi, Hindi)")
    log(f"  kiosk    {data['operators'][0]['phone']}  (CSC Sanganer)")


def main(argv=None) -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--reset", action="store_true")
    ap.add_argument("--if-empty", action="store_true")
    args = ap.parse_args(argv)
    s = get_settings()
    engine = get_engine()
    if args.reset:
        if not s.database_url.startswith("sqlite"):
            sys.exit("--reset is only allowed for the SQLite dev database")
        Base.metadata.drop_all(engine)
        for sub in ("media", "models"):
            import shutil

            shutil.rmtree(s.data_dir / sub, ignore_errors=True)
    if s.database_url.startswith("sqlite"):
        Base.metadata.create_all(engine)
    db = session_factory()()
    try:
        if db.execute(select(func.count()).select_from(Artisan)).scalar_one() > 0:
            if args.if_empty:
                log("database already seeded — skipping")
                return
            sys.exit("database is not empty (use --reset for SQLite dev)")
        seed(db)
        log("done")
    finally:
        db.close()


if __name__ == "__main__":
    main()
