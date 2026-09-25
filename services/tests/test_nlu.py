import json
from pathlib import Path

import pytest

from ai import nlu as N

FIXTURES = json.loads((Path(__file__).parent / "fixtures" / "nlu_cases.json").read_text(encoding="utf-8"))


@pytest.mark.parametrize("case", FIXTURES, ids=[c["id"] for c in FIXTURES])
def test_extraction_fixtures(case):
    ex = N.extract(case["text"]).to_dict()
    for k, v in case["expect"].items():
        if isinstance(v, list):
            assert set(v) <= set(ex[k]), f"{k}: {ex[k]} missing {v}"
        else:
            assert ex[k] == v, f"{k}: {ex[k]} != {v}"


def test_listing_for_mockup_phrase():
    ex = N.extract("Blue pottery vase, hand-painted")
    lst = N.generate_listing(ex, {"name": "Meena Devi", "state": "Rajasthan"})
    assert lst["title"] == "Hand-painted Blue Pottery Vase"
    assert lst["category"] == "Pottery & Ceramics"
    assert "Meena Devi" in lst["description"]
    assert "gi-tagged" in lst["tags"]


def test_follow_up_questions_in_artisan_language():
    qs = N.follow_up_questions(N.extract("नीली पॉटरी का फूलदान"), "hi")
    fields = [q["field"] for q in qs]
    assert fields == ["time_hours", "material_cost"]
    assert qs[0]["text"] == "इसे बनाने में कितने दिन लगे?"


def test_bare_number_answers_fill_the_asked_slot():
    base = N.extract("नीली पॉटरी का फूलदान")
    base = N.merge(base, N.answer_to_extraction("time_hours", "तीन"))
    base = N.merge(base, N.answer_to_extraction("material_cost", "चार सौ"))
    assert base.time_hours == 24 and base.material_cost == 400
    assert N.missing_fields(base) == []


def test_translations_in_native_script():
    ex = N.extract("handloom cotton saree red")
    a = {"name": "Rina Das", "name_native": "রিনা দাস", "state": "West Bengal"}
    bn = N.template_translation(ex, a, "bn")
    assert "শাড়ি" in bn["title"] and "রিনা দাস" in bn["description"]
    hi = N.template_translation(ex, a, "hi")
    assert "साड़ी" in hi["title"]
    assert N.template_translation(ex, a, "ta") is None  # handled by the translation provider instead
