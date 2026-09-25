"""Logistics tie-up adapter (shipping rate + tracking). Mock simulates a courier; real partners plug in here."""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from ai.pricing import logistics_estimate

ZONES = {"same_state": 3, "neighbour": 4, "national": 6, "remote": 8}


class MockLogistics:
    name = "mock"

    def quote(self, category: str, weight_g: float | None, from_state: str | None, to_state: str | None) -> dict:
        fee = logistics_estimate(category, weight_g)
        days = ZONES["same_state"] if from_state and from_state == to_state else ZONES["national"]
        return {"fee": fee, "days": days, "carrier": "IndiaPost Speed (mock)"}

    def create_shipment(self, order_id: str) -> dict:
        awb = "SS" + uuid.uuid4().hex[:10].upper()
        return {"awb": awb, "carrier": "IndiaPost Speed (mock)",
                "tracking_url": f"https://tracking.example/awb/{awb}",
                "created_at": datetime.now(timezone.utc).isoformat()}

    def track(self, shipment: dict) -> list[dict]:
        """Deterministic stub: events unfold over time since shipment creation."""
        start = datetime.fromisoformat(shipment["created_at"])
        steps = [("Picked up", 0), ("In transit", 6), ("Reached destination hub", 30), ("Out for delivery", 48)]
        now = datetime.now(timezone.utc)
        return [{"status": s, "at": (start + timedelta(hours=h)).isoformat()} for s, h in steps
                if start + timedelta(hours=h) <= now]


def get_logistics(provider: str = "mock"):
    return MockLogistics()
