"""Integration: the whole 'Craft to Cart in 5 steps' journey with mock providers, then buyer -> order -> payout."""
from datetime import datetime, timedelta, timezone

from conftest import capture_listing, login, make_admin, new_artisan


def test_five_step_flow_to_payout(client):
    # Onboard (OTP) + profile with consent
    h = new_artisan(client, "+919811111111")

    # 1 Speak + 2 Snap (captured offline an hour ago, synced now)
    offline_at = (datetime.now(timezone.utc) - timedelta(hours=1)).isoformat()
    p = capture_listing(client, h, "नीली पॉटरी का फूलदान, हाथ से पेंट किया, तीन दिन लगे, सामान 300 रुपये का",
                        offline_at=offline_at)

    # 3 AI Builds It
    assert p["status"] == "ready", p["needs_review_fields"]
    steps = {s["key"]: s["status"] for s in p["pipeline"]["steps"]}
    assert all(v == "done" for v in steps.values()), steps
    assert p["title"] == "Hand-painted Blue Pottery Vase"
    assert p["category"] == "Pottery & Ceramics"
    assert {"en", "hi"} <= set(p["translations"])
    assert {m["kind"] for m in p["media"]} >= {"original", "enhanced", "enhanced_4x5", "thumb", "audio"}
    q = p["price_quote"]
    assert q["final_price"] >= q["fair_floor"] and q["artisan_share_pct"] > 70

    # change price by voice, then 4 You Approve (one tap)
    q2 = client.post(f"/api/v1/products/{p['id']}/price", headers=h, json={"spoken": "make it 4,200"}).json()
    assert q2["final_price"] == 4200
    live = client.post(f"/api/v1/products/{p['id']}/approve", headers=h).json()
    assert live["status"] == "live" and live["certificate"]["qr_url"].startswith("http://testserver/v/")

    # 5 Goes Live: storefront + ONDC
    feed = client.get("/api/v1/storefront/feed").json()
    assert any(i["id"] == p["id"] for s in feed["sections"] for i in s["items"])
    detail = client.get(f"/api/v1/storefront/products/{p['id']}").json()
    assert detail["price"] == 4200 and detail["price_quote"]["breakdown"]
    assert "inputs" not in detail["price_quote"]
    cert_id = live["certificate"]["id"]
    sig = live["certificate"]["qr_url"].split("s=")[1]
    v = client.get(f"/api/v1/certificates/{cert_id}/verify?s={sig}").json()
    assert v["valid"], v
    page = client.get(f"/v/{cert_id}?s={sig}")
    assert page.status_code == 200 and "Verified" in page.text and "Meena Devi" in page.text

    # Buyer: cart -> checkout (UPI mock) -> pay
    b = login(client, "+919822222222", "buyer", "en")
    client.post("/api/v1/cart", headers=b, json={"product_id": p["id"], "quantity": 1})
    co = client.post("/api/v1/checkout", headers=b, json={"address": {
        "name": "Asha", "phone": "9822222222", "line1": "12 MG Road", "city": "Pune", "state": "Maharashtra",
        "pincode": "411001"}, "payment_method": "upi"}).json()
    order_id = co["order"]["id"]
    sim = client.post(f"/api/v1/payments/mock/{co['payment']['id']}/pay").json()
    assert client.post("/api/v1/payments/confirm", headers=b, json=sim).json()["status"] == "paid"

    # Artisan got SMS + IVR in Hindi, accepts by replying "1"
    admin = make_admin("+919800000001")
    notes = client.get("/api/v1/admin/notifications", headers=admin).json()
    new_order = [n for n in notes if n["template"] == "new_order"]
    assert {n["channel"] for n in new_order} == {"sms", "ivr"} and "नया ऑर्डर" in new_order[0]["body"] + new_order[1]["body"]
    r = client.post("/api/v1/notify/sms/incoming", data={"From": "+919811111111", "Body": "1"}).json()
    assert r["outcome"] == "accepted"

    # pack -> ship -> delivered (courier webhook) -> payout ledger
    for s in ("packed", "shipped"):
        assert client.post(f"/api/v1/orders/{order_id}/status", headers=h, json={"status": s}).status_code == 200
    delivered = client.post(f"/api/v1/orders/{order_id}/courier-delivered", headers=admin).json()
    assert delivered["status"] == "delivered" and delivered["tracking"]["awb"]
    ledger = client.get("/api/v1/artisans/me/ledger", headers=h).json()
    t = ledger["totals"]
    assert t["gross"] == 4200
    assert t["net"] == round(4200 - t["commission"] - t["logistics"], 2)
    assert t["net"] == ledger["payouts"][0]["net"]
    assert abs(t["net"] - q2["artisan_share_amount"]) < 0.01  # what we promised at listing is what was paid

    # Buyer reviews after delivery
    item_id = client.get(f"/api/v1/orders/{order_id}", headers=b).json()["items"][0]["id"]
    rv = client.post("/api/v1/reviews", headers=b, json={"order_item_id": item_id, "rating": 5, "text": "Beautiful"})
    assert rv.status_code == 200 and rv.json()["rating_count"] >= 1

    # IVR: Hindi (1) -> hear earnings (2)
    ivr = client.post("/api/v1/notify/ivr/simulate", headers=admin, json={"phone": "+919811111111", "digits": "12"}).json()
    assert "कमाए" in ivr["transcript"][-1]["prompts"][0]

    # Dashboard spoken summary + analytics + audit chain + learning loop
    dash = client.get("/api/v1/artisans/me/dashboard", headers=h).json()
    assert dash["earned_this_month"] > 0
    an = client.get("/api/v1/admin/analytics", headers=admin).json()
    assert an["orders"] >= 1 and an["offline_sync_health"]["captured_offline"] >= 1
    assert client.get("/api/v1/admin/audit", headers=admin).json()["chain_valid"]
    rt = client.post("/api/v1/admin/models/retrain", headers=admin).json()
    assert rt["market"].startswith("market-v") and rt["ranking_trained_on"]["products"] >= 1
    models = client.get("/api/v1/admin/models", headers=admin).json()
    assert any(m["id"] == rt["market"] and m["active"] for m in models)


def test_needs_review_when_ai_cannot_understand(client):
    h = new_artisan(client, "+919811111112")
    p = capture_listing(client, h, "", with_audio=False)
    assert p["status"] == "needs_review"
    assert "transcript" in p["needs_review_fields"] or "category" in p["needs_review_fields"]
    assert p["id"]  # capture is never lost


def test_follow_up_questions_then_answers(client):
    h = new_artisan(client, "+919811111113")
    p = capture_listing(client, h, "नीली पॉटरी का फूलदान")
    assert [q["field"] for q in p["pipeline"]["questions"]] == ["time_hours", "material_cost"]
    assert "price_inputs" in p["needs_review_fields"]
    client.post(f"/api/v1/products/{p['id']}/answers", headers=h,
                json=[{"field": "time_hours", "text": "दो दिन"}, {"field": "material_cost", "text": "दो सौ"}])
    p2 = client.get(f"/api/v1/products/{p['id']}", headers=h).json()
    assert p2["pipeline"]["questions"] == []
    assert p2["price_quote"]["inputs"]["estimated_fields"] == []


def test_kiosk_operator_captures_for_artisan(client):
    admin = make_admin("+919800000001")
    r = client.post("/api/v1/admin/operators", headers=admin, json={
        "phone": "+919833333333", "name": "CSC Sanganer", "kind": "csc", "csc_id": "CSC-RJ-114"})
    assert r.status_code == 200, r.text
    op = login(client, "+919833333333", "operator", "hi")
    client.patch("/api/v1/operators/me", headers=op, json={"name": "CSC Sanganer", "csc_id": "CSC-RJ-114"})
    a = client.post("/api/v1/operators/artisans", headers=op, json={
        "name": "Kamla Bai", "state": "Rajasthan", "craft_type": "Blue pottery", "gender": "female",
        "attestation": "Identity checked with Pehchan card; consent recorded in Hindi",
        "consent": {"voice": True, "photo": True, "location": False}}).json()
    oh = {**op, "X-Artisan-Id": a["id"]}
    p = capture_listing(client, oh, "blue pottery plate hand painted, one day")
    assert p["created_via"] == "kiosk"
    live = client.post(f"/api/v1/products/{p['id']}/approve", headers=oh).json()
    assert live["status"] == "live"
    pdf = client.get(f"/api/v1/operators/tags.pdf?product_ids={p['id']}", headers=op)
    assert pdf.status_code == 200 and pdf.content.startswith(b"%PDF")
    assert client.get("/api/v1/operators/stats", headers=op).json()["products_captured"] == 1
    # an operator cannot act for artisans they did not onboard
    other = client.get("/api/v1/products/mine", headers={**op, "X-Artisan-Id": "nope"})
    assert other.status_code == 403


def test_dpdp_export_and_delete(client):
    h = new_artisan(client, "+919811111114")
    capture_listing(client, h, "bamboo basket")
    exp = client.get("/api/v1/artisans/me/export", headers=h).json()
    assert exp["artisan"]["name"] == "Meena Devi" and exp["products"]
    assert client.delete("/api/v1/artisans/me", headers=h).json()["deleted"]
    assert client.get("/api/v1/artisans/me", headers=h).status_code == 401
