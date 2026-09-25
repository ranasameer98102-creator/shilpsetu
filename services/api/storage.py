"""Object storage behind an interface: local filesystem (dev/test) or S3-compatible (MinIO / AWS)."""
import hashlib
import hmac
import time
from functools import lru_cache
from pathlib import Path
from typing import Protocol
from urllib.parse import quote

from contextvars import ContextVar

from .config import get_settings

# Set per request (see api/main.py) so media links use the host the client actually reached
# (localhost on the laptop, the LAN address on a phone) instead of one hard-coded base URL.
request_base_url: ContextVar[str | None] = ContextVar("request_base_url", default=None)


class Storage(Protocol):
    def put(self, key: str, data: bytes, content_type: str) -> None: ...
    def get(self, key: str) -> bytes: ...
    def delete(self, key: str) -> None: ...
    def signed_url(self, key: str, ttl: int | None = None) -> str: ...


def _sign(key: str, exp: int) -> str:
    secret = get_settings().jwt_secret.encode()
    return hmac.new(secret, f"{key}:{exp}".encode(), hashlib.sha256).hexdigest()[:32]


def verify_local_signature(key: str, exp: int, sig: str) -> bool:
    return exp >= int(time.time()) and hmac.compare_digest(_sign(key, exp), sig)


class LocalStorage:
    def __init__(self, root: Path):
        self.root = root
        self.root.mkdir(parents=True, exist_ok=True)

    def _path(self, key: str) -> Path:
        p = (self.root / key).resolve()
        if self.root.resolve() not in p.parents:
            raise ValueError("invalid storage key")
        return p

    def put(self, key: str, data: bytes, content_type: str) -> None:
        p = self._path(key)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(data)

    def append(self, key: str, data: bytes) -> None:
        p = self._path(key)
        p.parent.mkdir(parents=True, exist_ok=True)
        with p.open("ab") as f:
            f.write(data)

    def get(self, key: str) -> bytes:
        return self._path(key).read_bytes()

    def delete(self, key: str) -> None:
        self._path(key).unlink(missing_ok=True)

    def signed_url(self, key: str, ttl: int | None = None) -> str:
        s = get_settings()
        exp = int(time.time()) + (ttl or s.media_url_ttl_seconds)
        # Round expiry to the hour so URLs are cache-friendly for low-bandwidth clients.
        exp = exp - exp % 3600 + 3600
        base = request_base_url.get() or s.public_base_url
        return f"{base}/media/{quote(key)}?exp={exp}&sig={_sign(key, exp)}"


class S3Storage:
    def __init__(self):
        import boto3

        s = get_settings()
        self.bucket = s.s3_bucket
        self.client = boto3.client(
            "s3",
            endpoint_url=s.s3_endpoint_url or None,
            aws_access_key_id=s.s3_access_key,
            aws_secret_access_key=s.s3_secret_key,
            region_name=s.s3_region,
        )
        try:
            self.client.head_bucket(Bucket=self.bucket)
        except Exception:
            self.client.create_bucket(Bucket=self.bucket)

    def put(self, key: str, data: bytes, content_type: str) -> None:
        self.client.put_object(Bucket=self.bucket, Key=key, Body=data, ContentType=content_type)

    def get(self, key: str) -> bytes:
        return self.client.get_object(Bucket=self.bucket, Key=key)["Body"].read()

    def delete(self, key: str) -> None:
        self.client.delete_object(Bucket=self.bucket, Key=key)

    def signed_url(self, key: str, ttl: int | None = None) -> str:
        return self.client.generate_presigned_url(
            "get_object", Params={"Bucket": self.bucket, "Key": key},
            ExpiresIn=ttl or get_settings().media_url_ttl_seconds,
        )


@lru_cache
def get_storage() -> Storage:
    s = get_settings()
    if s.storage_provider == "s3":
        return S3Storage()
    return LocalStorage(s.data_dir / "media")


def media_url(key: str | None) -> str | None:
    return get_storage().signed_url(key) if key else None
