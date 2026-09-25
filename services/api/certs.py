"""Per-item provenance certificates: Ed25519-signed payload, SHA-256 record hash, QR verify URL, printable PDF."""
from __future__ import annotations

import base64
import hashlib
import io
import json
from functools import lru_cache
from pathlib import Path

import qrcode
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey, Ed25519PublicKey

from .config import REPO_DIR, get_settings

FONT_DIR = REPO_DIR / "apps" / "shared" / "fonts"  # the same Noto/Poppins files the apps bundle


def _b64u(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode()


def _unb64u(s: str) -> bytes:
    return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))


@lru_cache
def signing_key() -> Ed25519PrivateKey:
    s = get_settings()
    path = Path(s.cert_signing_key_path) if s.cert_signing_key_path else s.data_dir / "keys" / "cert_ed25519.pem"
    if not path.exists():
        if s.env == "prod":
            raise RuntimeError("CERT_SIGNING_KEY_PATH must point to an existing Ed25519 key in production")
        path.parent.mkdir(parents=True, exist_ok=True)
        key = Ed25519PrivateKey.generate()
        path.write_bytes(key.private_bytes(serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
                                           serialization.NoEncryption()))
    return serialization.load_pem_private_key(path.read_bytes(), password=None)


def public_key_bytes() -> bytes:
    return signing_key().public_key().public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw)


def key_id() -> str:
    return "ss-" + hashlib.sha256(public_key_bytes()).hexdigest()[:12]


def canonical(payload: dict) -> bytes:
    return json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False, default=str).encode()


def sign(payload: dict) -> tuple[str, str]:
    """Returns (signature_b64url, sha256_hex)."""
    body = canonical(payload)
    return _b64u(signing_key().sign(body)), hashlib.sha256(body).hexdigest()


def verify_signature(payload: dict, signature: str, public_key: bytes | None = None) -> bool:
    pk = Ed25519PublicKey.from_public_bytes(public_key or public_key_bytes())
    try:
        pk.verify(_unb64u(signature), canonical(payload))
        return True
    except (InvalidSignature, ValueError):
        return False


def verify_url(cert_id: str, signature: str) -> str:
    return f"{get_settings().public_base_url}/v/{cert_id}?s={signature}"


def qr_png(data: str, box: int = 8) -> bytes:
    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=box, border=2)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="#0A3838", back_color="white")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def check(cert, product_exists: bool, sig_param: str | None) -> dict:
    """Full verification used by the public page and the JSON API."""
    reasons = []
    if not verify_signature(cert.payload, cert.signature):
        reasons.append("signature_invalid")
    if hashlib.sha256(canonical(cert.payload)).hexdigest() != cert.sha256:
        reasons.append("record_hash_mismatch")
    if sig_param is not None and sig_param != cert.signature:
        reasons.append("qr_signature_mismatch")
    if cert.revoked_at:
        reasons.append("revoked")
    if not product_exists:
        reasons.append("listing_removed")
    return {"valid": not reasons, "reasons": reasons}


# ------------------------------------------------------------------ printable PDF

_fonts_registered = False


def _register_fonts():
    global _fonts_registered
    if _fonts_registered:
        return
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont

    try:
        pdfmetrics.registerFont(TTFont("Poppins", str(FONT_DIR / "Poppins-Regular.ttf")))
        pdfmetrics.registerFont(TTFont("Poppins-Bold", str(FONT_DIR / "Poppins-Bold.ttf")))
        pdfmetrics.registerFont(TTFont("Lora", str(FONT_DIR / "Lora-Regular.ttf")))
    except Exception:
        pass
    _fonts_registered = True


def _font(name: str) -> str:
    from reportlab.pdfbase import pdfmetrics

    return name if name in pdfmetrics.getRegisteredFontNames() else {"Lora": "Times-Roman",
                                                                    "Poppins-Bold": "Helvetica-Bold"}.get(name, "Helvetica")


def pdf(cert, size: str = "a6") -> bytes:
    """A6 certificate or a 50x30 mm tag label. Latin-script only: ReportLab cannot shape Indic conjuncts,
    so native-script text lives on the web verify page instead."""
    return pdf_many([cert], size)


def pdf_many(cert_list: list, size: str = "a6") -> bytes:
    """One page per certificate — used for batch tag printing at exhibitions (kiosk mode)."""
    from reportlab.lib.pagesizes import A6
    from reportlab.lib.units import mm
    from reportlab.pdfgen import canvas

    _register_fonts()
    buf = io.BytesIO()
    pagesize = (50 * mm, 30 * mm) if size == "label" else A6
    c = canvas.Canvas(buf, pagesize=pagesize)
    for cert in cert_list:
        (_draw_label if size == "label" else _draw_a6)(c, cert, pagesize)
        c.showPage()
    c.save()
    return buf.getvalue()


def _colors():
    from reportlab.lib.colors import HexColor

    return (HexColor(c) for c in ("#0E4C4C", "#F6EFE2", "#E08A1E", "#7A2E2E", "#3F7F5A", "#261F18"))


def _draw_label(c, cert, pagesize) -> None:
    from reportlab.lib.units import mm
    from reportlab.lib.utils import ImageReader

    teal, cream, marigold, maroon, green, ink = _colors()
    p = cert.payload
    qr = ImageReader(io.BytesIO(qr_png(cert.qr_url, box=6)))
    c.drawImage(qr, 1.5 * mm, 3 * mm, 24 * mm, 24 * mm)
    c.setFillColor(teal)
    c.setFont(_font("Poppins-Bold"), 7)
    c.drawString(27 * mm, 23 * mm, "ShilpSetu")
    c.setFont(_font("Poppins"), 5.2)
    c.setFillColor(ink)
    lines = [p["artisan"]["name"][:26], (p["craft"] or "")[:26], (p["location"] or "")[:26],
             "Scan to verify", f"ID {cert.id[:10]}"]
    for i, t in enumerate(lines):
        c.drawString(27 * mm, (19 - i * 3.3) * mm, t)


def _draw_a6(c, cert, pagesize) -> None:
    from reportlab.lib.units import mm
    from reportlab.lib.utils import ImageReader

    teal, cream, marigold, maroon, green, ink = _colors()
    p = cert.payload
    qr = ImageReader(io.BytesIO(qr_png(cert.qr_url, box=6)))
    w, h = pagesize
    c.setFillColor(cream)
    c.rect(0, 0, w, h, stroke=0, fill=1)
    c.setFillColor(teal)
    c.rect(0, h - 22 * mm, w, 22 * mm, stroke=0, fill=1)
    c.setFillColor(marigold)
    c.setFont(_font("Poppins-Bold"), 15)
    c.drawString(8 * mm, h - 11 * mm, "ShilpSetu")
    c.setFillColor(cream)
    c.setFont(_font("Poppins"), 7.5)
    c.drawString(8 * mm, h - 16.5 * mm, "Artisan Provenance Certificate")
    y = h - 30 * mm
    c.setFillColor(teal)
    c.setFont(_font("Poppins-Bold"), 11)
    c.drawString(8 * mm, y, p["product"]["title"][:44])
    y -= 5 * mm
    c.setFillColor(ink)
    c.setFont(_font("Poppins"), 8)
    for label, val in [("Made by", p["artisan"]["name"]), ("Craft", p["craft"]), ("From", p["location"]),
                       ("Materials", ", ".join(p["materials"])[:48]),
                       ("Fair price", f"Rs {p['fair_price']['price']:,.0f}  -  Rs {p['fair_price']['artisan_share_amount']:,.0f}"
                                      f" ({p['fair_price']['artisan_share_pct']:.0f}%) to the artisan"),
                       ("Pehchan ID", "Verified" if p["artisan"]["pehchan_verified"] else "Not linked"),
                       ("Issued", p["issued_at"][:10])]:
        c.setFont(_font("Poppins-Bold"), 7.5)
        c.drawString(8 * mm, y, label)
        c.setFont(_font("Poppins"), 7.5)
        c.drawString(27 * mm, y, str(val or "-")[:60])
        y -= 4.6 * mm
    if p["artisan"]["pehchan_verified"]:
        c.setFillColor(green)
        c.roundRect(8 * mm, y - 1.5 * mm, 32 * mm, 5.5 * mm, 2.7 * mm, stroke=0, fill=1)
        c.setFillColor(cream)
        c.setFont(_font("Poppins-Bold"), 7)
        c.drawString(10.5 * mm, y + 0.3 * mm, "Verified Artisan")
    c.drawImage(qr, w - 38 * mm, 8 * mm, 32 * mm, 32 * mm)
    c.setFillColor(ink)
    c.setFont(_font("Lora"), 7)
    story = (p.get("story") or "")[:180]
    ty = 36 * mm
    for i in range(0, len(story), 58):
        c.drawString(8 * mm, ty, story[i:i + 58])
        ty -= 3.6 * mm
    c.setFont(_font("Poppins"), 5.5)
    c.setFillColor(maroon)
    c.drawString(8 * mm, 12 * mm, f"Certificate {cert.id}")
    c.drawString(8 * mm, 9 * mm, f"SHA-256 {cert.sha256[:32]}")
    c.drawString(8 * mm, 6 * mm, f"Signed {p['key_id']} (Ed25519) - scan QR to verify")
