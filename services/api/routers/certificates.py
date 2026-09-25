"""Certificates: JSON verify API, QR image, printable PDF, public key, and the public verification web page."""
import base64
import html

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import HTMLResponse, Response
from sqlalchemy.orm import Session

from .. import certs
from ..db import get_db
from ..models import Certificate, Product
from ..storage import media_url

router = APIRouter(prefix="/certificates", tags=["certificates"])
page_router = APIRouter(tags=["verify"])


def _load(db: Session, cert_id: str) -> Certificate:
    c = db.get(Certificate, cert_id)
    if not c:
        raise HTTPException(404, "certificate not found")
    return c


def verification(db: Session, cert_id: str, sig: str | None) -> dict:
    c = db.get(Certificate, cert_id)
    if not c:
        return {"valid": False, "reasons": ["not_found"], "certificate": None}
    p = db.get(Product, c.product_id)
    result = certs.check(c, product_exists=p is not None, sig_param=sig)
    return {**result, "certificate": {"id": c.id, "payload": c.payload, "sha256": c.sha256, "signature": c.signature,
                                      "key_id": c.key_id, "issued_at": c.issued_at.isoformat(),
                                      "revoked_at": c.revoked_at.isoformat() if c.revoked_at else None,
                                      "revoked_reason": c.revoked_reason},
            "product_status": p.status if p else None}


@router.get("/public-key")
def public_key():
    """Anyone can verify certificates offline with this Ed25519 key."""
    return {"key_id": certs.key_id(), "algorithm": "Ed25519",
            "public_key_b64": base64.b64encode(certs.public_key_bytes()).decode(),
            "canonicalization": "JSON, sorted keys, separators (',', ':'), UTF-8"}


@router.get("/{cert_id}/verify")
def verify(cert_id: str, s: str | None = None, db: Session = Depends(get_db)):
    return verification(db, cert_id, s)


@router.get("/{cert_id}/qr.png")
def qr(cert_id: str, db: Session = Depends(get_db)):
    return Response(certs.qr_png(_load(db, cert_id).qr_url), media_type="image/png",
                    headers={"Cache-Control": "public, max-age=86400"})


@router.get("/{cert_id}/pdf")
def pdf(cert_id: str, size: str = "a6", db: Session = Depends(get_db)):
    c = _load(db, cert_id)
    return Response(certs.pdf(c, "label" if size == "label" else "a6"), media_type="application/pdf",
                    headers={"Content-Disposition": f'inline; filename="shilpsetu-certificate-{cert_id[:8]}.pdf"'})


REASONS = {"signature_invalid": "The signature does not match — this record may have been altered.",
           "record_hash_mismatch": "The stored record hash does not match.",
           "qr_signature_mismatch": "This QR code does not belong to this certificate.",
           "revoked": "This certificate has been revoked.", "listing_removed": "The listing no longer exists.",
           "not_found": "No certificate with this ID exists."}


@page_router.get("/v/{cert_id}", response_class=HTMLResponse, include_in_schema=False)
def verify_page(cert_id: str, s: str | None = None, db: Session = Depends(get_db)):
    """Public, no-login, mobile-friendly verification page (what a buyer sees after scanning the QR)."""
    v = verification(db, cert_id, s)
    e = html.escape
    if not v["certificate"]:
        body = f'<div class="status bad"><span>✗</span> Not verified</div><p>{e(REASONS["not_found"])}</p>'
        return HTMLResponse(PAGE.format(title="Certificate not found", body=body), status_code=404)
    p = v["certificate"]["payload"]
    a = p["artisan"]
    fp = p["fair_price"]
    ok = v["valid"]
    status = ('<div class="status ok"><span>✓</span> Verified — genuine ShilpSetu certificate</div>' if ok else
              '<div class="status bad"><span>✗</span> Not valid</div>' +
              "".join(f"<p class=warn>{e(REASONS.get(r, r))}</p>" for r in v["reasons"]))
    photo = f'<img class="avatar" src="{e(media_url(a["photo"]))}" alt="">' if a.get("photo") else '<div class="avatar ph"></div>'
    prod = db.get(Product, p["listing_id"])
    audio = ""
    if p.get("story_audio") and prod and prod.artisan.story_audio_url:
        audio = f'<audio controls preload="none" src="{e(media_url(prod.artisan.story_audio_url))}"></audio><div class="m">Hear {e(a["name"])} in their own voice</div>'
    rows = "".join(f"<tr><td>{e(l['label'])}</td><td>₹{l['amount']:,.0f}</td></tr>" for l in fp.get("basis", []))
    native = f' <span class="native">{e(a["name_native"])}</span>' if a.get("name_native") and a["name_native"] != a["name"] else ""
    body = f"""{status}
<section class="card"><div class="row">{photo}<div><div class="k">Made by</div><h2>{e(a['name'])}{native}</h2>
<div class="m">{e(p.get('location') or '')}</div>
{'<span class="pill">✓ Verified Artisan</span>' if a.get('verified') else ''}
{'<span class="pill g">Pehchan ID verified</span>' if a.get('pehchan_verified') else ''}</div></div></section>
<section class="card"><div class="k">Product</div><h3>{e(p['product']['title'])}</h3>
<div class="m">{e(p.get('craft') or '')}{(' · GI: ' + e(p['gi'])) if p.get('gi') else ''}</div>
<div class="m">Materials: {e(', '.join(p.get('materials') or []) or '—')}</div>
<div class="m">Made {e(p['created_at'][:10])} · Certificate issued {e(p['issued_at'][:10])}</div></section>
{f'<section class="card story"><div class="k">Their story</div><p>{e(p["story"])}</p>{audio}</section>' if p.get('story') else ''}
<section class="card"><div class="k">Fair-price basis</div>
<div class="big">₹{(fp.get('price') or 0):,.0f}</div>
<div class="share">₹{(fp.get('artisan_share_amount') or 0):,.0f} ({(fp.get('artisan_share_pct') or 0):.0f}%) goes directly to the artisan</div>
<table>{rows}</table></section>
<section class="card tech"><div class="k">Tamper evidence</div>
<div>Certificate <code>{e(cert_id)}</code></div><div>SHA-256 <code>{e(v['certificate']['sha256'])}</code></div>
<div>Ed25519 key <code>{e(v['certificate']['key_id'])}</code> · <a href="/api/v1/certificates/public-key">public key</a> ·
<a href="/api/v1/certificates/{e(cert_id)}/verify">raw JSON</a> · <a href="/api/v1/certificates/{e(cert_id)}/pdf">print PDF</a></div>
<div>Original photo hash <code>{e((p.get('original_photo_sha256') or '—')[:24])}…</code></div></section>"""
    return HTMLResponse(PAGE.format(title=f"{p['product']['title']} — Provenance", body=body))


PAGE = """<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title} · ShilpSetu</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link href="https://fonts.googleapis.com/css2?family=Lora:ital@0;1&family=Poppins:wght@400;600;700&family=Noto+Sans+Devanagari&family=Noto+Sans+Bengali&display=swap" rel="stylesheet">
<style>
:root{{--teal-deep:#0A3838;--teal:#0E4C4C;--cream:#F6EFE2;--sand:#D8CBA8;--marigold:#E08A1E;--ochre:#B76F12;--maroon:#7A2E2E;--ink:#261F18;--slate:#5B6660;--green:#3F7F5A}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--cream);color:var(--ink);font:16px/1.5 Poppins,'Noto Sans Devanagari','Noto Sans Bengali',sans-serif}}
header{{background:var(--teal);padding:14px 16px;color:var(--cream)}}header b{{color:var(--marigold);font-size:22px}}header small{{display:block;opacity:.8}}
main{{max-width:620px;margin:0 auto;padding:16px}}.card{{background:#fff;border-radius:20px;padding:16px;margin:12px 0;box-shadow:0 2px 10px rgba(38,31,24,.07)}}
.status{{border-radius:16px;padding:14px 16px;font-weight:700;font-size:18px}}.status span{{font-size:22px;margin-right:6px}}
.ok{{background:#E3F0E8;color:var(--green)}}.bad{{background:#F6E1DF;color:var(--maroon)}}.warn{{color:var(--maroon);margin:6px 0 0}}
.row{{display:flex;gap:14px;align-items:center}}.avatar{{width:72px;height:72px;border-radius:50%;object-fit:cover;flex:none}}
.ph{{background:linear-gradient(135deg,var(--maroon),var(--ochre))}}h2,h3{{margin:2px 0;color:var(--teal)}}.native{{font-weight:400;color:var(--slate)}}
.k{{font-size:12px;letter-spacing:.06em;text-transform:uppercase;color:var(--slate)}}.m{{color:var(--slate);font-size:14px}}
.pill{{display:inline-block;margin:6px 6px 0 0;padding:3px 10px;border-radius:99px;background:#fff;border:1px solid var(--sand);color:var(--green);font-size:13px;font-weight:600}}
.pill.g{{color:var(--teal)}}.story p{{font-family:Lora,serif;font-size:17px;line-height:1.6}}audio{{width:100%;margin-top:6px}}
.big{{font-size:30px;font-weight:700;color:var(--maroon)}}.share{{color:var(--green);font-weight:600;margin-bottom:8px}}
table{{width:100%;border-collapse:collapse;font-size:14px}}td{{padding:6px 0;border-top:1px solid #EFE7D6}}td:last-child{{text-align:right}}
.tech{{font-size:12px;color:var(--slate);overflow-wrap:anywhere}}code{{font-size:11px}}a{{color:var(--teal)}}
footer{{text-align:center;font-size:12px;color:var(--slate);padding:16px}}
</style></head><body><header><b>ShilpSetu</b><small>Artisan Provenance Certificate</small></header>
<main>{body}</main><footer>ShilpSetu · SIH 2026 · PS ID SIH26090 · Team HACKER LOBBY</footer></body></html>"""
