"""Transparent fair-price engine: shows *how the price is built*, not just a matched number.

fair price = (materials + labour + overheads + craft/GI premium + logistics) / (1 - platform commission)
labour     = hours x fair hourly wage (state floor, admin-configurable, at or above skilled minimum wage)

A gradient-boosting quantile model estimates the market-rate range (p20 / p50 / p80) from comparable
listings and ShilpSetu's own sales. If the market pays more than the cost-plus fair price, the artisan gets
half of that uplift as an explicit "market premium" line — the price never drops below the fair floor.
"""
from __future__ import annotations

import math
from dataclasses import asdict, dataclass, field
from pathlib import Path

import joblib
import numpy as np

from . import lexicon as L

COMPLEXITY = {
    "dhokra": 1.20, "ikat": 1.20, "blue_pottery": 1.15, "pattachitra": 1.15, "kantha": 1.15,
    "chikankari": 1.15, "madhubani": 1.10, "handloom": 1.10, "embroidery": 1.10, "carved": 1.10,
    "block_print": 1.08, "bandhani": 1.08, "hand_painted": 1.08, "channapatna": 1.10, "warli": 1.05,
    "pashmina": 1.25, "banarasi": 1.20, "tanjore": 1.20, "bidri": 1.20, "zardozi": 1.15, "filigree": 1.20,
    "marble_inlay": 1.20, "kalamkari": 1.12, "gond": 1.08, "pichwai": 1.12, "phulkari": 1.12, "meenakari": 1.15,
    "kutch_embroidery": 1.10, "papier_mache": 1.08, "leather_puppet": 1.10, "mamallapuram": 1.12,
}
GI_PREMIUM = 0.08
# Share of the gap between the fair floor and the market price added on top. Kept low so crafts stay affordable:
# the artisan's fair wage is never cut, buyers get most of the difference to market price.
MARKET_PREMIUM_SHARE = 0.25
DEFAULT_OVERHEAD_PCT = 0.12  # tools, electricity, packaging
FRAGILE = {"Pottery & Ceramics", "Stone Craft"}

# Typical hours by category, used only when the artisan hasn't said (the field is then marked estimated).
TYPICAL_HOURS = {
    "Textiles & Handloom": 32, "Pottery & Ceramics": 16, "Metalcraft": 32, "Woodcraft": 24,
    "Bamboo & Cane": 10, "Jewellery": 12, "Paintings & Folk Art": 20, "Leather": 12, "Stone Craft": 20,
    "Toys & Dolls": 8, "Home Décor": 12, "Other": 12,
}
TYPICAL_WEIGHT_G = {
    "Textiles & Handloom": 500, "Pottery & Ceramics": 1200, "Metalcraft": 900, "Woodcraft": 800,
    "Bamboo & Cane": 400, "Jewellery": 100, "Paintings & Folk Art": 300, "Leather": 600, "Stone Craft": 1500,
    "Toys & Dolls": 300, "Home Décor": 600, "Other": 500,
}


def logistics_estimate(category: str, weight_g: float | None) -> float:
    w = (weight_g or TYPICAL_WEIGHT_G.get(category, 500)) / 1000
    fee = 40 + 40 * max(0.25, w)  # small-parcel rate: ₹50 for a bookmark, ₹60 for 500 g, ₹88 for 1.2 kg
    if category in FRAGILE:
        fee += 40  # protective packing
    return float(round(fee / 5) * 5)


def round_price(x: float) -> float:
    """Round to a clean shelf price: nearest ₹10 under ₹1,000, nearest ₹50 above."""
    step = 10 if x < 1000 else 50
    return float(math.ceil(x / step) * step)


@dataclass
class PriceInputs:
    category: str
    material_cost: float | None
    hours: float | None
    wage_per_hour: float
    commission_pct: float
    techniques: list[str] = field(default_factory=list)
    gi_craft: str | None = None
    weight_g: float | None = None
    overhead_pct: float = DEFAULT_OVERHEAD_PCT
    state: str | None = None


@dataclass
class MarketEstimate:
    low: float
    mid: float
    high: float
    model_version: str


# ------------------------------------------------------------------ market model

FEATURES = ["cat_idx", "log_material", "hours", "gi", "complexity", "log_weight"]


def features(category: str, material_cost: float, hours: float, gi: bool, complexity: float,
             weight_g: float | None) -> list[float]:
    cat_idx = L.CATEGORIES.index(category) if category in L.CATEGORIES else len(L.CATEGORIES) - 1
    w = weight_g or TYPICAL_WEIGHT_G.get(category, 500)
    return [cat_idx, math.log1p(material_cost), hours, 1.0 if gi else 0.0, complexity, math.log1p(w)]


# Retail markup a middleman-led channel typically applies over the artisan's cost, by category.
RETAIL_MARKUP = {
    "Textiles & Handloom": 2.3, "Pottery & Ceramics": 2.4, "Metalcraft": 2.2, "Woodcraft": 2.1,
    "Bamboo & Cane": 2.0, "Jewellery": 2.5, "Paintings & Folk Art": 2.6, "Leather": 2.0, "Stone Craft": 2.1,
    "Toys & Dolls": 2.2, "Home Décor": 2.3, "Other": 2.0,
}


def synthetic_comparables(n: int = 1200, seed: int = 7) -> tuple[np.ndarray, np.ndarray]:
    """Seed training set standing in for scraped comparable listings (documented as synthetic).
    Market retail = (materials + hours x market wage) x category markup x GI premium x noise."""
    rng = np.random.default_rng(seed)
    X, y = [], []
    for _ in range(n):
        cat = L.CATEGORIES[rng.integers(0, len(L.CATEGORIES) - 1)]
        hours = float(max(2, rng.gamma(2.0, TYPICAL_HOURS[cat] / 2)))
        material = float(max(30, rng.lognormal(math.log(40 + 12 * hours), 0.5)))
        gi = bool(rng.random() < 0.3)
        complexity = float(rng.choice([1.0, 1.05, 1.1, 1.15, 1.2]))
        weight = float(max(50, rng.normal(TYPICAL_WEIGHT_G[cat], TYPICAL_WEIGHT_G[cat] * 0.3)))
        market_wage = rng.uniform(45, 90)  # what middlemen effectively pay per hour
        cost = material + hours * market_wage
        price = cost * RETAIL_MARKUP[cat] * (1.2 if gi else 1.0) * complexity * rng.lognormal(0, 0.18)
        X.append(features(cat, material, hours, gi, complexity, weight))
        y.append(price)
    return np.array(X), np.array(y)


class MarketModel:
    def __init__(self, models: dict, version: str):
        self.models, self.version = models, version

    @classmethod
    def train(cls, X: np.ndarray, y: np.ndarray, version: str, sample_weight: np.ndarray | None = None) -> "MarketModel":
        from sklearn.ensemble import HistGradientBoostingRegressor

        models = {}
        for name, alpha in (("low", 0.2), ("mid", 0.5), ("high", 0.8)):
            m = HistGradientBoostingRegressor(loss="quantile", quantile=alpha, max_iter=200, max_depth=4,
                                              learning_rate=0.08, categorical_features=[0], random_state=0)
            m.fit(X, np.log(y), sample_weight=sample_weight)
            models[name] = m
        return cls(models, version)

    def predict(self, x: list[float]) -> MarketEstimate:
        arr = np.array([x])
        vals = sorted(float(np.exp(self.models[k].predict(arr)[0])) for k in ("low", "mid", "high"))
        return MarketEstimate(round(vals[0], 2), round(vals[1], 2), round(vals[2], 2), self.version)

    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        joblib.dump({"models": self.models, "version": self.version}, path)

    @classmethod
    def load(cls, path: Path) -> "MarketModel":
        d = joblib.load(path)
        return cls(d["models"], d["version"])


# ------------------------------------------------------------------ fair price

def complexity_of(techniques: list[str]) -> float:
    return max([COMPLEXITY.get(t, 1.05) for t in techniques] or [1.0])


def quote(inp: PriceInputs, market: MarketEstimate | None) -> dict:
    estimated = []
    hours = inp.hours
    if not hours:
        hours = float(TYPICAL_HOURS.get(inp.category, 12))
        estimated.append("hours")
    material = inp.material_cost
    if material is None:
        material = round((market.mid if market else 600) * 0.18, 0)
        estimated.append("material_cost")
    commission = inp.commission_pct / 100
    complexity = complexity_of(inp.techniques)
    gi = GI_PREMIUM if inp.gi_craft else 0.0

    labour = hours * inp.wage_per_hour
    overheads = (material + labour) * inp.overhead_pct
    base = material + labour + overheads
    craft_premium = base * ((complexity - 1) + gi)
    logistics = logistics_estimate(inp.category, inp.weight_g)
    artisan_take = base + craft_premium
    fair_floor = (artisan_take + logistics) / (1 - commission)

    market_premium = 0.0
    target = fair_floor
    if market and market.mid > fair_floor:
        target = fair_floor + MARKET_PREMIUM_SHARE * (market.mid - fair_floor)
    price = round_price(target)
    fee = round(price * commission, 2)
    market_premium = price - fee - logistics - artisan_take
    share = price - fee - logistics

    breakdown = _lines(material, labour, overheads, craft_premium, market_premium, fee, logistics)
    compare_at = round_price(max(market.high, price * 1.3)) if market else round_price(price * 1.4)
    return {
        "recommended": price,
        "final_price": price,
        "fair_floor": round(fair_floor, 2),
        "market_low": market.low if market else round(price * 0.8, 2),
        "market_mid": market.mid if market else price,
        "market_high": market.high if market else round(price * 1.4, 2),
        "compare_at": compare_at,
        "artisan_share_amount": round(share, 2),
        "artisan_share_pct": round(100 * share / price, 1),
        "effective_hourly_wage": round((share - material) / hours, 1),
        "breakdown": breakdown,
        "inputs": {**asdict(inp), "hours_used": hours, "material_cost_used": material, "complexity": complexity,
                   "gi_premium_pct": gi * 100, "estimated_fields": estimated},
        "model_version": market.model_version if market else "heuristic",
    }


def _lines(material, labour, overheads, craft_premium, market_premium, fee, logistics) -> list[dict]:
    rows = [
        ("materials", "Materials", "सामग्री", material, True),
        ("labour", "Artisan labour (fair wage)", "कारीगर की मेहनत (उचित मज़दूरी)", labour, True),
        ("overheads", "Tools, electricity & packaging", "औज़ार, बिजली और पैकिंग", overheads, True),
        ("craft_premium", "Craft skill & GI premium", "शिल्प कौशल और GI प्रीमियम", craft_premium, True),
        ("market_premium", "Market premium (to artisan)", "बाज़ार प्रीमियम (कारीगर को)", market_premium, True),
        ("platform_fee", "ShilpSetu platform fee", "शिल्पसेतु प्लेटफ़ॉर्म शुल्क", fee, False),
        ("logistics", "Shipping & packing", "डिलीवरी खर्च", logistics, False),
    ]
    return [{"key": k, "label": en, "label_hi": hi, "amount": round(a, 2), "to_artisan": to}
            for k, en, hi, a, to in rows if round(a, 2) > 0 or k in ("materials", "labour", "platform_fee")]


def adjust(q: dict, new_price: float) -> dict:
    """Artisan nudges the price. Fee and logistics stay transparent; the difference moves the artisan's share."""
    inp = q["inputs"]
    commission = inp["commission_pct"] / 100
    material, hours = inp["material_cost_used"], inp["hours_used"]
    logistics = next((l["amount"] for l in q["breakdown"] if l["key"] == "logistics"), 0.0)
    by_key = {l["key"]: l["amount"] for l in q["breakdown"]}
    labour, overheads, craft = by_key.get("labour", 0), by_key.get("overheads", 0), by_key.get("craft_premium", 0)
    price = float(new_price)
    fee = round(price * commission, 2)
    share = price - fee - logistics
    premium = share - (material + labour + overheads + craft)
    out = dict(q)
    out.update({
        "final_price": price,
        "artisan_share_amount": round(share, 2),
        "artisan_share_pct": round(100 * share / price, 1) if price else 0,
        "effective_hourly_wage": round((share - material) / hours, 1),
        "breakdown": _lines(material, labour, overheads, craft, max(premium, 0), fee, logistics),
        "warnings": ["below_fair_wage"] if price < q["fair_floor"] else [],
    })
    if premium < 0:  # below fair floor: show the shortfall against labour honestly
        for line in out["breakdown"]:
            if line["key"] == "labour":
                line["amount"] = round(labour + premium, 2)
                line["label"] += " (below fair wage)"
    return out


def parse_spoken_price(text: str) -> float | None:
    """'make it 1,600' / '1600 कर दो' / 'सोलह सौ' -> 1600."""
    from .nlu import _parse_numbers, _tokens

    nums = [v for _, _, v in _parse_numbers(_tokens(text)) if v >= 10]
    return max(nums) if nums else None
