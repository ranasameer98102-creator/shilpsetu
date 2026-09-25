"""Admin-editable runtime settings (commission, fair-wage floors, languages, provider selection)."""
from sqlalchemy.orm import Session

from .config import get_settings
from .models import Setting

# Skilled-worker hourly floor (₹/hour), pegged at or above state minimum wages for skilled work
# (daily skilled minimum wage / 8 hours, rounded up). Admin can edit these.
FAIR_WAGE_BY_STATE = {
    "Rajasthan": 95.0,
    "Jharkhand": 90.0,
    "Chhattisgarh": 90.0,
    "West Bengal": 95.0,
    "Odisha": 95.0,
    "Uttar Pradesh": 95.0,
    "Gujarat": 100.0,
    "Maharashtra": 110.0,
    "Tamil Nadu": 105.0,
    "Karnataka": 110.0,
    "Kerala": 125.0,
    "Delhi": 130.0,
    "Assam": 90.0,
    "Andhra Pradesh": 100.0,
    "Telangana": 100.0,
    "Punjab": 105.0,
}

SUPPORTED_LANGUAGES = ["hi", "en", "bn", "mr", "te", "ta", "gu", "ur", "kn", "or", "ml", "pa", "as", "sat"]

# All 22 scheduled languages; the architecture accepts any of these codes.
SCHEDULED_LANGUAGES = [
    "as", "bn", "brx", "doi", "gu", "hi", "kn", "ks", "kok", "mai", "ml",
    "mni", "mr", "ne", "or", "pa", "sa", "sat", "sd", "ta", "te", "ur",
]


def defaults() -> dict:
    s = get_settings()
    return {
        "commission_pct": s.default_commission_pct,
        "fair_wage_default": s.default_fair_wage_per_hour,
        "fair_wage_by_state": FAIR_WAGE_BY_STATE,
        "supported_languages": SUPPORTED_LANGUAGES,
        "buyer_languages": ["en", "hi"],
        "providers": {
            "asr": s.asr_provider,
            "nlu": s.nlu_provider,
            "translation": s.translation_provider,
            "sms": s.sms_provider,
            "ivr": s.ivr_provider,
            "payment": s.payment_provider,
            "ondc": s.ondc_mode,
        },
        "fairness_boost": {"new_artisan_days": 45, "max_sales": 5, "boost": 0.25},
        "tile_tap_mode": "speak_then_open",  # speak_then_open | open
        "team_id": s.team_id,
    }


def get_all(db: Session) -> dict:
    merged = defaults()
    for row in db.query(Setting).all():
        if isinstance(merged.get(row.key), dict) and isinstance(row.value, dict):
            merged[row.key] = {**merged[row.key], **row.value}
        else:
            merged[row.key] = row.value
    return merged


def get(db: Session, key: str):
    return get_all(db).get(key)


def put(db: Session, key: str, value) -> None:
    row = db.get(Setting, key)
    if row:
        row.value = value
    else:
        db.add(Setting(key=key, value=value))
    db.flush()


def fair_wage_for(db: Session, state: str | None) -> float:
    cfg = get_all(db)
    return float(cfg["fair_wage_by_state"].get(state or "", cfg["fair_wage_default"]))


def provider(db: Session | None, kind: str) -> str:
    if db is None:
        return defaults()["providers"][kind]
    return get_all(db)["providers"].get(kind, "mock")
