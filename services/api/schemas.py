"""Request / response bodies. These become the JSON Schemas in the OpenAPI document (docs/api.md)."""
from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

Role = Literal["artisan", "operator", "buyer", "admin"]


# ---------------------------------------------------------------- auth
class OtpRequest(BaseModel):
    phone: str = Field(pattern=r"^\+?\d{10,13}$", examples=["+919876543210"])
    language: str = "hi"


class OtpRequested(BaseModel):
    challenge_id: str
    expires_in: int
    dev_otp: str | None = Field(None, description="Only returned when SMS_PROVIDER=mock (dev/demo)")


class OtpVerify(BaseModel):
    phone: str
    code: str = Field(pattern=r"^\d{6}$")
    role: Role = "artisan"
    language: str | None = None


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    role: Role
    has_profile: bool


# ---------------------------------------------------------------- artisans
class ConsentIn(BaseModel):
    voice: bool = False
    photo: bool = False
    location: bool = False
    consent_audio_key: str | None = Field(None, description="storage key of the recorded spoken consent")


class ArtisanProfileIn(BaseModel):
    name: str
    name_native: str | None = None
    village: str | None = None
    district: str | None = None
    state: str | None = None
    craft_type: str | None = None
    years_practice: int | None = None
    story_text: str | None = None
    story_audio_key: str | None = None
    photo_key: str | None = None
    pehchan_id: str | None = None
    shg_name: str | None = None
    csc_id: str | None = None
    cluster: str | None = None
    gi_tag: str | None = None
    gender: Literal["female", "male", "other", "prefer_not"] | None = None
    consent: ConsentIn = ConsentIn()


class ArtisanVoiceProfileIn(BaseModel):
    """Zero-typing onboarding: each field answered by voice; server transcribes and fills the profile."""
    language: str = "hi"
    answers: dict[str, str] = Field(default_factory=dict,
                                    description="field -> upload id (audio) or on-device transcript text")
    consent: ConsentIn = ConsentIn()


class ArtisanOut(BaseModel):
    id: str
    name: str
    name_native: str | None
    village: str | None
    district: str | None
    state: str | None
    craft_type: str | None
    years_practice: int | None
    story_text: str | None
    story_translations: dict
    story_audio_url: str | None
    photo_url: str | None
    pehchan_verified: bool
    verification_status: str
    shg_name: str | None
    cluster: str | None
    gi_tag: str | None
    verified: bool


# ---------------------------------------------------------------- capture
class UploadCreate(BaseModel):
    idempotency_key: str = Field(min_length=8, max_length=80)
    kind: Literal["audio", "photo"]
    content_type: str
    total_size: int = Field(gt=0, le=25 * 1024 * 1024)
    sha256: str | None = None


class UploadStatus(BaseModel):
    upload_id: str
    received: int
    total_size: int
    status: Literal["open", "complete"]
    storage_key: str | None = None


class DraftCreate(BaseModel):
    idempotency_key: str = Field(min_length=8, max_length=80)
    device_id: str
    language: str = "hi"
    audio_upload_id: str | None = None
    photo_upload_ids: list[str] = Field(default_factory=list, max_length=5)
    device_transcript: str | None = Field(None, description="on-device ASR result, if the phone produced one")
    answers: list["AnswerIn"] = Field(default_factory=list)
    captured_offline_at: datetime | None = None
    edits: dict = Field(default_factory=dict, description="artisan edits made on device (device wins)")


class AnswerIn(BaseModel):
    field: Literal["product_type", "materials", "time_hours", "material_cost", "quantity", "dimensions"]
    upload_id: str | None = None
    text: str | None = None


class PipelineStep(BaseModel):
    key: str
    label: str
    label_hi: str
    status: str
    note: str | None = None


class PriceLine(BaseModel):
    key: str
    label: str
    label_hi: str
    amount: float
    to_artisan: bool


class PriceQuoteOut(BaseModel):
    recommended: float
    final_price: float
    fair_floor: float | None
    market_low: float
    market_mid: float
    market_high: float
    compare_at: float | None
    artisan_share_amount: float
    artisan_share_pct: float
    effective_hourly_wage: float | None
    breakdown: list[PriceLine]
    inputs: dict
    model_version: str
    warnings: list[str] = []


class MediaOut(BaseModel):
    kind: str
    url: str
    width: int | None
    height: int | None
    position: int


class ProductOut(BaseModel):
    id: str
    status: str
    title: str | None
    short_title: str | None
    description: str | None
    category: str | None
    tags: list
    translations: dict
    language: str
    transcript: str | None
    attributes: dict
    quantity: int
    price: float | None
    compare_at_price: float | None
    needs_review_fields: list
    pipeline: dict
    media: list[MediaOut]
    price_quote: PriceQuoteOut | None
    certificate: dict | None
    created_via: str
    published_at: datetime | None


class PriceAdjust(BaseModel):
    price: float | None = Field(None, gt=0)
    spoken: str | None = Field(None, description="e.g. 'make it 1,600' / 'सोलह सौ कर दो'")


class ProductEdit(BaseModel):
    title: str | None = None
    description: str | None = None
    category: str | None = None
    quantity: int | None = Field(None, ge=0)


# ---------------------------------------------------------------- storefront / orders
class CartLine(BaseModel):
    product_id: str
    quantity: int = Field(1, ge=1, le=20)


class Address(BaseModel):
    name: str
    phone: str
    line1: str
    city: str
    state: str
    pincode: str = Field(pattern=r"^\d{6}$")


class CheckoutIn(BaseModel):
    address: Address
    payment_method: Literal["upi", "cod"] = "upi"


class OrderStatusIn(BaseModel):
    status: Literal["accepted", "declined", "packed", "shipped", "delivered", "cancelled", "returned"]
    note: str | None = None


class PaymentConfirm(BaseModel):
    provider_order_id: str
    payment_id: str
    signature: str


class ReviewIn(BaseModel):
    order_item_id: str
    rating: int = Field(ge=1, le=5)
    text: str | None = Field(None, max_length=1000)


class EventIn(BaseModel):
    type: Literal["view", "add_to_cart", "order", "return"]
    product_id: str
    meta: dict = Field(default_factory=dict)


class EventsIn(BaseModel):
    events: list[EventIn] = Field(max_length=200)


# ---------------------------------------------------------------- operators / admin
class OperatorArtisanCreate(ArtisanProfileIn):
    phone: str | None = Field(None, description="artisan may not own a phone")
    language: str = "hi"
    attestation: str = Field(description="operator attests to identity and consent")
    consent_audio_upload_id: str | None = None


class VerifyArtisanIn(BaseModel):
    status: Literal["verified", "rejected"]
    pehchan_verified: bool = False
    note: str | None = None


class ModerateIn(BaseModel):
    action: Literal["flag", "unpublish", "republish", "edit"]
    reason: str | None = None
    title: str | None = None
    description: str | None = None


class RevokeIn(BaseModel):
    reason: str


class SettingsIn(BaseModel):
    commission_pct: float | None = Field(None, ge=0, le=20)
    fair_wage_default: float | None = Field(None, ge=0)
    fair_wage_by_state: dict[str, float] | None = None
    supported_languages: list[str] | None = None
    buyer_languages: list[str] | None = None
    providers: dict[str, str] | None = None
    fairness_boost: dict | None = None
    tile_tap_mode: Literal["speak_then_open", "open"] | None = None
    team_id: str | None = None


class OperatorCreate(BaseModel):
    phone: str
    name: str
    kind: Literal["csc", "shg"] = "csc"
    csc_id: str | None = None
    shg_id: str | None = None
    region: str | None = None
    language: str = "hi"


class SchemeLinkIn(BaseModel):
    scheme: Literal["NHDP", "CHCDS", "SFURTI"]
    artisan_id: str | None = None
    cluster: str | None = None
    note: str | None = None


DraftCreate.model_rebuild()
