"""'AI Builds It': ASR -> NLU -> listing -> translation -> image enhancement -> fair price -> certificate draft.

Each step records visible progress (with a spoken message in English + Hindi). If a step fails the pipeline
continues with what it has and marks the affected fields 'needs review' — the artisan's capture is never lost.
"""
from __future__ import annotations

import logging
import traceback
from datetime import datetime, timezone

from sqlalchemy.orm import Session
from sqlalchemy.orm.attributes import flag_modified

from ai import nlu as N
from ai import speech
from ai.image import enhance
from api import runtime_settings
from api.config import get_settings
from api.crypto import sha256_bytes
from api.models import Artisan, Product, ProductMedia
from api.storage import get_storage

from . import pricing_service

log = logging.getLogger(__name__)

STEPS = [
    ("asr", "Understanding your voice", "आपकी आवाज़ समझ रहे हैं"),
    ("nlu", "Finding the details", "जानकारी निकाल रहे हैं"),
    ("listing", "Writing title and description", "नाम और विवरण लिख रहे हैं"),
    ("translation", "Translating for buyers", "खरीदारों के लिए अनुवाद कर रहे हैं"),
    ("image", "Cleaning up your photo", "आपकी फ़ोटो सुधार रहे हैं"),
    ("price", "Working out a fair price", "सही दाम निकाल रहे हैं"),
    ("certificate", "Preparing your certificate", "आपका प्रमाणपत्र तैयार कर रहे हैं"),
]


FLAT_CATEGORIES = {"Paintings & Folk Art", "Textiles & Handloom"}

def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def init_pipeline(product: Product) -> None:
    product.pipeline = {"started_at": None, "finished_at": None, "done": False, "questions": [],
                        "steps": [{"key": k, "label": en, "label_hi": hi, "status": "pending"} for k, en, hi in STEPS]}


def _set(db: Session, product: Product, key: str, status: str, note: str | None = None) -> None:
    for s in product.pipeline["steps"]:
        if s["key"] == key:
            s["status"] = status
            s["at"] = _now()
            if note:
                s["note"] = note[:300]
    flag_modified(product, "pipeline")
    db.commit()


def _artisan_ctx(a: Artisan) -> dict:
    return {"name": a.name, "name_native": a.name_native, "village": a.village, "district": a.district,
            "state": a.state, "craft_type": a.craft_type, "years_practice": a.years_practice, "gender": a.gender,
            "cluster": a.cluster}


def _flag(product: Product, field_name: str) -> None:
    if field_name not in product.needs_review_fields:
        product.needs_review_fields = [*product.needs_review_fields, field_name]


def run(db: Session, product_id: str, only: set[str] | None = None) -> Product:
    product = db.get(Product, product_id)
    artisan = db.get(Artisan, product.artisan_id)
    storage = get_storage()
    s = get_settings()
    if not product.pipeline or only is None:
        init_pipeline(product)
        product.needs_review_fields = []
    product.status = "processing"
    product.pipeline["started_at"] = _now()
    db.commit()
    attrs = dict(product.attributes or {})
    ctx = _artisan_ctx(artisan)
    lang = product.language or "hi"

    def want(step: str) -> bool:
        return only is None or step in only

    # 1. ASR --------------------------------------------------------------
    if want("asr"):
        _set(db, product, "asr", "running")
        try:
            audio = next((m for m in product.media if m.kind == "audio"), None)
            text = ""
            if audio or attrs.get("device_transcript"):
                t = speech.transcribe(db, runtime_settings.provider(db, "asr"),
                                      storage.get(audio.url) if audio else b"", lang,
                                      device_transcript=attrs.get("device_transcript"))
                text = t.text
                attrs["asr"] = {"provider": t.provider, "confidence": t.confidence}
                if t.confidence < 0.6:
                    _flag(product, "transcript")
            for ans in attrs.get("answers", []):
                if ans.get("media_key") and not ans.get("text"):
                    at = speech.transcribe(db, runtime_settings.provider(db, "asr"), storage.get(ans["media_key"]), lang)
                    ans["text"] = at.text
            product.transcript = text
            _set(db, product, "asr", "done" if text else "failed", None if text else "no speech captured")
            if not text:
                _flag(product, "transcript")
        except Exception as e:
            log.exception("ASR failed")
            _flag(product, "transcript")
            _set(db, product, "asr", "failed", str(e))

    # 2. NLU + 3. listing --------------------------------------------------
    listing = None
    if want("nlu"):
        _set(db, product, "nlu", "running")
        provider = runtime_settings.provider(db, "nlu")
        try:
            try:
                ex, listing = N.get_nlu(provider).analyze(product.transcript or "", lang, ctx)
            except Exception as e:
                log.warning("NLU provider %s failed (%s); falling back to rule-based", provider, e)
                ex, listing = N.RuleBasedNLU().analyze(product.transcript or "", lang, ctx)
                attrs["nlu_fallback"] = str(e)[:200]
            for ans in attrs.get("answers", []):
                if ans.get("text"):
                    ex = N.merge(ex, N.answer_to_extraction(ans["field"], ans["text"]))
            if listing is None or attrs.get("answers"):
                listing = {**N.generate_listing(ex, ctx), **({"native": listing.get("native")} if listing and listing.get("native") else {})}
            attrs["extraction"] = ex.to_dict()
            product.pipeline["questions"] = N.follow_up_questions(ex, lang)
            if ex.quantity:
                product.quantity = ex.quantity
            if not ex.product_type:
                _flag(product, "category")
            _set(db, product, "nlu", "done")
        except Exception as e:
            log.exception("NLU failed")
            _flag(product, "attributes")
            _set(db, product, "nlu", "failed", str(e))

    if want("listing"):
        _set(db, product, "listing", "running")
        try:
            if listing is None:
                ex = N.Extraction(**{k: v for k, v in attrs.get("extraction", {}).items()}) if attrs.get("extraction") \
                    else N.extract(product.transcript or "")
                listing = N.generate_listing(ex, ctx)
            edited = product.device_edited_fields or {}
            # Device wins for artisan edits; AI fills everything else.
            product.title = edited.get("title", listing["title"])
            product.short_title = edited.get("short_title", listing["short_title"])
            product.description = edited.get("description", listing["description"])
            product.category = edited.get("category", listing["category"])
            product.tags = listing["tags"]
            attrs["seo_title"] = listing.get("seo_title")
            attrs["native_listing"] = listing.get("native")
            _set(db, product, "listing", "done")
        except Exception as e:
            log.exception("listing failed")
            product.title = product.title or "Handmade craft"
            product.category = product.category or "Other"
            _flag(product, "title")
            _set(db, product, "listing", "failed", str(e))

    # 4. translations --------------------------------------------------------
    if want("translation"):
        _set(db, product, "translation", "running")
        try:
            cfg = runtime_settings.get_all(db)
            langs = list(dict.fromkeys([lang, "en", "hi", *cfg.get("buyer_languages", [])]))
            ex = N.Extraction(**attrs["extraction"]) if attrs.get("extraction") else N.extract(product.transcript or "")
            tr_provider = runtime_settings.provider(db, "translation")
            translations = {}
            for L in langs:
                if L == "en":
                    translations["en"] = {"title": product.title, "description": product.description, "source": "generated"}
                    continue
                native = attrs.get("native_listing")
                if native and L == lang:
                    translations[L] = {**native, "source": "llm"}
                    continue
                tmpl = N.template_translation(ex, ctx, L) if tr_provider == "mock" else None
                if tmpl:
                    translations[L] = {**tmpl, "source": "template"}
                    continue
                title, ok1 = speech.translate(db, tr_provider, product.title, "en", L)
                desc, ok2 = speech.translate(db, tr_provider, product.description, "en", L)
                translations[L] = {"title": title, "description": desc, "source": tr_provider,
                                   "needs_review": not (ok1 and ok2)}
            product.translations = translations
            _set(db, product, "translation", "done")
        except Exception as e:
            log.exception("translation failed")
            _flag(product, "translations")
            _set(db, product, "translation", "failed", str(e))

    # 5. image enhancement ------------------------------------------------------
    if want("image"):
        _set(db, product, "image", "running")
        originals = sorted([m for m in product.media if m.kind == "original"], key=lambda m: m.position)
        if not originals:
            _flag(product, "photo")
            _set(db, product, "image", "skipped", "no photo")
        else:
            for m in list(product.media):
                if m.kind in ("enhanced", "enhanced_4x5", "thumb"):
                    db.delete(m)
            db.flush()
            try:
                hints = []
                # Paintings and fabrics are flat: cutting out the "background" would crop the art itself.
                flat = product.category in FLAT_CATEGORIES or attrs.get("keep_background")
                mode = "off" if flat else s.background_removal
                for orig in originals:
                    e = enhance(storage.get(orig.url), mode, model=s.rembg_model)
                    base = f"products/{product.id}/{orig.position}"
                    for kind, data, ext, ctype, (w, h) in (
                        ("enhanced", e.square_jpeg, "jpg", "image/jpeg", (e.width, e.height)),
                        ("enhanced_4x5", e.portrait_jpeg, "jpg", "image/jpeg", (e.width, int(e.width * 1.25))),
                        ("thumb", e.thumb_webp, "webp", "image/webp", (400, 400)),
                    ):
                        key = f"{base}_{kind}.{ext}"
                        storage.put(key, data, ctype)
                        db.add(ProductMedia(product_id=product.id, kind=kind, url=key, sha256=sha256_bytes(data),
                                            width=w, height=h, position=orig.position))
                    if orig.position == 0:
                        attrs["photo_quality"] = {**e.quality, "background_removed": e.background_removed}
                        hints = e.hints
                attrs["photo_hints"] = hints
                _set(db, product, "image", "done")
            except Exception as e:
                log.exception("image enhancement failed")
                _flag(product, "photo")
                _set(db, product, "image", "failed", str(e))

    product.attributes = attrs
    flag_modified(product, "attributes")
    db.commit()

    # 6. fair price -------------------------------------------------------------
    if want("price"):
        _set(db, product, "price", "running")
        try:
            q = pricing_service.quote_product(db, product, artisan)
            est = q.inputs.get("estimated_fields", [])
            if est:
                _flag(product, "price_inputs")
            _set(db, product, "price", "done", f"estimated: {', '.join(est)}" if est else None)
        except Exception as e:
            log.exception("pricing failed")
            _flag(product, "price")
            _set(db, product, "price", "failed", str(e))

    # 7. certificate draft --------------------------------------------------------
    if want("certificate"):
        _set(db, product, "certificate", "running")
        try:
            from .publishing import certificate_payload

            attrs["certificate_draft"] = certificate_payload(db, product, draft=True)
            product.attributes = attrs
            flag_modified(product, "attributes")
            _set(db, product, "certificate", "done")
        except Exception as e:
            log.exception("certificate draft failed")
            _set(db, product, "certificate", "failed", str(e))

    product.pipeline["done"] = True
    product.pipeline["finished_at"] = _now()
    flag_modified(product, "pipeline")
    product.status = "needs_review" if product.needs_review_fields else "ready"
    db.commit()
    return product


def run_safely(db: Session, product_id: str, only: set[str] | None = None) -> None:
    try:
        run(db, product_id, only)
    except Exception:
        db.rollback()
        p = db.get(Product, product_id)
        if p:
            p.status = "needs_review"
            p.pipeline = {**(p.pipeline or {}), "done": True, "error": traceback.format_exc()[-800:]}
            db.commit()
