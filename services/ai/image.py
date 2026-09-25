"""Computer-vision cleanup: one photo in any lighting / background -> marketplace-ready variants.

Pipeline: EXIF orient -> gray-world white balance -> exposure/contrast (CLAHE + gamma) -> denoise ->
foreground mask (rembg U^2-Net if installed, else GrabCut) -> auto-crop -> composite on a clean cream
background with a soft shadow -> square (1:1) and 4:5 exports + small WebP thumbnail. Original is kept untouched.
"""
from __future__ import annotations

import io
import logging
from dataclasses import dataclass, field

import cv2
import numpy as np
from PIL import Image, ImageOps

log = logging.getLogger(__name__)

CREAM_BGR = (226, 239, 246)  # #F6EFE2
MAX_WORK = 1200


@dataclass
class Enhanced:
    square_jpeg: bytes
    portrait_jpeg: bytes
    thumb_webp: bytes
    width: int
    height: int
    background_removed: bool
    quality: dict = field(default_factory=dict)
    hints: list[str] = field(default_factory=list)


def _decode(data: bytes) -> np.ndarray:
    img = Image.open(io.BytesIO(data))
    img = ImageOps.exif_transpose(img).convert("RGB")
    arr = cv2.cvtColor(np.asarray(img), cv2.COLOR_RGB2BGR)
    h, w = arr.shape[:2]
    scale = min(1.0, MAX_WORK / max(h, w))
    if scale < 1:
        arr = cv2.resize(arr, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)
    return arr


def assess_quality(img: np.ndarray, fill: float | None = None) -> tuple[dict, list[str]]:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    brightness = float(gray.mean()) / 255
    sharpness = float(cv2.Laplacian(cv2.resize(gray, (512, int(512 * gray.shape[0] / gray.shape[1]))),
                                    cv2.CV_64F).var())
    hints = []
    if brightness < 0.28:
        hints.append("too_dark")
    elif brightness > 0.85:
        hints.append("too_bright")
    if sharpness < 40:
        hints.append("blurry")
    if fill is not None and fill < 0.12:
        hints.append("move_closer")
    return {"brightness": round(brightness, 3), "sharpness": round(sharpness, 1),
            "fill": None if fill is None else round(fill, 3)}, hints


def white_balance(img: np.ndarray) -> np.ndarray:
    """Gray-world in LAB: pull a/b channel means toward neutral, partially (keeps the craft's true colours)."""
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB).astype(np.float32)
    for c in (1, 2):
        lab[:, :, c] -= (lab[:, :, c].mean() - 128) * 0.7 * (lab[:, :, 0] / 255.0)
    return cv2.cvtColor(np.clip(lab, 0, 255).astype(np.uint8), cv2.COLOR_LAB2BGR)


def fix_exposure(img: np.ndarray) -> np.ndarray:
    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)
    l = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8)).apply(l)
    mean = l.mean() / 255
    if 0.05 < mean < 0.95:
        gamma = np.log(0.52) / np.log(mean)  # move mid-tones toward 0.52
        gamma = float(np.clip(gamma, 0.55, 1.6))
        lut = np.array([((i / 255.0) ** gamma) * 255 for i in range(256)], dtype=np.uint8)
        l = cv2.LUT(l, lut)
    return cv2.cvtColor(cv2.merge([l, a, b]), cv2.COLOR_LAB2BGR)


def denoise(img: np.ndarray) -> np.ndarray:
    return cv2.fastNlMeansDenoisingColored(img, None, 4, 4, 7, 21)


_rembg_sessions: dict = {}


def _mask_rembg(img: np.ndarray, model: str = "u2netp") -> np.ndarray | None:
    try:
        from rembg import new_session, remove  # type: ignore
    except ImportError:
        return None
    if model not in _rembg_sessions:  # model weights download once, then load from cache
        _rembg_sessions[model] = new_session(model)
    rgba = remove(Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGR2RGB)), session=_rembg_sessions[model])
    return np.asarray(rgba)[:, :, 3]


def _mask_grabcut(img: np.ndarray) -> np.ndarray:
    h, w = img.shape[:2]
    scale = 600 / max(h, w)
    small = cv2.resize(img, (int(w * scale), int(h * scale))) if scale < 1 else img.copy()
    sh, sw = small.shape[:2]
    mask = np.zeros((sh, sw), np.uint8)
    mx, my = int(sw * 0.06), int(sh * 0.06)
    rect = (mx, my, sw - 2 * mx, sh - 2 * my)
    bgd, fgd = np.zeros((1, 65), np.float64), np.zeros((1, 65), np.float64)
    cv2.grabCut(small, mask, rect, bgd, fgd, 5, cv2.GC_INIT_WITH_RECT)
    fg = np.where((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD), 255, 0).astype(np.uint8)
    # keep the largest connected component and fill holes
    n, labels, stats, _ = cv2.connectedComponentsWithStats(fg)
    if n > 1:
        largest = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
        fg = np.where(labels == largest, 255, 0).astype(np.uint8)
    fg = cv2.morphologyEx(fg, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    return cv2.resize(fg, (w, h), interpolation=cv2.INTER_LINEAR)


def foreground_mask(img: np.ndarray, mode: str, model: str = "u2netp") -> np.ndarray | None:
    if mode == "off":
        return None
    mask = None
    if mode in ("auto", "rembg"):
        try:
            mask = _mask_rembg(img, model)
        except Exception as e:
            log.warning("rembg failed: %s", e)
    if mask is None and mode in ("auto", "grabcut"):
        try:
            mask = _mask_grabcut(img)
        except Exception as e:
            log.warning("grabcut failed: %s", e)
    if mask is None:
        return None
    fill = (mask > 127).mean()
    if fill < 0.03 or fill > 0.97:  # segmentation clearly failed; keep the photo as-is
        return None
    return mask


def _compose(img: np.ndarray, mask: np.ndarray | None, out_w: int, out_h: int) -> np.ndarray:
    if mask is not None:
        ys, xs = np.where(mask > 127)
        x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    else:
        h, w = img.shape[:2]
        x0, x1, y0, y1 = 0, w - 1, 0, h - 1
    crop = img[y0:y1 + 1, x0:x1 + 1]
    cm = mask[y0:y1 + 1, x0:x1 + 1] if mask is not None else None

    pad = 0.12 if mask is not None else 0.0
    avail_w, avail_h = out_w * (1 - 2 * pad), out_h * (1 - 2 * pad)
    ch, cw = crop.shape[:2]
    s = min(avail_w / cw, avail_h / ch) if mask is not None else max(out_w / cw, out_h / ch)
    nw, nh = max(1, int(cw * s)), max(1, int(ch * s))
    crop = cv2.resize(crop, (nw, nh), interpolation=cv2.INTER_AREA if s < 1 else cv2.INTER_CUBIC)

    canvas = np.full((out_h, out_w, 3), CREAM_BGR, np.uint8)
    if cm is None:  # no segmentation: centre-crop fill
        x, y = (nw - out_w) // 2, (nh - out_h) // 2
        return crop[y:y + out_h, x:x + out_w]

    cm = cv2.resize(cm, (nw, nh), interpolation=cv2.INTER_LINEAR)
    alpha = cv2.GaussianBlur(cm, (5, 5), 0).astype(np.float32)[:, :, None] / 255.0
    ox, oy = (out_w - nw) // 2, (out_h - nh) // 2
    # soft ground shadow
    shadow = np.zeros((out_h, out_w), np.float32)
    cv2.ellipse(shadow, (out_w // 2, min(out_h - 5, oy + nh)), (int(nw * 0.42), max(6, int(nh * 0.05))),
                0, 0, 360, 1.0, -1)
    shadow = cv2.GaussianBlur(shadow, (0, 0), sigmaX=max(8, nw * 0.04))[:, :, None] * 0.22
    canvas = (canvas * (1 - shadow)).astype(np.uint8)
    region = canvas[oy:oy + nh, ox:ox + nw].astype(np.float32)
    canvas[oy:oy + nh, ox:ox + nw] = (crop * alpha + region * (1 - alpha)).astype(np.uint8)
    return canvas


def _jpeg(img: np.ndarray, q: int = 88) -> bytes:
    return cv2.imencode(".jpg", img, [cv2.IMWRITE_JPEG_QUALITY, q, cv2.IMWRITE_JPEG_PROGRESSIVE, 1])[1].tobytes()


def _webp(img: np.ndarray, q: int = 70) -> bytes:
    return cv2.imencode(".webp", img, [cv2.IMWRITE_WEBP_QUALITY, q])[1].tobytes()


def enhance(data: bytes, background_removal: str = "auto", size: int = 1080, model: str = "u2netp") -> Enhanced:
    img = _decode(data)
    quality, hints = assess_quality(img)
    work = denoise(fix_exposure(white_balance(img)))
    mask = foreground_mask(work, background_removal, model)
    if mask is not None:
        quality, hints = assess_quality(img, fill=float((mask > 127).mean()))
    square = _compose(work, mask, size, size)
    portrait = _compose(work, mask, size, int(size * 1.25))
    thumb = cv2.resize(square, (400, 400), interpolation=cv2.INTER_AREA)
    return Enhanced(_jpeg(square), _jpeg(portrait), _webp(thumb), size, size, mask is not None, quality, hints)


def quick_quality(data: bytes) -> dict:
    """Cheap check for live camera hints (no enhancement)."""
    img = _decode(data)
    q, hints = assess_quality(img)
    return {**q, "hints": hints}
