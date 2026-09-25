import pytest

from ai import pricing as P


@pytest.fixture(scope="module")
def model():
    X, y = P.synthetic_comparables(n=600)
    return P.MarketModel.train(X, y, "test-v1")


def inputs(**kw):
    base = dict(category="Pottery & Ceramics", material_cost=300, hours=24, wage_per_hour=95, commission_pct=6,
                techniques=["blue_pottery"], gi_craft="Jaipur Blue Pottery")
    base.update(kw)
    return P.PriceInputs(**base)


def test_breakdown_adds_up_to_price(model):
    inp = inputs()
    q = P.quote(inp, model.predict(P.features(inp.category, 300, 24, True, 1.15, None)))
    total = sum(l["amount"] for l in q["breakdown"])
    assert total == pytest.approx(q["final_price"], abs=0.05)
    to_artisan = sum(l["amount"] for l in q["breakdown"] if l["to_artisan"])
    assert to_artisan == pytest.approx(q["artisan_share_amount"], abs=0.05)
    assert q["artisan_share_pct"] == pytest.approx(100 * q["artisan_share_amount"] / q["final_price"], abs=0.1)


def test_price_never_below_fair_floor(model):
    # A market estimate far below cost must not drag the price below materials + fair wage.
    low_market = P.MarketEstimate(100, 150, 200, "x")
    q = P.quote(inputs(), low_market)
    assert q["final_price"] >= q["fair_floor"]
    labour = next(l for l in q["breakdown"] if l["key"] == "labour")
    assert labour["amount"] == pytest.approx(24 * 95)


def test_market_uplift_goes_to_artisan():
    q = P.quote(inputs(), P.MarketEstimate(9000, 10000, 12000, "x"))
    prem = next(l for l in q["breakdown"] if l["key"] == "market_premium")
    assert prem["to_artisan"] and prem["amount"] > 0
    assert q["final_price"] < 10000  # half of the uplift, not all of it — stays competitive


def test_fair_wage_floor_scales_with_state_wage():
    lo = P.quote(inputs(wage_per_hour=90), None)
    hi = P.quote(inputs(wage_per_hour=130), None)
    assert hi["fair_floor"] > lo["fair_floor"]


def test_missing_inputs_are_estimated_and_flagged():
    q = P.quote(inputs(material_cost=None, hours=None), P.MarketEstimate(1000, 1500, 2000, "x"))
    assert set(q["inputs"]["estimated_fields"]) == {"hours", "material_cost"}


def test_artisan_adjust_moves_only_artisan_share():
    q = P.quote(inputs(), None)
    fee_before = next(l for l in q["breakdown"] if l["key"] == "platform_fee")["amount"]
    a = P.adjust(q, q["final_price"] + 500)
    fee_after = next(l for l in a["breakdown"] if l["key"] == "platform_fee")["amount"]
    assert fee_after == pytest.approx((q["final_price"] + 500) * 0.06)
    assert a["artisan_share_amount"] - q["artisan_share_amount"] == pytest.approx(500 - (fee_after - fee_before), abs=0.05)
    assert sum(l["amount"] for l in a["breakdown"]) == pytest.approx(a["final_price"], abs=0.05)


def test_below_fair_wage_is_warned_and_shown():
    q = P.quote(inputs(), None)
    a = P.adjust(q, 1000)
    assert "below_fair_wage" in a["warnings"]
    assert any("below fair wage" in l["label"] for l in a["breakdown"])


@pytest.mark.parametrize("spoken,expected", [("make it 1,600", 1600), ("1600 कर दो", 1600), ("सोलह सौ", 1600),
                                             ("दो हज़ार पांच सौ", 2500), ("two thousand", 2000), ("৮০০ টাকা", 800)])
def test_spoken_price(spoken, expected):
    assert P.parse_spoken_price(spoken) == expected


def test_market_model_orders_quantiles(model):
    m = model.predict(P.features("Textiles & Handloom", 800, 56, False, 1.1, None))
    assert m.low <= m.mid <= m.high
    small = model.predict(P.features("Textiles & Handloom", 100, 4, False, 1.0, None))
    assert small.mid < m.mid  # more material and labour -> higher market price


def test_round_price():
    assert P.round_price(1441) == 1450
    assert P.round_price(987) == 990


def test_mockup_demo_vase_is_above_fair_wage_at_1450():
    """The flagship demo (₹1,450, Jaipur, 6 hours, ₹120 materials) must pay at least the Rajasthan fair wage."""
    from ai import nlu as N

    ex = N.extract("Blue pottery vase, hand-painted")
    ex = N.merge(ex, N.answer_to_extraction("time_hours", "छह घंटे"))
    ex = N.merge(ex, N.answer_to_extraction("material_cost", "एक सौ बीस"))
    inp = P.PriceInputs(category=ex.category, material_cost=ex.material_cost, hours=ex.time_hours, wage_per_hour=95,
                        commission_pct=6, techniques=ex.technique, gi_craft=ex.gi_craft)
    a = P.adjust(P.quote(inp, None), 1450)
    assert a["warnings"] == [] and a["artisan_share_pct"] > 80
