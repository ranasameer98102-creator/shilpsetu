"""Central configuration. Every external service is selected by an env var and defaults to a mock."""
from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

SERVICES_DIR = Path(__file__).resolve().parent.parent
REPO_DIR = SERVICES_DIR.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=(REPO_DIR / "infra" / ".env", ".env"), extra="ignore")

    env: str = "dev"  # dev | test | prod
    database_url: str = f"sqlite:///{(SERVICES_DIR / '.data' / 'shilpsetu.db').as_posix()}"
    data_dir: Path = SERVICES_DIR / ".data"
    public_base_url: str = "http://localhost:8000"

    # Security
    jwt_secret: str = "dev-only-change-me-please-0123456789abcdef"
    jwt_ttl_minutes: int = 60 * 24 * 7
    pii_encryption_key: str = ""  # Fernet key; generated into data_dir when empty (dev only)
    cert_signing_key_path: str = ""  # Ed25519 PEM; generated into data_dir when empty (dev only)
    media_url_ttl_seconds: int = 3600

    # Provider switches: mock | real adapter name
    asr_provider: str = "mock"  # mock | bhashini | ai4bharat
    nlu_provider: str = "mock"  # mock | claude
    assistant_provider: str = "mock"  # mock (rule-based, offline) | claude
    translation_provider: str = "mock"  # mock | bhashini | indictrans2
    storage_provider: str = "local"  # local | s3
    sms_provider: str = "mock"  # mock | twilio | exotel
    ivr_provider: str = "mock"  # mock | twilio | exotel
    payment_provider: str = "mock"  # mock | razorpay
    logistics_provider: str = "mock"  # mock
    ondc_mode: str = "mock"  # mock | sandbox | production
    job_mode: str = "inline"  # inline | rq
    background_removal: str = "auto"  # auto | rembg | grabcut | off
    rembg_model: str = "u2net"  # u2net (176 MB, best) | u2netp (4.6 MB, fast) | isnet-general-use

    # Bhashini (ULCA)
    bhashini_user_id: str = ""
    bhashini_api_key: str = ""
    bhashini_pipeline_id: str = "64392f96daac500b55c543cd"
    bhashini_config_url: str = "https://meity-auth.ulcacontrib.org/ulca/apis/v0/model/getModelsPipeline"

    # AI4Bharat / IndicTrans2 self-hosted endpoints
    ai4bharat_asr_url: str = ""
    indictrans2_url: str = ""

    # LLM for listing generation
    anthropic_api_key: str = ""
    llm_model: str = "claude-opus-5"

    # Storage (S3 / MinIO)
    s3_endpoint_url: str = "http://localhost:9000"
    s3_bucket: str = "shilpsetu-media"
    s3_access_key: str = "minioadmin"
    s3_secret_key: str = "minioadmin"
    s3_region: str = "ap-south-1"

    # Redis / workers
    redis_url: str = "redis://localhost:6379/0"

    # SMS / IVR
    twilio_account_sid: str = ""
    twilio_auth_token: str = ""
    twilio_from_number: str = ""
    exotel_sid: str = ""
    exotel_api_key: str = ""
    exotel_api_token: str = ""
    exotel_caller_id: str = ""
    exotel_subdomain: str = "api.exotel.com"

    # Payments
    razorpay_key_id: str = ""
    razorpay_key_secret: str = ""
    razorpay_webhook_secret: str = ""

    # ONDC / Beckn
    ondc_subscriber_id: str = "shilpsetu.local"
    ondc_subscriber_uri: str = "http://localhost:8000/ondc"
    ondc_unique_key_id: str = "shilpsetu-key-1"
    ondc_signing_private_key: str = ""  # base64 Ed25519 seed; generated in mock mode
    ondc_gateway_url: str = "http://localhost:8000/ondc-mock/gateway"
    ondc_domain: str = "ONDC:RET12"  # retail: fashion/handicraft
    ondc_city: str = "std:0141"

    # Shared secret for telephony / logistics webhooks (Exotel, courier). Twilio uses its own request signature.
    webhook_token: str = ""
    # Mock SMS shows the OTP on screen for the demo. On a public server set False: admin codes then go to the log only.
    show_admin_otp: bool = True

    # Business defaults (overridable from the admin Settings screen)
    default_commission_pct: float = 4.0
    default_fair_wage_per_hour: float = 100.0
    team_id: str = "[Your Team ID]"

    @property
    def is_test(self) -> bool:
        return self.env == "test"


@lru_cache
def get_settings() -> Settings:
    s = Settings()
    s.data_dir.mkdir(parents=True, exist_ok=True)
    return s
