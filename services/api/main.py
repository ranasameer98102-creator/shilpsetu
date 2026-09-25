"""ShilpSetu API — AI Co-Seller for Marginalized Artisans (SIH 2026 · PS ID SIH26090 · Team HACKER LOBBY)."""
import json
import logging
import mimetypes
import time
import uuid
from collections import Counter
from contextlib import asynccontextmanager
from urllib.parse import unquote

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse, Response
from sqlalchemy import text

from . import runtime_settings
from .config import REPO_DIR, SERVICES_DIR, get_settings
from .db import Base, get_engine, session_factory
from .storage import LocalStorage, get_storage, request_base_url, verify_local_signature

log = logging.getLogger("shilpsetu")
METRICS: Counter = Counter()


class JsonFormatter(logging.Formatter):
    def format(self, record):
        base = {"ts": self.formatTime(record), "level": record.levelname, "logger": record.name, "msg": record.getMessage()}
        for k in ("request_id", "path", "status", "ms"):
            if hasattr(record, k):
                base[k] = getattr(record, k)
        return json.dumps(base, ensure_ascii=False)


def _setup_logging():
    h = logging.StreamHandler()
    h.setFormatter(JsonFormatter())
    root = logging.getLogger()
    root.handlers = [h]
    root.setLevel(logging.INFO)


@asynccontextmanager
async def lifespan(app: FastAPI):
    _setup_logging()
    s = get_settings()
    if s.env == "prod":  # never run production on dev secrets
        missing = [name for name, bad in (
            ("JWT_SECRET", s.jwt_secret.startswith("dev-only")),
            ("PII_ENCRYPTION_KEY", not s.pii_encryption_key),
            ("CERT_SIGNING_KEY_PATH", not s.cert_signing_key_path),
        ) if bad]
        if missing:
            raise RuntimeError(f"refusing to start in ENV=prod without: {', '.join(missing)}")
    from . import models  # noqa: F401  (register tables)

    if s.database_url.startswith("sqlite"):
        Base.metadata.create_all(get_engine())  # dev/test without Docker; Postgres uses Alembic
    yield


ABOUT = {
    "product": "ShilpSetu", "tagline": "AI Co-Seller for Marginalized Artisans",
    "hero": "From handmade to headline-worthy — every craft, always in market.",
    "promise": "One photo. One spoken sentence. A fair-priced, trust-verified listing — no typing, no middleman, no English required.",
    "hackathon": "Smart India Hackathon 2026", "problem_statement_id": "SIH26090",
    "ministry": "Ministry of Social Justice & Empowerment (MoSJE)", "theme": "Heritage & Culture",
    "category": "Software", "team": "HACKER LOBBY",
}

app = FastAPI(title="ShilpSetu API", version="1.0.0", lifespan=lifespan,
              description=ABOUT["promise"] + " · SIH 2026 · PS ID SIH26090 · Team HACKER LOBBY")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"],
                   expose_headers=["X-Request-ID"])
app.add_middleware(GZipMiddleware, minimum_size=800)  # low-bandwidth friendly


@app.middleware("http")
async def request_context(request: Request, call_next):
    rid = request.headers.get("X-Request-ID") or uuid.uuid4().hex[:16]
    request_base_url.set(str(request.base_url).rstrip("/"))
    start = time.perf_counter()
    try:
        response = await call_next(request)
    except Exception:
        log.exception("unhandled error", extra={"request_id": rid, "path": request.url.path})
        METRICS["http_5xx"] += 1
        return JSONResponse({"detail": "internal error", "request_id": rid}, status_code=500,
                            headers={"X-Request-ID": rid})
    ms = round((time.perf_counter() - start) * 1000, 1)
    response.headers["X-Request-ID"] = rid
    METRICS["http_requests"] += 1
    METRICS[f"http_{response.status_code // 100}xx"] += 1
    if not request.url.path.startswith("/media"):
        log.info("%s %s", request.method, request.url.path,
                 extra={"request_id": rid, "path": request.url.path, "status": response.status_code, "ms": ms})
    return response


# ------------------------------------------------------------------ routers
from ondc_adapter import bpp, mock_gateway  # noqa: E402

from .routers import (admin, artisans, assistant, auth, capture, certificates, commerce, notify_hooks,  # noqa: E402
                      operators, products, storefront, sync)

API = "/api/v1"
for r in (auth.router, artisans.router, operators.router, capture.router, products.router, sync.router,
          certificates.router, storefront.router, commerce.router, notify_hooks.router, admin.router,
          assistant.router):
    app.include_router(r, prefix=API)
app.include_router(certificates.page_router)
app.include_router(bpp.router)
app.include_router(mock_gateway.router)


@app.get(f"{API}/about", tags=["meta"])
def about():
    db = session_factory()()
    try:
        return {**ABOUT, "team_id": runtime_settings.get(db, "team_id"),
                "supported_languages": runtime_settings.get(db, "supported_languages")}
    finally:
        db.close()


@app.get(f"{API}/config/public", tags=["meta"])
def public_config():
    """What the apps need at start-up: languages, categories, tile behaviour, fair-price policy."""
    from ai.lexicon import CATEGORIES

    db = session_factory()()
    try:
        cfg = runtime_settings.get_all(db)
        return {"supported_languages": cfg["supported_languages"], "categories": CATEGORIES,
                "commission_pct": cfg["commission_pct"], "tile_tap_mode": cfg["tile_tap_mode"],
                "providers": {k: v for k, v in cfg["providers"].items()}}
    finally:
        db.close()


@app.get(f"{API}/photo-credits", tags=["meta"])
def photo_credits():
    """Authors and licences of the Wikimedia Commons photos used for demo products (CC licences need attribution)."""
    f = REPO_DIR / "seed" / "images" / "CREDITS.json"
    if not f.exists():
        return []
    return [{"product": k, **v} for k, v in json.loads(f.read_text(encoding="utf-8")).items()]


@app.get("/health", tags=["meta"])
def health():
    return {"status": "ok"}


@app.get("/ready", tags=["meta"])
def ready():
    try:
        with get_engine().connect() as c:
            c.execute(text("SELECT 1"))
        return {"status": "ready"}
    except Exception as e:
        raise HTTPException(503, f"database unavailable: {e}")


@app.get("/metrics", tags=["meta"])
def metrics():
    lines = [f"shilpsetu_{k} {v}" for k, v in sorted(METRICS.items())]
    return Response("\n".join(lines) + "\n", media_type="text/plain")


@app.get("/media/{key:path}", include_in_schema=False)
def media(key: str, exp: int, sig: str):
    """Signed, expiring media URLs for local storage (S3/MinIO uses presigned URLs instead)."""
    key = unquote(key)
    if not verify_local_signature(key, exp, sig):
        raise HTTPException(403, "link expired or invalid")
    storage = get_storage()
    if not isinstance(storage, LocalStorage):
        raise HTTPException(404, "not served here")
    try:
        data = storage.get(key)
    except (FileNotFoundError, ValueError):
        raise HTTPException(404, "not found")
    ext = key.rsplit(".", 1)[-1].lower()
    ctype = {"jpg": "image/jpeg", "png": "image/png", "webp": "image/webp", "wav": "audio/wav", "m4a": "audio/mp4",
             "aac": "audio/aac", "ogg": "audio/ogg", "webm": "audio/webm", "mp3": "audio/mpeg"}.get(ext, "application/octet-stream")
    return Response(data, media_type=ctype, headers={"Cache-Control": "private, max-age=3600"})


# ------------------------------------------------------------------ web apps (public demo: one link for everything)
# Prebuilt Flutter web bundles (scripts/build_web.sh). Mounted last so every API route above takes precedence.
from fastapi.staticfiles import StaticFiles  # noqa: E402

mimetypes.add_type("application/wasm", ".wasm")
WEB_DIR = SERVICES_DIR / "webapp"
if (WEB_DIR / "admin" / "index.html").exists():
    app.mount("/admin", StaticFiles(directory=WEB_DIR / "admin", html=True), name="admin-web")
if (WEB_DIR / "store" / "index.html").exists():
    app.mount("/", StaticFiles(directory=WEB_DIR / "store", html=True), name="store-web")
