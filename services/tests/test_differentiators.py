"""One test per row of the differentiator table (§5): each ✓ is a real, testable feature."""
import uuid
from datetime import datetime, timedelta, timezone

from conftest import capture_listing, make_admin, new_artisan, photo_bytes, upload, wav_bytes


def test_works_without_typing_voice_first(client, monkeypatch, tmp_path):
    """Only audio + photo, no text fields at all -> complete listing with title, category and price."""
    import hashlib
    import json

    from ai import speech

    h = new_artisan(client, "+919844440001")
    # The mock ASR recognises known clips by hash (stand-in for Bhashini transcribing a real clip).
    audio = wav_bytes(seconds=0.5, seed=42)
    seed_file = tmp_path / "transcripts.json"
    seed_file.write_text(json.dumps({hashlib.sha256(audio).hexdigest(): {
        "text": "नीली पॉटरी का फूलदान, हाथ से पेंट किया हुआ", "language": "hi"}}, ensure_ascii=False), encoding="utf-8")
    monkeypatch.setattr(speech, "SEED_TRANSCRIPTS", seed_file)
    speech._seed_transcripts.cache_clear()
    body = {"idempotency_key": uuid.uuid4().hex, "device_id": "d", "language": "hi",
            "audio_upload_id": upload(client, h, audio, "audio", "audio/wav"),
            "photo_upload_ids": [upload(client, h, photo_bytes(), "photo", "image/jpeg")]}
    pid = client.post("/api/v1/products/drafts", headers=h, json=body).json()["id"]
    p = client.get(f"/api/v1/products/{pid}", headers=h).json()
    assert p["transcript"].startswith("नीली पॉटरी")
    assert p["title"] and p["category"] == "Pottery & Ceramics" and p["price"] > 0
    # the artisan hears follow-up questions in their language instead of typing
    assert all("?" in q["text"] for q in p["pipeline"]["questions"])


def test_shows_how_the_price_is_built(client):
    h = new_artisan(client, "+919844440002")
    p = capture_listing(client, h, "handloom cotton saree, seven days, materials 800 rupees")
    client.post(f"/api/v1/products/{p['id']}/approve", headers=h)
    pub = client.get(f"/api/v1/pricing/{p['id']}").json()
    lines = {l["key"]: l for l in pub["breakdown"]}
    assert {"materials", "labour", "platform_fee", "logistics"} <= set(lines)
    assert abs(sum(l["amount"] for l in pub["breakdown"]) - pub["final_price"]) < 0.05
    assert lines["labour"]["amount"] == 56 * 95.0  # 7 days x 8h x West Bengal fair wage floor
    detail = client.get(f"/api/v1/storefront/products/{p['id']}").json()
    assert detail["price_quote"]["artisan_share_amount"] > 0 and detail["compare_at_price"] > detail["price"]


def test_per_item_certificate(client):
    h = new_artisan(client, "+919844440003")
    ids = []
    for t in ("blue pottery bowl", "blue pottery tile"):
        p = capture_listing(client, h, t)
        ids.append(client.post(f"/api/v1/products/{p['id']}/approve", headers=h).json()["certificate"]["id"])
    assert len(set(ids)) == 2
    for cid in ids:
        v = client.get(f"/api/v1/certificates/{cid}/verify").json()
        assert v["valid"] and v["certificate"]["payload"]["artisan"]["name"] == "Meena Devi"
    assert not client.get(f"/api/v1/certificates/{ids[0]}/verify?s=forged").json()["valid"]


def test_works_offline_low_connectivity(client):
    """Captured with airplane mode on (hours earlier), synced later over small chunks, retried twice."""
    h = new_artisan(client, "+919844440004")
    key = uuid.uuid4().hex
    captured = (datetime.now(timezone.utc) - timedelta(hours=20)).isoformat()
    photo = upload(client, h, photo_bytes(3), "photo", "image/jpeg", chunk=4096)  # 2G-sized chunks
    body = {"idempotency_key": key, "device_id": "phone-1", "language": "hi", "photo_upload_ids": [photo],
            "device_transcript": "हथकरघा दुपट्टा", "captured_offline_at": captured}
    first = client.post("/api/v1/products/drafts", headers=h, json=body).json()
    retry = client.post("/api/v1/products/drafts", headers=h, json=body).json()
    assert first["id"] == retry["id"]
    st = client.get(f"/api/v1/sync/status?device_id=phone-1&keys={key}", headers=h).json()
    assert st[key]["status"] in ("ready", "needs_review")
    p = client.get(f"/api/v1/products/{first['id']}", headers=h).json()
    assert p["attributes"]["asr"]["provider"] == "on-device"


def test_understands_vernacular_languages(client):
    h = new_artisan(client, "+919844440005", {
        "name": "Rina Das", "name_native": "রিনা দাস", "state": "West Bengal", "village": "Phulia",
        "gender": "female", "consent": {"voice": True, "photo": True, "location": True}}, language="bn")
    p = capture_listing(client, h, "ফুলিয়া তাঁতের সুতি শাড়ি, লাল আর সাদা, সাত দিন লেগেছে, উপকরণে ৮০০ টাকা খরচ",
                        language="bn")
    assert p["category"] == "Textiles & Handloom"
    ex = p["attributes"]["extraction"]
    assert ex["time_hours"] == 56 and ex["material_cost"] == 800
    assert {"bn", "en", "hi"} <= set(p["translations"])
    assert "শাড়ি" in p["translations"]["bn"]["title"] and "साड़ी" in p["translations"]["hi"]["title"]
    ivr = client.post("/api/v1/notify/ivr/simulate", headers=make_admin("+919800000001"),
                      json={"phone": "+919844440005", "digits": "3"}).json()
    assert ivr["transcript"][-1]["language"] == "bn"


def test_publishes_straight_to_ondc(client):
    h = new_artisan(client, "+919844440006")
    p = capture_listing(client, h, "dhokra brass elephant, five days, materials 900 rupees")
    client.post(f"/api/v1/products/{p['id']}/approve", headers=h)
    found = client.post("/ondc-mock/buyer/api/search", json={"q": "elephant"}).json()
    items = [i for prov in found["catalog"]["bpp/providers"] for i in prov["items"]]
    item = next(i for i in items if i["id"] == p["id"])
    tags = {t["code"]: t["value"] for t in item["tags"][1]["list"]}
    assert tags["provenance_certificate"].startswith("http") and float(tags["artisan_share_pct"]) > 50
    res = client.post("/ondc-mock/buyer/api/order", json={"product_id": p["id"]}).json()
    assert res["order"]["state"] == "Created"
    assert res["callbacks"] == ["on_select", "on_init", "on_confirm"]
    st = client.get(f"/ondc-mock/buyer/api/status/{res['order']['id']}").json()
    assert st["order"]["state"] == "Created"
    orders = client.get("/api/v1/artisan/orders", headers=h).json()
    assert any(o["channel"] == "ondc" for o in orders)
