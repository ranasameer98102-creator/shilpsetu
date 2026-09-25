"""Beckn/ONDC HTTP signatures: BLAKE2b-512 body digest, Ed25519 signature in the Authorization header."""
from __future__ import annotations

import base64
import hashlib
import re
import time
from functools import lru_cache

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey
from cryptography.hazmat.primitives import serialization

from api.config import get_settings


@lru_cache
def private_key() -> Ed25519PrivateKey:
    s = get_settings()
    if s.ondc_signing_private_key:
        raw = base64.b64decode(s.ondc_signing_private_key)
        return Ed25519PrivateKey.from_private_bytes(raw[:32])
    path = s.data_dir / "keys" / "ondc_ed25519.raw"
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(Ed25519PrivateKey.generate().private_bytes(
            serialization.Encoding.Raw, serialization.PrivateFormat.Raw, serialization.NoEncryption()))
    return Ed25519PrivateKey.from_private_bytes(path.read_bytes())


def public_key_b64() -> str:
    return base64.b64encode(private_key().public_key().public_bytes(
        serialization.Encoding.Raw, serialization.PublicFormat.Raw)).decode()


def _digest(body: bytes) -> str:
    return base64.b64encode(hashlib.blake2b(body, digest_size=64).digest()).decode()


def _signing_string(created: int, expires: int, body: bytes) -> str:
    return f"(created): {created}\n(expires): {expires}\ndigest: BLAKE-512={_digest(body)}"


def auth_header(body: bytes, ttl: int = 300) -> str:
    s = get_settings()
    created = int(time.time())
    expires = created + ttl
    sig = base64.b64encode(private_key().sign(_signing_string(created, expires, body).encode())).decode()
    return (f'Signature keyId="{s.ondc_subscriber_id}|{s.ondc_unique_key_id}|ed25519",algorithm="ed25519",'
            f'created="{created}",expires="{expires}",headers="(created) (expires) digest",signature="{sig}"')


def verify_header(header: str, body: bytes, public_key_b64_: str) -> bool:
    params = dict(re.findall(r'(\w+)="([^"]*)"', header or ""))
    try:
        created, expires = int(params["created"]), int(params["expires"])
        if expires < time.time():
            return False
        pk = Ed25519PublicKey.from_public_bytes(base64.b64decode(public_key_b64_))
        pk.verify(base64.b64decode(params["signature"]), _signing_string(created, expires, body).encode())
        return True
    except Exception:
        return False
