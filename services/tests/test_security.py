"""Regression tests for access-control and abuse fixes."""
import uuid

from conftest import capture_listing, login, make_admin, new_artisan, photo_bytes, upload, wav_bytes


def _order_for(client, artisan_phone: str, buyer_phone: str) -> tuple[str, dict]:
    h = new_artisan(client, artisan_phone)
    p = capture_listing(client, h, "blue pottery bowl, one day, materials 100 rupees")
    client.post(f"/api/v1/products/{p['id']}/approve", headers=h)
    b = login(client, buyer_phone, "buyer", "en")
    client.post("/api/v1/cart", headers=b, json={"product_id": p["id"], "quantity": 1})
    o = client.post("/api/v1/checkout", headers=b, json={"address": {
        "name": "A", "phone": "9", "line1": "x", "city": "Pune", "state": "Maharashtra", "pincode": "411001"},
        "payment_method": "cod"}).json()["order"]
    return o["id"], h


def test_courier_webhook_requires_token_or_admin(client):
    oid, h = _order_for(client, "+919855550001", "+919855550002")
    for s in ("accepted", "packed", "shipped"):
        client.post(f"/api/v1/orders/{oid}/status", headers=h, json={"status": s})
    assert client.post(f"/api/v1/orders/{oid}/courier-delivered").status_code == 403
    assert client.post(f"/api/v1/orders/{oid}/courier-delivered", headers=h).status_code == 403
    assert client.post(f"/api/v1/orders/{oid}/courier-delivered", headers=make_admin("+919800000001")).status_code == 200


def test_ivr_simulator_is_admin_only(client):
    body = {"phone": "+919855550001", "digits": "12"}
    assert client.post("/api/v1/notify/ivr/simulate", json=body).status_code == 401
    buyer = login(client, "+919855550003", "buyer", "en")
    assert client.post("/api/v1/notify/ivr/simulate", headers=buyer, json=body).status_code == 403


def test_operator_cannot_self_register(client):
    code = client.post("/api/v1/auth/otp/request", json={"phone": "+919855550004"}).json()["dev_otp"]
    r = client.post("/api/v1/auth/otp/verify", json={"phone": "+919855550004", "code": code, "role": "operator"})
    assert r.status_code == 403


def test_operator_only_touches_orders_of_their_artisans(client):
    oid, _ = _order_for(client, "+919855550005", "+919855550006")
    admin = make_admin("+919800000001")
    client.post("/api/v1/admin/operators", headers=admin, json={"phone": "+919855550007", "name": "Other CSC"})
    op = login(client, "+919855550007", "operator", "hi")
    assert client.get(f"/api/v1/orders/{oid}", headers=op).status_code == 403
    assert client.post(f"/api/v1/orders/{oid}/status", headers=op, json={"status": "accepted"}).status_code == 403


def test_otp_requests_are_rate_limited(client):
    codes = [client.post("/api/v1/auth/otp/request", json={"phone": "+919855550008"}).status_code for _ in range(6)]
    assert codes[:5] == [200] * 5 and codes[5] == 429


def test_unknown_audio_asks_what_the_item_is(client):
    """Mock ASR must not invent a product for audio it cannot recognise."""
    h = new_artisan(client, "+919855550009")
    body = {"idempotency_key": uuid.uuid4().hex, "device_id": "d", "language": "hi",
            "audio_upload_id": upload(client, h, wav_bytes(seed=99), "audio", "audio/wav"),
            "photo_upload_ids": [upload(client, h, photo_bytes(), "photo", "image/jpeg")]}
    pid = client.post("/api/v1/products/drafts", headers=h, json=body).json()["id"]
    p = client.get(f"/api/v1/products/{pid}", headers=h).json()
    assert p["transcript"] == "" and "transcript" in p["needs_review_fields"]
    assert p["pipeline"]["questions"][0]["field"] == "product_type"
    client.post(f"/api/v1/products/{pid}/answers", headers=h, json=[{"field": "product_type", "text": "नीली पॉटरी का फूलदान"}])
    p = client.get(f"/api/v1/products/{pid}?lang=hi", headers=h).json()
    assert p["category"] == "Pottery & Ceramics" and "फूलदान" in p["title"]


def test_media_links_follow_the_host_the_client_used(client):
    feed = client.get("/api/v1/storefront/feed", headers={"Host": "192.168.1.50:8000"}).json()
    item = feed["sections"][0]["items"][0]
    assert item["thumb"].startswith("http://192.168.1.50:8000/media/")


def test_admin_otp_hidden_on_public_server(client, monkeypatch):
    from api.config import get_settings

    make_admin("+919855550030")
    monkeypatch.setattr(get_settings(), "show_admin_otp", False)
    assert client.post("/api/v1/auth/otp/request", json={"phone": "+919855550030"}).json()["dev_otp"] is None
    assert client.post("/api/v1/auth/otp/request", json={"phone": "+919855550031"}).json()["dev_otp"]


def test_listing_priced_when_market_model_unavailable(client, monkeypatch):
    from api.domain import pricing_service

    def blocked(db):
        raise ImportError("DLL load failed")

    monkeypatch.setattr(pricing_service, "active_market_model", blocked)
    h = new_artisan(client, "+919855550040")
    p = capture_listing(client, h, "blue pottery bowl, one day, materials 100 rupees")
    assert p["price"] > 0


def test_artisan_can_shop_but_not_buy_own_product(client):
    seller = new_artisan(client, "+919855550050")
    p = capture_listing(client, seller, "blue pottery bowl, one day, materials 100 rupees")
    client.post(f"/api/v1/products/{p['id']}/approve", headers=seller)
    shopper = new_artisan(client, "+919855550051")
    assert client.post("/api/v1/cart", headers=shopper, json={"product_id": p["id"], "quantity": 1}).status_code == 200
    assert len(client.get("/api/v1/cart", headers=shopper).json()["items"]) == 1
    assert client.get("/api/v1/orders", headers=shopper).status_code == 200
    assert client.post("/api/v1/cart", headers=seller, json={"product_id": p["id"], "quantity": 1}).status_code == 409
