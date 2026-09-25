"""Shilpi the assistant, product stories and affordable pricing."""
from conftest import capture_listing, login, new_artisan


def _live_product(client, phone: str, said: str) -> dict:
    h = new_artisan(client, phone)
    p = capture_listing(client, h, said)
    client.post(f"/api/v1/products/{p['id']}/approve", headers=h)
    return p


def test_buyer_greeting_has_craft_of_the_day(client):
    g = client.get("/api/v1/assistant/greeting", params={"lang": "en"}).json()
    assert g["name"] == "Shilpi" and g["craft_of_day"]["history"] and g["suggestions"]


def test_artisan_greeting_tracks_streak_goal_and_badges(client):
    h = new_artisan(client, "+919866660001")
    p = capture_listing(client, h, "blue pottery bowl, one day, materials 100 rupees")
    client.post(f"/api/v1/products/{p['id']}/approve", headers=h)
    g = client.get("/api/v1/assistant/greeting", params={"lang": "hi"}, headers=h).json()
    assert g["streak"] >= 1
    assert g["goal"] == {"done": 1, "target": 1}
    earned = {b["key"] for b in g["badges"] if b["earned"]}
    assert "first_listing" in earned and "first_sale" not in earned
    assert "लक्ष्य" in g["message"]


def test_gift_search_respects_budget(client):
    _live_product(client, "+919866660002", "Madhubani bookmark, hand-painted, 1 hour, materials 15 rupees, 20 grams")
    r = client.post("/api/v1/assistant/chat", json={"message": "Gifts under ₹300", "lang": "en"}).json()
    assert r["intent"] == "gifts" and r["products"]
    assert all(p["price"] <= 300 for p in r["products"])


def test_craft_question_tells_the_story_in_hindi(client):
    r = client.post("/api/v1/assistant/chat", json={"message": "मधुबनी के बारे में बताओ", "lang": "hi"}).json()
    assert r["intent"] == "craft_info"
    assert "मिथिला" in r["reply"] and r["actions"][0]["route"].startswith("/store/search")


def test_artisan_gets_listing_help_with_a_shortcut(client):
    h = new_artisan(client, "+919866660003")
    r = client.post("/api/v1/assistant/chat", json={"message": "How do I add a product?"}, headers=h).json()
    assert r["intent"] == "how_to_list" and r["actions"][0]["route"] == "/artisan/capture"


def test_product_page_has_details_story_and_artisan_facts(client):
    p = _live_product(client, "+919866660004", "Warli painting on cloth, rice paste, 2 days, materials 120 rupees")
    d = client.get(f"/api/v1/storefront/products/{p['id']}", params={"lang": "en"}).json()
    assert d["craft"]["key"] == "warli" and d["craft"]["gi"] == "Warli Painting"
    keys = {r["key"] for r in d["details"]}
    assert {"technique", "time", "care", "gi"} <= keys
    assert d["artisan"]["live_products"] >= 1


def test_small_items_stay_affordable_and_fair(client):
    p = _live_product(client, "+919866660005", "Jute craft pouch, hand stitched, 1 hour, materials 20 rupees, 60 grams")
    d = client.get(f"/api/v1/storefront/products/{p['id']}").json()
    q = d["price_quote"]
    assert d["price"] <= 300
    assert q["effective_hourly_wage"] >= 100  # the artisan's fair wage is never cut
