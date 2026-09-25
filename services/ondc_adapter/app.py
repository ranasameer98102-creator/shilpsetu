"""Standalone ONDC Seller Network Participant (BPP) service.

In local dev the main API also mounts these routes, so one process is enough. In docker-compose / production
this runs as its own service at the public BPP subscriber URI registered with the ONDC registry, sharing the
database with the API.
"""
from fastapi import FastAPI

from . import bpp, mock_gateway, signing

app = FastAPI(title="ShilpSetu ONDC BPP Adapter", version="1.0.0")
app.include_router(bpp.router)
app.include_router(mock_gateway.router)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ondc/subscriber")
def subscriber_info():
    """Values to register with the ONDC registry (signing public key for Beckn HTTP signatures)."""
    from api.config import get_settings

    s = get_settings()
    return {"subscriber_id": s.ondc_subscriber_id, "subscriber_url": s.ondc_subscriber_uri,
            "unique_key_id": s.ondc_unique_key_id, "signing_public_key": signing.public_key_b64(),
            "domain": s.ondc_domain, "city": s.ondc_city, "type": "BPP"}
