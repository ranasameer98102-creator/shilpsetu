"""PostgreSQL data model (§10). Portable to SQLite for tests."""
import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .crypto import EncryptedString
from .db import Base, JSONType


def uid() -> str:
    return uuid.uuid4().hex


def now() -> datetime:
    return datetime.now(timezone.utc)


class User(Base):
    __tablename__ = "users"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    role: Mapped[str] = mapped_column(String(16), index=True)  # artisan | operator | buyer | admin
    phone: Mapped[str | None] = mapped_column(EncryptedString(255))
    phone_hash: Mapped[str | None] = mapped_column(String(64), index=True)
    language: Mapped[str] = mapped_column(String(8), default="hi")
    display_name: Mapped[str | None] = mapped_column(String(120))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))

    artisan: Mapped["Artisan | None"] = relationship(back_populates="user", uselist=False)


class Artisan(Base):
    __tablename__ = "artisans"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    user_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"), unique=True)
    name: Mapped[str] = mapped_column(String(120))
    name_native: Mapped[str | None] = mapped_column(String(120))
    village: Mapped[str | None] = mapped_column(String(120))
    district: Mapped[str | None] = mapped_column(String(120))
    state: Mapped[str | None] = mapped_column(String(64), index=True)
    craft_type: Mapped[str | None] = mapped_column(String(120))
    years_practice: Mapped[int | None] = mapped_column(Integer)
    story_text: Mapped[str | None] = mapped_column(Text)
    story_audio_url: Mapped[str | None] = mapped_column(String(512))
    story_translations: Mapped[dict] = mapped_column(JSONType, default=dict)
    photo_url: Mapped[str | None] = mapped_column(String(512))
    pehchan_id: Mapped[str | None] = mapped_column(EncryptedString(255))
    pehchan_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    verification_status: Mapped[str] = mapped_column(String(16), default="pending")  # pending|verified|rejected
    shg_name: Mapped[str | None] = mapped_column(String(160))
    csc_id: Mapped[str | None] = mapped_column(String(64))
    cluster: Mapped[str | None] = mapped_column(String(160), index=True)
    gi_tag: Mapped[str | None] = mapped_column(String(160))
    gender: Mapped[str | None] = mapped_column(String(16))  # self-declared, impact analytics only
    consent_flags: Mapped[dict] = mapped_column(JSONType, default=dict)
    onboarded_by_operator_id: Mapped[str | None] = mapped_column(ForeignKey("operators.id"))
    operator_attestation: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)

    user: Mapped[User | None] = relationship(back_populates="artisan")
    products: Mapped[list["Product"]] = relationship(back_populates="artisan")


class Operator(Base):
    __tablename__ = "operators"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), unique=True)
    kind: Mapped[str] = mapped_column(String(8), default="csc")  # csc | shg
    csc_id: Mapped[str | None] = mapped_column(String(64))
    shg_id: Mapped[str | None] = mapped_column(String(64))
    name: Mapped[str | None] = mapped_column(String(160))
    region: Mapped[str | None] = mapped_column(String(160))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Product(Base):
    __tablename__ = "products"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    artisan_id: Mapped[str] = mapped_column(ForeignKey("artisans.id"), index=True)
    status: Mapped[str] = mapped_column(String(16), default="draft", index=True)
    # draft|queued|processing|needs_review|live|unpublished
    title: Mapped[str | None] = mapped_column(String(200))
    short_title: Mapped[str | None] = mapped_column(String(80))
    description: Mapped[str | None] = mapped_column(Text)
    category: Mapped[str | None] = mapped_column(String(64), index=True)
    tags: Mapped[list] = mapped_column(JSONType, default=list)
    attributes: Mapped[dict] = mapped_column(JSONType, default=dict)
    translations: Mapped[dict] = mapped_column(JSONType, default=dict)
    language: Mapped[str] = mapped_column(String(8), default="hi")
    transcript: Mapped[str | None] = mapped_column(Text)
    needs_review_fields: Mapped[list] = mapped_column(JSONType, default=list)
    pipeline: Mapped[dict] = mapped_column(JSONType, default=dict)
    quantity: Mapped[int] = mapped_column(Integer, default=1)
    price: Mapped[float | None] = mapped_column(Float)
    compare_at_price: Mapped[float | None] = mapped_column(Float)
    rank_score: Mapped[float] = mapped_column(Float, default=0.0)
    rating_avg: Mapped[float] = mapped_column(Float, default=0.0)
    rating_count: Mapped[int] = mapped_column(Integer, default=0)
    created_via: Mapped[str] = mapped_column(String(8), default="app")  # app | kiosk
    operator_id: Mapped[str | None] = mapped_column(ForeignKey("operators.id"))
    idempotency_key: Mapped[str | None] = mapped_column(String(80), unique=True)
    device_edited_fields: Mapped[dict] = mapped_column(JSONType, default=dict)
    captured_offline_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, onupdate=now)
    published_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    moderation_flag: Mapped[str | None] = mapped_column(String(200))

    artisan: Mapped[Artisan] = relationship(back_populates="products")
    media: Mapped[list["ProductMedia"]] = relationship(back_populates="product", cascade="all, delete-orphan")
    certificate: Mapped["Certificate | None"] = relationship(back_populates="product", uselist=False)


class ProductMedia(Base):
    __tablename__ = "product_media"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), index=True)
    kind: Mapped[str] = mapped_column(String(16))  # original|enhanced|enhanced_4x5|thumb|audio|answer_audio
    url: Mapped[str] = mapped_column(String(512))  # storage key
    sha256: Mapped[str | None] = mapped_column(String(64))
    width: Mapped[int | None] = mapped_column(Integer)
    height: Mapped[int | None] = mapped_column(Integer)
    position: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)

    product: Mapped[Product] = relationship(back_populates="media")


class Upload(Base):
    """Resumable chunked upload session for audio/photo captured on-device."""
    __tablename__ = "uploads"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    owner_user_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    idempotency_key: Mapped[str] = mapped_column(String(80), unique=True)
    kind: Mapped[str] = mapped_column(String(16))  # audio | photo
    content_type: Mapped[str] = mapped_column(String(64))
    total_size: Mapped[int] = mapped_column(Integer)
    sha256: Mapped[str | None] = mapped_column(String(64))
    received: Mapped[int] = mapped_column(Integer, default=0)
    storage_key: Mapped[str | None] = mapped_column(String(512))
    status: Mapped[str] = mapped_column(String(16), default="open")  # open | complete
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class PriceQuote(Base):
    __tablename__ = "price_quotes"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), index=True)
    model_version: Mapped[str] = mapped_column(String(32))
    inputs: Mapped[dict] = mapped_column(JSONType, default=dict)
    breakdown: Mapped[dict] = mapped_column(JSONType, default=dict)
    market_low: Mapped[float] = mapped_column(Float)
    market_high: Mapped[float] = mapped_column(Float)
    market_mid: Mapped[float] = mapped_column(Float)
    recommended: Mapped[float] = mapped_column(Float)
    final_price: Mapped[float | None] = mapped_column(Float)
    artisan_share_amount: Mapped[float] = mapped_column(Float)
    artisan_share_pct: Mapped[float] = mapped_column(Float)
    source: Mapped[str] = mapped_column(String(16), default="model")  # model | artisan_adjusted | seed
    is_current: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Certificate(Base):
    __tablename__ = "certificates"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), unique=True)
    payload: Mapped[dict] = mapped_column(JSONType)
    signature: Mapped[str] = mapped_column(String(128))
    sha256: Mapped[str] = mapped_column(String(64))
    qr_url: Mapped[str] = mapped_column(String(512))
    key_id: Mapped[str] = mapped_column(String(64))
    issued_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked_reason: Mapped[str | None] = mapped_column(String(200))

    product: Mapped[Product] = relationship(back_populates="certificate")


class CartItem(Base):
    __tablename__ = "cart_items"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    buyer_id: Mapped[str] = mapped_column(ForeignKey("users.id"), index=True)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"))
    quantity: Mapped[int] = mapped_column(Integer, default=1)
    __table_args__ = (UniqueConstraint("buyer_id", "product_id"),)


class Order(Base):
    __tablename__ = "orders"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    buyer_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"), index=True)
    channel: Mapped[str] = mapped_column(String(8), default="app")  # app | ondc
    ondc_transaction_id: Mapped[str | None] = mapped_column(String(80), index=True)
    status: Mapped[str] = mapped_column(String(16), default="placed")
    # placed|accepted|declined|packed|shipped|delivered|cancelled
    address: Mapped[dict] = mapped_column(JSONType, default=dict)
    payment_method: Mapped[str] = mapped_column(String(8), default="upi")  # upi | cod
    subtotal: Mapped[float] = mapped_column(Float, default=0)
    logistics_fee: Mapped[float] = mapped_column(Float, default=0)
    total: Mapped[float] = mapped_column(Float, default=0)
    delivery_estimate_days: Mapped[int | None] = mapped_column(Integer)
    tracking: Mapped[dict] = mapped_column(JSONType, default=dict)
    history: Mapped[list] = mapped_column(JSONType, default=list)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)

    items: Mapped[list["OrderItem"]] = relationship(back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    order_id: Mapped[str] = mapped_column(ForeignKey("orders.id"), index=True)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"))
    artisan_id: Mapped[str] = mapped_column(ForeignKey("artisans.id"), index=True)
    quantity: Mapped[int] = mapped_column(Integer, default=1)
    unit_price: Mapped[float] = mapped_column(Float)
    price_quote_id: Mapped[str | None] = mapped_column(ForeignKey("price_quotes.id"))

    order: Mapped[Order] = relationship(back_populates="items")


class Payment(Base):
    __tablename__ = "payments"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    order_id: Mapped[str] = mapped_column(ForeignKey("orders.id"), index=True)
    provider: Mapped[str] = mapped_column(String(16))
    provider_order_id: Mapped[str | None] = mapped_column(String(80))
    provider_payment_id: Mapped[str | None] = mapped_column(String(80))
    amount: Mapped[float] = mapped_column(Float)
    status: Mapped[str] = mapped_column(String(16), default="created")  # created|paid|failed|cod_pending|cod_collected
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Payout(Base):
    __tablename__ = "payouts"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    artisan_id: Mapped[str] = mapped_column(ForeignKey("artisans.id"), index=True)
    order_id: Mapped[str] = mapped_column(ForeignKey("orders.id"))
    gross: Mapped[float] = mapped_column(Float)
    commission: Mapped[float] = mapped_column(Float)
    logistics: Mapped[float] = mapped_column(Float)
    net: Mapped[float] = mapped_column(Float)
    status: Mapped[str] = mapped_column(String(16), default="pending")  # pending | paid
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class LedgerEntry(Base):
    __tablename__ = "ledger_entries"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    artisan_id: Mapped[str] = mapped_column(ForeignKey("artisans.id"), index=True)
    order_id: Mapped[str | None] = mapped_column(ForeignKey("orders.id"))
    payout_id: Mapped[str | None] = mapped_column(ForeignKey("payouts.id"))
    kind: Mapped[str] = mapped_column(String(16))  # sale | commission | logistics | payout
    amount: Mapped[float] = mapped_column(Float)  # signed, artisan perspective
    memo: Mapped[str] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Review(Base):
    __tablename__ = "reviews"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    order_item_id: Mapped[str | None] = mapped_column(ForeignKey("order_items.id"), unique=True)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), index=True)
    buyer_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"))
    rating: Mapped[int] = mapped_column(Integer)
    text: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Event(Base):
    __tablename__ = "events"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    type: Mapped[str] = mapped_column(String(16), index=True)  # view|add_to_cart|order|return
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), index=True)
    buyer_id: Mapped[str | None] = mapped_column(String(32))
    ts: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, index=True)
    meta: Mapped[dict] = mapped_column(JSONType, default=dict)


class SyncJob(Base):
    __tablename__ = "sync_jobs"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    device_id: Mapped[str] = mapped_column(String(80), index=True)
    idempotency_key: Mapped[str] = mapped_column(String(80), unique=True)
    kind: Mapped[str] = mapped_column(String(24), default="product_capture")
    status: Mapped[str] = mapped_column(String(16), default="received")  # received|processing|done|failed
    attempts: Mapped[int] = mapped_column(Integer, default=1)
    result_ref: Mapped[str | None] = mapped_column(String(64))
    last_error: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, onupdate=now)


class OndcSync(Base):
    __tablename__ = "ondc_sync"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    product_id: Mapped[str] = mapped_column(ForeignKey("products.id"), unique=True)
    status: Mapped[str] = mapped_column(String(16), default="queued")  # queued|synced|failed|removed
    last_payload: Mapped[dict] = mapped_column(JSONType, default=dict)
    last_error: Mapped[str | None] = mapped_column(Text)
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, onupdate=now)


class Notification(Base):
    __tablename__ = "notifications"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    user_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"), index=True)
    channel: Mapped[str] = mapped_column(String(8))  # sms | ivr | push
    template: Mapped[str] = mapped_column(String(40))
    language: Mapped[str] = mapped_column(String(8))
    to: Mapped[str | None] = mapped_column(EncryptedString(255))
    body: Mapped[str] = mapped_column(Text)
    provider: Mapped[str] = mapped_column(String(16))
    provider_ref: Mapped[str | None] = mapped_column(String(80))
    status: Mapped[str] = mapped_column(String(16), default="queued")  # queued|sent|failed|delivered
    meta: Mapped[dict] = mapped_column(JSONType, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class OtpChallenge(Base):
    __tablename__ = "otp_challenges"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    phone_hash: Mapped[str] = mapped_column(String(64), index=True)
    code_hash: Mapped[str] = mapped_column(String(64))
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    used: Mapped[bool] = mapped_column(Boolean, default=False)


class AuditLog(Base):
    """Append-only: each row chains the hash of the previous row (tamper evidence)."""
    __tablename__ = "audit_log"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    ts: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)
    actor_id: Mapped[str | None] = mapped_column(String(32))
    action: Mapped[str] = mapped_column(String(48), index=True)
    entity: Mapped[str] = mapped_column(String(32))
    entity_id: Mapped[str] = mapped_column(String(64), index=True)
    data: Mapped[dict] = mapped_column(JSONType, default=dict)
    prev_hash: Mapped[str] = mapped_column(String(64))
    hash: Mapped[str] = mapped_column(String(64))


class ModelVersion(Base):
    __tablename__ = "model_versions"
    id: Mapped[str] = mapped_column(String(32), primary_key=True)  # e.g. market-v3
    kind: Mapped[str] = mapped_column(String(16))  # market | ranking
    path: Mapped[str | None] = mapped_column(String(512))
    metrics: Mapped[dict] = mapped_column(JSONType, default=dict)
    params: Mapped[dict] = mapped_column(JSONType, default=dict)
    trained_on: Mapped[dict] = mapped_column(JSONType, default=dict)
    is_active: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class Setting(Base):
    __tablename__ = "settings"
    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    value: Mapped[dict | list | float | str | None] = mapped_column(JSONType)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now, onupdate=now)


class SchemeLink(Base):
    __tablename__ = "scheme_links"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    scheme: Mapped[str] = mapped_column(String(16))  # NHDP | CHCDS | SFURTI
    artisan_id: Mapped[str | None] = mapped_column(ForeignKey("artisans.id"))
    cluster: Mapped[str | None] = mapped_column(String(160))
    note: Mapped[str | None] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class HelpdeskCallback(Base):
    __tablename__ = "helpdesk_callbacks"
    id: Mapped[str] = mapped_column(String(32), primary_key=True, default=uid)
    user_id: Mapped[str | None] = mapped_column(ForeignKey("users.id"))
    language: Mapped[str] = mapped_column(String(8))
    reason: Mapped[str | None] = mapped_column(String(200))
    status: Mapped[str] = mapped_column(String(16), default="open")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class AiCache(Base):
    """Cache for ASR / translation results so repeated calls (retries, re-syncs) cost nothing."""
    __tablename__ = "ai_cache"
    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    kind: Mapped[str] = mapped_column(String(16))
    value: Mapped[dict] = mapped_column(JSONType)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=now)


class AssistantDay(Base):
    """One row per user per day they used the app with the assistant: powers the Duolingo-style streak."""
    __tablename__ = "assistant_days"
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), primary_key=True)
    day: Mapped[str] = mapped_column(String(10), primary_key=True)  # YYYY-MM-DD (IST)
