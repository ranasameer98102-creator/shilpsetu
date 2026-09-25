import copy
from types import SimpleNamespace

from api import certs


def _cert(payload):
    sig, digest = certs.sign(payload)
    return SimpleNamespace(id="c1", payload=payload, signature=sig, sha256=digest, revoked_at=None,
                           qr_url=certs.verify_url("c1", sig))


PAYLOAD = {"v": 1, "certificate_id": "c1", "listing_id": "p1",
           "product": {"title": "Hand-painted Pottery Vase", "category": "Pottery & Ceramics"},
           "artisan": {"id": "a1", "name": "Meena Devi", "name_native": "मीना देवी", "photo": None,
                       "pehchan_verified": True, "verified": True, "shg": None},
           "craft": "Blue Pottery", "cluster": "Jaipur", "gi": "Jaipur Blue Pottery",
           "location": "Jaipur, Rajasthan • GI-linked cluster", "materials": ["Quartz"], "story": "कहानी",
           "story_audio": False,
           "fair_price": {"price": 1450, "artisan_share_amount": 1217, "artisan_share_pct": 83.9, "basis": [],
                          "model_version": "market-v1"},
           "created_at": "2026-09-01T00:00:00+00:00", "original_photo_sha256": "ab" * 32,
           "issued_at": "2026-09-02T00:00:00+00:00", "issuer": "ShilpSetu", "key_id": "k"}


def test_sign_and_verify_roundtrip():
    c = _cert(copy.deepcopy(PAYLOAD))
    assert certs.verify_signature(c.payload, c.signature)
    assert certs.check(c, True, c.signature) == {"valid": True, "reasons": []}


def test_tampered_payload_is_detected():
    c = _cert(copy.deepcopy(PAYLOAD))
    c.payload["fair_price"]["artisan_share_amount"] = 5000  # someone edits the record
    r = certs.check(c, True, c.signature)
    assert not r["valid"] and "signature_invalid" in r["reasons"] and "record_hash_mismatch" in r["reasons"]


def test_qr_from_another_certificate_is_rejected():
    c1 = _cert(copy.deepcopy(PAYLOAD))
    other = copy.deepcopy(PAYLOAD)
    other["certificate_id"] = "c2"
    c2 = _cert(other)
    assert "qr_signature_mismatch" in certs.check(c1, True, c2.signature)["reasons"]


def test_revoked_certificate_is_invalid():
    c = _cert(copy.deepcopy(PAYLOAD))
    c.revoked_at = "2026-09-10"
    assert certs.check(c, True, None)["reasons"] == ["revoked"]


def test_canonical_is_key_order_independent():
    a = {"b": 1, "a": {"y": 2, "x": 1}}
    b = {"a": {"x": 1, "y": 2}, "b": 1}
    assert certs.canonical(a) == certs.canonical(b)


def test_verify_with_published_public_key_only():
    c = _cert(copy.deepcopy(PAYLOAD))
    assert certs.verify_signature(c.payload, c.signature, public_key=certs.public_key_bytes())


def test_pdf_a6_and_label():
    c = _cert(copy.deepcopy(PAYLOAD))
    assert certs.pdf(c, "a6").startswith(b"%PDF")
    assert certs.pdf(c, "label").startswith(b"%PDF")
    assert len(certs.pdf_many([c, c], "label")) > len(certs.pdf(c, "label"))  # one page per tag


def test_qr_png():
    assert certs.qr_png("http://x/v/c1?s=abc").startswith(b"\x89PNG")
