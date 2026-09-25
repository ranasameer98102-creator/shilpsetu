"""SMS / IVR gateway adapters. Mock logs to console + the notifications table (shown in admin)."""
from __future__ import annotations

import logging
import uuid
from xml.sax.saxutils import escape

import httpx

log = logging.getLogger("shilpsetu.notify")


class MockGateway:
    name = "mock"

    def send_sms(self, to: str, body: str) -> str:
        ref = "mock-sms-" + uuid.uuid4().hex[:10]
        log.info("[SMS -> %s] %s", to, body)
        print(f"[mock SMS -> {to}] {body}")
        return ref

    def place_call(self, to: str, prompts: list[str], language: str, callback_url: str) -> str:
        ref = "mock-call-" + uuid.uuid4().hex[:10]
        log.info("[IVR call -> %s | %s] %s", to, language, " / ".join(prompts))
        print(f"[mock IVR call -> {to} ({language})] {' / '.join(prompts)}")
        return ref


# Twilio <Say> language codes (Polly/Google voices exist for these Indian locales).
TWILIO_LANG = {"hi": "hi-IN", "en": "en-IN", "bn": "bn-IN", "mr": "mr-IN", "ta": "ta-IN", "te": "te-IN",
               "gu": "gu-IN", "kn": "kn-IN", "ml": "ml-IN", "pa": "pa-IN"}


def twiml(prompts: list[str], language: str, gather_action: str | None = None) -> str:
    lang = TWILIO_LANG.get(language, "en-IN")
    says = "".join(f'<Say language="{lang}">{escape(p)}</Say>' for p in prompts)
    if gather_action:
        return f'<?xml version="1.0" encoding="UTF-8"?><Response><Gather numDigits="1" action="{escape(gather_action)}">{says}</Gather></Response>'
    return f'<?xml version="1.0" encoding="UTF-8"?><Response>{says}</Response>'


class TwilioGateway:
    name = "twilio"

    def __init__(self, sid: str, token: str, from_number: str):
        self.sid, self.token, self.from_number = sid, token, from_number
        self.base = f"https://api.twilio.com/2010-04-01/Accounts/{sid}"

    def send_sms(self, to: str, body: str) -> str:
        r = httpx.post(f"{self.base}/Messages.json", auth=(self.sid, self.token), timeout=20,
                       data={"To": to, "From": self.from_number, "Body": body})
        r.raise_for_status()
        return r.json()["sid"]

    def place_call(self, to: str, prompts: list[str], language: str, callback_url: str) -> str:
        r = httpx.post(f"{self.base}/Calls.json", auth=(self.sid, self.token), timeout=20,
                       data={"To": to, "From": self.from_number, "Twiml": twiml(prompts, language, callback_url)})
        r.raise_for_status()
        return r.json()["sid"]


class ExotelGateway:
    name = "exotel"

    def __init__(self, sid: str, key: str, token: str, caller_id: str, subdomain: str):
        self.sid, self.key, self.token, self.caller_id = sid, key, token, caller_id
        self.base = f"https://{subdomain}/v1/Accounts/{sid}"

    def send_sms(self, to: str, body: str) -> str:
        r = httpx.post(f"{self.base}/Sms/send.json", auth=(self.key, self.token), timeout=20,
                       data={"From": self.caller_id, "To": to, "Body": body})
        r.raise_for_status()
        return r.json()["SMSMessage"]["Sid"]

    def place_call(self, to: str, prompts: list[str], language: str, callback_url: str) -> str:
        # Exotel plays an IVR flow configured in its App Bazaar; we pass our callback as the flow URL.
        r = httpx.post(f"{self.base}/Calls/connect.json", auth=(self.key, self.token), timeout=20,
                       data={"From": to, "CallerId": self.caller_id, "Url": callback_url,
                             "CustomField": language})
        r.raise_for_status()
        return r.json()["Call"]["Sid"]


def get_gateway(provider: str):
    from api.config import get_settings

    s = get_settings()
    if provider == "twilio":
        return TwilioGateway(s.twilio_account_sid, s.twilio_auth_token, s.twilio_from_number)
    if provider == "exotel":
        return ExotelGateway(s.exotel_sid, s.exotel_api_key, s.exotel_api_token, s.exotel_caller_id,
                             s.exotel_subdomain)
    return MockGateway()
