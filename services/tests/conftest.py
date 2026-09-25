import io
import os
import struct
import sys
import tempfile
import uuid
import wave
from pathlib import Path

import pytest

_tmp = Path(tempfile.mkdtemp(prefix="shilpsetu-test-"))
os.environ.update({
    "ENV": "test",
    "DATABASE_URL": f"sqlite:///{(_tmp / 'test.db').as_posix()}",
    "DATA_DIR": str(_tmp),
    "JOB_MODE": "sync",
    "PUBLIC_BASE_URL": "http://testserver",
    "BACKGROUND_REMOVAL": "grabcut",
    "JWT_SECRET": "test-secret-0123456789-abcdefghijklmnopqrstuvwxyz",
})
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from fastapi.testclient import TestClient  # noqa: E402

from api.main import app  # noqa: E402


@pytest.fixture(scope="session")
def client():
    with TestClient(app) as c:
        yield c


def login(client, phone: str, role: str = "artisan", language: str = "hi") -> dict:
    r = client.post("/api/v1/auth/otp/request", json={"phone": phone, "language": language})
    assert r.status_code == 200, r.text
    code = r.json()["dev_otp"]
    r = client.post("/api/v1/auth/otp/verify", json={"phone": phone, "code": code, "role": role, "language": language})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


def make_admin(phone: str) -> dict:
    from api.crypto import lookup_hash
    from api.db import session_factory
    from api.models import User
    from api.routers.auth import normalize_phone
    from api.security import create_token

    db = session_factory()()
    p = normalize_phone(phone)
    u = db.query(User).filter_by(phone_hash=lookup_hash(p)).one_or_none()
    if not u:
        u = User(role="admin", phone=p, phone_hash=lookup_hash(p), language="en")
        db.add(u)
        db.commit()
    tok = create_token(u)
    db.close()
    return {"Authorization": f"Bearer {tok}"}


def photo_bytes(seed: int = 1) -> bytes:
    import cv2
    import numpy as np

    rng = np.random.default_rng(seed)
    img = cv2.GaussianBlur(rng.integers(40, 90, (480, 640, 3)).astype("uint8"), (9, 9), 0)
    cv2.ellipse(img, (320, 260), (90, 130), 0, 0, 360, (150, 60, 20), -1)
    return cv2.imencode(".jpg", img)[1].tobytes()


def wav_bytes(seconds: float = 0.4, seed: int = 0) -> bytes:
    buf = io.BytesIO()
    with wave.open(buf, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(16000)
        n = int(16000 * seconds)
        w.writeframes(b"".join(struct.pack("<h", ((i * (seed + 3)) % 200) - 100) for i in range(n)))
    return buf.getvalue()


def upload(client, headers, data: bytes, kind: str, ctype: str, chunk: int = 64 * 1024) -> str:
    """Resumable upload exactly as the mobile app does it."""
    import hashlib

    key = uuid.uuid4().hex
    r = client.post("/api/v1/capture/uploads", headers=headers, json={
        "idempotency_key": key, "kind": kind, "content_type": ctype, "total_size": len(data),
        "sha256": hashlib.sha256(data).hexdigest()})
    assert r.status_code == 200, r.text
    uid = r.json()["upload_id"]
    off = 0
    while off < len(data):
        r = client.put(f"/api/v1/capture/uploads/{uid}?offset={off}", headers=headers, content=data[off:off + chunk])
        assert r.status_code == 200, r.text
        off = r.json()["received"]
    r = client.post(f"/api/v1/capture/uploads/{uid}/complete", headers=headers)
    assert r.status_code == 200, r.text
    return uid


PROFILE = {
    "name": "Meena Devi", "name_native": "मीना देवी", "village": "Sanganer", "district": "Jaipur",
    "state": "Rajasthan", "craft_type": "Blue pottery", "years_practice": 18, "gender": "female",
    "story_text": "मैं अठारह साल से नीली पॉटरी बना रही हूँ। यह कला मैंने अपनी माँ से सीखी।",
    "cluster": "Jaipur Blue Pottery Cluster", "gi_tag": "Jaipur Blue Pottery", "pehchan_id": "RJ-0412-3381",
    "consent": {"voice": True, "photo": True, "location": True},
}


def new_artisan(client, phone: str, profile: dict | None = None, language: str = "hi") -> dict:
    h = login(client, phone, "artisan", language)
    r = client.put("/api/v1/artisans/me", headers=h, json=profile or PROFILE)
    assert r.status_code == 200, r.text
    return h


def capture_listing(client, h, transcript: str, language: str = "hi", key: str | None = None,
                    offline_at: str | None = None, with_audio: bool = True, extra: dict | None = None) -> dict:
    photo = upload(client, h, photo_bytes(), "photo", "image/jpeg")
    body = {"idempotency_key": key or uuid.uuid4().hex, "device_id": "test-device", "language": language,
            "photo_upload_ids": [photo], "device_transcript": transcript, "captured_offline_at": offline_at}
    if with_audio:
        body["audio_upload_id"] = upload(client, h, wav_bytes(), "audio", "audio/wav")
    body.update(extra or {})
    r = client.post("/api/v1/products/drafts", headers=h, json=body)
    assert r.status_code == 200, r.text
    return client.get(f"/api/v1/products/{r.json()['id']}", headers=h).json()
