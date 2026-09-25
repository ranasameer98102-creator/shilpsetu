"""PII encryption at rest (Fernet) and keyed hashing for lookups."""
import hashlib
import hmac
from functools import lru_cache

from cryptography.fernet import Fernet
from sqlalchemy import String
from sqlalchemy.types import TypeDecorator

from .config import get_settings


@lru_cache
def _fernet() -> Fernet:
    s = get_settings()
    key = s.pii_encryption_key
    if not key:
        if s.env == "prod":
            raise RuntimeError("PII_ENCRYPTION_KEY must be set in production")
        key_file = s.data_dir / "keys" / "pii.key"
        key_file.parent.mkdir(parents=True, exist_ok=True)
        if not key_file.exists():
            key_file.write_bytes(Fernet.generate_key())
        key = key_file.read_text().strip()
    return Fernet(key.encode() if isinstance(key, str) else key)


def encrypt(value: str) -> str:
    return _fernet().encrypt(value.encode()).decode()


def decrypt(token: str) -> str:
    return _fernet().decrypt(token.encode()).decode()


def lookup_hash(value: str) -> str:
    """Deterministic keyed hash so encrypted columns (phone) can still be looked up."""
    key = get_settings().jwt_secret.encode()
    return hmac.new(key, value.strip().encode(), hashlib.sha256).hexdigest()


class EncryptedString(TypeDecorator):
    impl = String
    cache_ok = True

    def process_bind_param(self, value, dialect):
        return None if value is None else encrypt(value)

    def process_result_value(self, value, dialect):
        return None if value is None else decrypt(value)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()
