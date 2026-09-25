"""Offline queue <-> server: resumable chunked uploads, idempotent retries, checksum protection."""
import hashlib
import uuid

from conftest import capture_listing, new_artisan, photo_bytes, upload


def test_resume_after_connection_drop(client):
    h = new_artisan(client, "+919800000101")
    data = photo_bytes(7)
    key = uuid.uuid4().hex
    body = {"idempotency_key": key, "kind": "photo", "content_type": "image/jpeg", "total_size": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}
    uid = client.post("/api/v1/capture/uploads", headers=h, json=body).json()["upload_id"]
    client.put(f"/api/v1/capture/uploads/{uid}?offset=0", headers=h, content=data[:5000])
    # connection drops; the app restarts and asks the server where to resume (same idempotency key)
    st = client.post("/api/v1/capture/uploads", headers=h, json=body).json()
    assert st["upload_id"] == uid and st["received"] == 5000
    # a retried chunk that overlaps what the server already has is de-duplicated
    r = client.put(f"/api/v1/capture/uploads/{uid}?offset=4000", headers=h, content=data[4000:])
    assert r.json()["received"] == len(data)
    done = client.post(f"/api/v1/capture/uploads/{uid}/complete", headers=h).json()
    assert done["status"] == "complete"


def test_gap_is_rejected(client):
    h = new_artisan(client, "+919800000102")
    data = photo_bytes(8)
    uid = client.post("/api/v1/capture/uploads", headers=h, json={
        "idempotency_key": uuid.uuid4().hex, "kind": "photo", "content_type": "image/jpeg",
        "total_size": len(data)}).json()["upload_id"]
    r = client.put(f"/api/v1/capture/uploads/{uid}?offset=100", headers=h, content=data[100:200])
    assert r.status_code == 409


def test_checksum_mismatch_forces_reupload(client):
    h = new_artisan(client, "+919800000103")
    data = photo_bytes(9)
    uid = client.post("/api/v1/capture/uploads", headers=h, json={
        "idempotency_key": uuid.uuid4().hex, "kind": "photo", "content_type": "image/jpeg",
        "total_size": len(data), "sha256": "0" * 64}).json()["upload_id"]
    client.put(f"/api/v1/capture/uploads/{uid}?offset=0", headers=h, content=data)
    r = client.post(f"/api/v1/capture/uploads/{uid}/complete", headers=h)
    assert r.status_code == 422
    assert client.get(f"/api/v1/capture/uploads/{uid}", headers=h).json()["received"] == 0


def test_duplicate_draft_submission_creates_one_listing(client):
    h = new_artisan(client, "+919800000104")
    key = uuid.uuid4().hex
    p1 = capture_listing(client, h, "नीली पॉटरी का कटोरा", key=key)
    p2 = client.post("/api/v1/products/drafts", headers=h, json={
        "idempotency_key": key, "device_id": "test-device", "language": "hi", "device_transcript": "anything"}).json()
    assert p1["id"] == p2["id"]
    mine = client.get("/api/v1/products/mine", headers=h).json()
    assert len([p for p in mine if p["id"] == p1["id"]]) == 1


def test_sync_status_reports_each_queued_item(client):
    h = new_artisan(client, "+919800000105")
    k1, k2 = uuid.uuid4().hex, uuid.uuid4().hex
    capture_listing(client, h, "handloom cotton stole", key=k1)
    st = client.get(f"/api/v1/sync/status?device_id=test-device&keys={k1},{k2}", headers=h).json()
    assert st[k1]["status"] in ("ready", "needs_review") and k2 not in st


def test_device_edits_win_over_ai_reruns(client):
    h = new_artisan(client, "+919800000106")
    p = capture_listing(client, h, "नीली पॉटरी का फूलदान")
    client.patch(f"/api/v1/products/{p['id']}", headers=h, json={"title": "Meena's Morning Vase"})
    client.post(f"/api/v1/products/{p['id']}/answers", headers=h, json=[{"field": "time_hours", "text": "तीन दिन"}])
    after = client.get(f"/api/v1/products/{p['id']}", headers=h).json()
    assert after["title"] == "Meena's Morning Vase"  # device wins for artisan edits
    assert after["price_quote"]["inputs"]["hours_used"] == 24  # server wins for model outputs
