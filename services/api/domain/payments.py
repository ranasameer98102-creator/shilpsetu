"""Payment gateway adapters: mock (dev) and Razorpay (test mode / live). UPI + Cash on Delivery."""
from __future__ import annotations

import hashlib
import hmac
import uuid

import httpx

from api.config import get_settings


class MockPayments:
    name = "mock"

    def create_order(self, amount_inr: float, receipt: str) -> dict:
        oid = "mock_order_" + uuid.uuid4().hex[:12]
        return {"id": oid, "amount": int(round(amount_inr * 100)), "currency": "INR",
                "checkout": {"provider": "mock", "upi_intent": f"upi://pay?pa=shilpsetu@upi&am={amount_inr:.2f}&tn={receipt}"}}

    def verify_payment(self, provider_order_id: str, payment_id: str, signature: str) -> bool:
        expected = hmac.new(b"mock-secret", f"{provider_order_id}|{payment_id}".encode(), hashlib.sha256).hexdigest()
        return hmac.compare_digest(expected, signature)

    @staticmethod
    def sign_for_test(provider_order_id: str, payment_id: str) -> str:
        return hmac.new(b"mock-secret", f"{provider_order_id}|{payment_id}".encode(), hashlib.sha256).hexdigest()

    def verify_webhook(self, body: bytes, signature: str) -> bool:
        return hmac.compare_digest(hmac.new(b"mock-secret", body, hashlib.sha256).hexdigest(), signature)


class RazorpayPayments:
    name = "razorpay"

    def __init__(self):
        s = get_settings()
        self.key_id, self.secret, self.webhook_secret = s.razorpay_key_id, s.razorpay_key_secret, s.razorpay_webhook_secret

    def create_order(self, amount_inr: float, receipt: str) -> dict:
        r = httpx.post("https://api.razorpay.com/v1/orders", auth=(self.key_id, self.secret), timeout=20,
                       json={"amount": int(round(amount_inr * 100)), "currency": "INR", "receipt": receipt[:40]})
        r.raise_for_status()
        data = r.json()
        return {"id": data["id"], "amount": data["amount"], "currency": "INR",
                "checkout": {"provider": "razorpay", "key_id": self.key_id, "order_id": data["id"]}}

    def verify_payment(self, provider_order_id: str, payment_id: str, signature: str) -> bool:
        expected = hmac.new(self.secret.encode(), f"{provider_order_id}|{payment_id}".encode(), hashlib.sha256).hexdigest()
        return hmac.compare_digest(expected, signature)

    def verify_webhook(self, body: bytes, signature: str) -> bool:
        expected = hmac.new(self.webhook_secret.encode(), body, hashlib.sha256).hexdigest()
        return hmac.compare_digest(expected, signature)


def get_payments(provider: str):
    return RazorpayPayments() if provider == "razorpay" else MockPayments()
