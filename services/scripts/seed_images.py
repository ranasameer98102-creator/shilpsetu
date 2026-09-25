"""Procedurally draw demo 'phone photos' of crafts: object on a cluttered, unevenly lit background.

These stand in for real artisan photos in the demo seed; the real image-enhancement pipeline then cleans
them up exactly as it would a real capture. Run: python -m scripts.seed_images
"""
from __future__ import annotations

import math
from pathlib import Path

import cv2
import numpy as np

OUT = Path(__file__).resolve().parents[2] / "seed" / "images"

COBALT = (140, 50, 20)
TURQ = (170, 150, 40)
WHITE = (225, 235, 240)
BRASS = (60, 140, 185)
BRASS_DARK = (30, 85, 120)


def background(rng, w=960, h=1200) -> np.ndarray:
    base = rng.integers(60, 120, size=3)
    img = np.full((h, w, 3), base, np.uint8).astype(np.float32)
    for _ in range(14):  # clutter: blobs and shapes of a courtyard / floor
        c = tuple(int(v) for v in rng.integers(30, 170, size=3))
        cv2.ellipse(img, (int(rng.integers(0, w)), int(rng.integers(0, h))),
                    (int(rng.integers(40, 260)), int(rng.integers(20, 140))), float(rng.integers(0, 180)), 0, 360, c, -1)
    img = cv2.GaussianBlur(img, (0, 0), 18)
    yy, xx = np.mgrid[0:h, 0:w]
    light = 0.55 + 0.6 * np.exp(-(((xx - w * 0.3) / (w * 0.8)) ** 2 + ((yy - h * 0.25) / (h * 0.8)) ** 2))
    img *= light[:, :, None]
    img[:, :, 2] *= 1.12  # warm tungsten cast
    return np.clip(img, 0, 255)


def finish(img: np.ndarray, rng) -> np.ndarray:
    img = img * rng.uniform(0.62, 0.85)  # underexposed like a real indoor phone shot
    img += rng.normal(0, 6, img.shape)  # sensor noise
    return np.clip(img, 0, 255).astype(np.uint8)


def flower(img, c, r, color, petals=6):
    for k in range(petals):
        a = 2 * math.pi * k / petals
        cv2.circle(img, (int(c[0] + r * math.cos(a)), int(c[1] + r * math.sin(a))), max(2, r // 2), color, -1, cv2.LINE_AA)
    cv2.circle(img, c, max(2, r // 2), TURQ, -1, cv2.LINE_AA)


def shade(img, mask, strength=0.35):
    """Left-lit cylindrical shading over a mask so objects read as 3D."""
    h, w = mask.shape
    ys, xs = np.where(mask > 0)
    if len(xs) == 0:
        return img
    x0, x1 = xs.min(), xs.max()
    grad = np.clip((np.arange(w) - x0) / max(1, x1 - x0), 0, 1)
    f = 1 - strength * (grad - 0.35) ** 2 * 2.2
    f = np.tile(f, (h, 1))
    img[mask > 0] = img[mask > 0] * f[mask > 0][:, None]
    return img


def pottery(kind: str, rng, palette=(WHITE, COBALT)) -> np.ndarray:
    img = background(rng)
    h, w = img.shape[:2]
    mask = np.zeros((h, w), np.uint8)
    cx, cy = w // 2, int(h * 0.55)
    ground, ink = palette
    if kind == "vase":
        cv2.ellipse(mask, (cx, cy + 60), (230, 280), 0, 0, 360, 255, -1)
        cv2.rectangle(mask, (cx - 80, cy - 390), (cx + 80, cy - 180), 255, -1)
        cv2.ellipse(mask, (cx, cy - 390), (120, 34), 0, 0, 360, 255, -1)
    elif kind == "bowl":
        cv2.ellipse(mask, (cx, cy), (330, 230), 0, 0, 180, 255, -1)
        cv2.ellipse(mask, (cx, cy), (330, 70), 0, 0, 360, 255, -1)
    elif kind == "plate":
        cv2.ellipse(mask, (cx, cy), (360, 300), 0, 0, 360, 255, -1)
    elif kind == "tile":
        pts = np.array([[cx - 300, cy - 280], [cx + 300, cy - 300], [cx + 320, cy + 300], [cx - 290, cy + 290]])
        cv2.fillPoly(mask, [pts], 255)
    elif kind == "mug":
        cv2.rectangle(mask, (cx - 190, cy - 260), (cx + 190, cy + 240), 255, -1)
        cv2.ellipse(mask, (cx + 210, cy), (90, 140), 0, -90, 90, 255, 40)
    img[mask > 0] = ground
    ys, xs = np.where(mask > 0)
    for _ in range(26 if kind != "mug" else 14):  # hand-painted florals
        i = int(rng.integers(0, len(xs)))
        flower(img, (int(xs[i]), int(ys[i])), int(rng.integers(12, 30)), ink)
    if kind in ("plate", "bowl"):
        cv2.ellipse(img, (cx, cy), (300, 240 if kind == "plate" else 60), 0, 0, 360, ink, 10, cv2.LINE_AA)
    img[mask == 0] = img[mask == 0]
    return finish(shade(img, mask), rng)


def textile(kind: str, rng, body, border, motif=(60, 170, 220)) -> np.ndarray:
    img = background(rng)
    h, w = img.shape[:2]
    mask = np.zeros((h, w), np.uint8)
    x0, y0, x1, y1 = 150, 230, w - 150, h - 170
    pts = np.array([[x0, y0 + 20], [x1, y0], [x1 + 10, y1], [x0 - 10, y1 - 15]])
    cv2.fillPoly(mask, [pts], 255)
    img[mask > 0] = body
    # folds
    for k in range(1, 4):
        y = y0 + k * (y1 - y0) // 4
        cv2.line(img, (x0, y), (x1, y - 8), tuple(int(c * 0.7) for c in body), 6, cv2.LINE_AA)
    # borders + zari
    cv2.rectangle(img, (x0, y1 - 150), (x1, y1 - 10), border, -1)
    for yy in (y1 - 150, y1 - 20):
        cv2.line(img, (x0, yy), (x1, yy - 3), (80, 190, 230), 7, cv2.LINE_AA)
    if kind in ("saree", "stole"):
        for yy in range(y0 + 60, y1 - 170, 90):
            for xx in range(x0 + 60, x1 - 40, 110):
                flower(img, (xx + (yy // 90 % 2) * 50, yy), 11, motif, 5)
    if kind == "kantha":
        for yy in range(y0 + 40, y1 - 170, 22):
            for xx in range(x0 + 20, x1 - 20, 26):
                cv2.line(img, (xx, yy), (xx + 12, yy), motif, 3)
    img = cv2.GaussianBlur(img.astype(np.float32), (0, 0), 0.8)
    return finish(shade(img, mask, 0.2), rng)


def dhokra(kind: str, rng) -> np.ndarray:
    img = background(rng)
    h, w = img.shape[:2]
    mask = np.zeros((h, w), np.uint8)
    cx, cy = w // 2, int(h * 0.55)
    if kind in ("horse", "elephant"):
        body_rx = 250 if kind == "elephant" else 210
        cv2.ellipse(mask, (cx, cy - 40), (body_rx, 150), 0, 0, 360, 255, -1)
        for dx in (-150, -60, 70, 160):  # legs
            cv2.rectangle(mask, (cx + dx - 26, cy + 60), (cx + dx + 26, cy + 330), 255, -1)
        if kind == "horse":
            cv2.fillPoly(mask, [np.array([[cx + 150, cy - 120], [cx + 250, cy - 380], [cx + 330, cy - 360], [cx + 230, cy - 60]])], 255)
            cv2.ellipse(mask, (cx + 300, cy - 360), (70, 45), -20, 0, 360, 255, -1)
            cv2.line(mask, (cx - 200, cy - 60), (cx - 300, cy + 120), 255, 30)
        else:
            cv2.circle(mask, (cx + 260, cy - 110), 120, 255, -1)
            cv2.line(mask, (cx + 330, cy - 60), (cx + 360, cy + 260), 255, 50)
            cv2.ellipse(mask, (cx + 190, cy - 140), (60, 110), 0, 0, 360, 255, -1)
    elif kind == "lamp":
        cv2.ellipse(mask, (cx, cy + 200), (240, 70), 0, 0, 360, 255, -1)
        cv2.rectangle(mask, (cx - 30, cy - 200), (cx + 30, cy + 200), 255, -1)
        cv2.ellipse(mask, (cx, cy - 220), (200, 80), 0, 0, 180, 255, -1)
    elif kind == "bell":
        cv2.fillPoly(mask, [np.array([[cx - 90, cy - 250], [cx + 90, cy - 250], [cx + 230, cy + 220], [cx - 230, cy + 220]])], 255)
        cv2.circle(mask, (cx, cy - 290), 50, 255, 18)
    elif kind == "figurine":
        cv2.ellipse(mask, (cx, cy + 40), (150, 280), 0, 0, 360, 255, -1)
        cv2.circle(mask, (cx, cy - 300), 95, 255, -1)
        cv2.line(mask, (cx - 140, cy - 60), (cx - 290, cy + 120), 255, 40)
        cv2.line(mask, (cx + 140, cy - 60), (cx + 290, cy - 180), 255, 40)
    img[mask > 0] = BRASS
    ys, xs = np.where(mask > 0)
    for _ in range(220):  # dhokra wire-scroll texture
        i = int(rng.integers(0, len(xs)))
        cv2.ellipse(img, (int(xs[i]), int(ys[i])), (int(rng.integers(6, 16)),) * 2, 0, 0, 300, BRASS_DARK, 2, cv2.LINE_AA)
    return finish(shade(img, mask, 0.45), rng)


def basket(rng) -> np.ndarray:
    img = background(rng)
    h, w = img.shape[:2]
    mask = np.zeros((h, w), np.uint8)
    cx, cy = w // 2, int(h * 0.55)
    cv2.fillPoly(mask, [np.array([[cx - 320, cy - 200], [cx + 320, cy - 200], [cx + 250, cy + 260], [cx - 250, cy + 260]])], 255)
    img[mask > 0] = (90, 170, 205)
    for y in range(cy - 200, cy + 260, 24):
        cv2.line(img, (cx - 330, y), (cx + 330, y), (50, 120, 160), 5)
    for x in range(cx - 320, cx + 320, 30):
        cv2.line(img, (x, cy - 200), (x + 10, cy + 260), (60, 130, 170), 4)
    img[mask == 0] = img[mask == 0]
    return finish(shade(img, mask, 0.3), rng)


def render(spec: dict, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    k = spec["kind"]
    if k in ("vase", "bowl", "plate", "tile", "mug"):
        pal = (WHITE, COBALT) if spec.get("palette") != "turquoise" else ((215, 225, 200), TURQ)
        return pottery(k, rng, pal)
    if k in ("saree", "stole", "kantha", "fabric"):
        return textile(k, rng, tuple(spec["body"]), tuple(spec["border"]), tuple(spec.get("motif", (60, 170, 220))))
    if k in ("horse", "elephant", "lamp", "bell", "figurine"):
        return dhokra(k, rng)
    return basket(rng)


def generate(products: list[dict]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for i, p in enumerate(products):
        path = OUT / f"{p['slug']}.jpg"
        if not path.exists():
            if p["image"].get("photo"):
                raise FileNotFoundError(f"missing product photo {path} (see seed/images/CREDITS.json)")
            cv2.imwrite(str(path), render(p["image"], 1000 + i), [cv2.IMWRITE_JPEG_QUALITY, 85])


if __name__ == "__main__":
    import json

    data = json.loads((OUT.parent / "demo_data.json").read_text(encoding="utf-8"))
    generate(data["products"])
    print(f"wrote {len(data['products'])} images to {OUT}")
