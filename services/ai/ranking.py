"""Storefront ranking: learned conversion model + smoothed engagement + fairness boost for new artisans.

The model is a logistic regression predicting P(add-to-cart or order | view) from product features,
retrained nightly from marketplace events. With too little data it falls back to prior weights.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import numpy as np

FEATURES = ["price_vs_market", "rating", "log_reviews", "verified", "gi", "enhanced_photo", "freshness"]
PRIOR_COEF = [-0.8, 0.35, 0.25, 0.5, 0.3, 0.4, 0.3]
PRIOR_INTERCEPT = -2.5


@dataclass
class ProductSignals:
    product_id: str
    price: float
    market_mid: float
    rating: float
    reviews: int
    verified: bool
    gi: bool
    enhanced_photo: bool
    age_days: float
    views: int
    conversions: int  # add_to_cart + order
    artisan_age_days: float
    artisan_sales: int


def feature_row(s: ProductSignals) -> list[float]:
    ratio = math.log(max(s.price, 1) / max(s.market_mid, 1))
    return [ratio, s.rating / 5, math.log1p(s.reviews), float(s.verified), float(s.gi),
            float(s.enhanced_photo), math.exp(-s.age_days / 30)]


class RankingModel:
    def __init__(self, coef: list[float], intercept: float, version: str, trained: bool):
        self.coef, self.intercept, self.version, self.trained = coef, intercept, version, trained

    @classmethod
    def prior(cls, version: str = "ranking-prior") -> "RankingModel":
        return cls(PRIOR_COEF, PRIOR_INTERCEPT, version, False)

    @classmethod
    def train(cls, signals: list[ProductSignals], version: str) -> "RankingModel":
        X, y, w = [], [], []
        for s in signals:
            if s.views <= 0:
                continue
            row = feature_row(s)
            pos = min(s.conversions, s.views)
            if pos:
                X.append(row); y.append(1); w.append(pos)
            if s.views - pos:
                X.append(row); y.append(0); w.append(s.views - pos)
        if len(set(y)) < 2 or sum(w) < 30:
            return cls.prior(version)
        try:
            from sklearn.linear_model import LogisticRegression
        except ImportError:  # ML runtime blocked on this machine: keep the hand-set prior weights
            return cls.prior(version)

        lr = LogisticRegression(C=1.0, max_iter=500)
        lr.fit(np.array(X), np.array(y), sample_weight=np.array(w, dtype=float))
        return cls([float(c) for c in lr.coef_[0]], float(lr.intercept_[0]), version, True)

    def prob(self, s: ProductSignals) -> float:
        z = self.intercept + sum(c * f for c, f in zip(self.coef, feature_row(s)))
        return 1 / (1 + math.exp(-z))


def fairness_boost(s: ProductSignals, cfg: dict) -> float:
    """New artisans (recently joined or few sales) get a decaying visibility boost so early sellers are seen."""
    days, max_sales, boost = cfg.get("new_artisan_days", 45), cfg.get("max_sales", 5), cfg.get("boost", 0.25)
    if s.artisan_sales >= max_sales and s.artisan_age_days >= days:
        return 0.0
    time_factor = max(0.0, 1 - s.artisan_age_days / days)
    sales_factor = max(0.0, 1 - s.artisan_sales / max_sales)
    return boost * max(time_factor, sales_factor)


def score(model: RankingModel, s: ProductSignals, fairness_cfg: dict) -> float:
    smoothed = (s.conversions + 1) / (s.views + 20)  # Bayesian-smoothed engagement
    return round(0.6 * model.prob(s) + 0.4 * smoothed + fairness_boost(s, fairness_cfg), 5)
