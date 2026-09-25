"""Indic ASR and translation behind provider interfaces, with a shared result cache.

ASR:          mock | bhashini (ULCA pipeline) | ai4bharat (self-hosted IndicConformer / IndicWhisper endpoint)
Translation:  mock | bhashini (NMT)          | indictrans2 (self-hosted IndicTrans2 endpoint)
"""
from __future__ import annotations

import base64
import hashlib
import json
import logging
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

import httpx

log = logging.getLogger(__name__)

SEED_TRANSCRIPTS = Path(__file__).resolve().parents[2] / "seed" / "audio" / "transcripts.json"


@dataclass
class Transcript:
    text: str
    language: str
    confidence: float
    provider: str


# ------------------------------------------------------------------ cache

def _cache_get(db, kind: str, key: str):
    if db is None:
        return None
    from api.models import AiCache

    row = db.get(AiCache, key)
    return row.value if row and row.kind == kind else None


def _cache_put(db, kind: str, key: str, value) -> None:
    if db is None:
        return
    from api.models import AiCache

    if not db.get(AiCache, key):
        db.add(AiCache(key=key, kind=kind, value=value))
        db.flush()


# ------------------------------------------------------------------ ASR

@lru_cache
def _seed_transcripts() -> dict:
    if SEED_TRANSCRIPTS.exists():
        return json.loads(SEED_TRANSCRIPTS.read_text(encoding="utf-8"))
    return {}


class MockASR:
    name = "mock"

    def transcribe(self, audio: bytes, language: str, content_type: str = "audio/wav") -> Transcript:
        digest = hashlib.sha256(audio).hexdigest()
        known = _seed_transcripts().get(digest)
        if known:
            return Transcript(known["text"], known.get("language", language), 0.97, self.name)
        # Unknown clip: say so honestly (the pipeline then asks "what is this item?") rather than invent a product.
        return Transcript("", language, 0.0, self.name)


class BhashiniASR:
    """Bhashini ULCA pipeline: fetch pipeline config (service id + inference endpoint), then compute."""
    name = "bhashini"

    def __init__(self, user_id: str, api_key: str, pipeline_id: str, config_url: str):
        self.user_id, self.api_key, self.pipeline_id, self.config_url = user_id, api_key, pipeline_id, config_url

    def _config(self, task: dict) -> tuple[str, str, str]:
        r = httpx.post(self.config_url, timeout=20, headers={"userID": self.user_id, "ulcaApiKey": self.api_key},
                       json={"pipelineTasks": [task], "pipelineRequestConfig": {"pipelineId": self.pipeline_id}})
        r.raise_for_status()
        data = r.json()
        endpoint = data["pipelineInferenceAPIEndPoint"]
        service_id = data["pipelineResponseConfig"][0]["config"][0]["serviceId"]
        return endpoint["callbackUrl"], endpoint["inferenceApiKey"]["value"], service_id

    def transcribe(self, audio: bytes, language: str, content_type: str = "audio/wav") -> Transcript:
        url, key, service_id = self._config({"taskType": "asr", "config": {"language": {"sourceLanguage": language}}})
        fmt = "wav" if "wav" in content_type else ("flac" if "flac" in content_type else "mp3")
        body = {
            "pipelineTasks": [{"taskType": "asr", "config": {"language": {"sourceLanguage": language},
                                                             "serviceId": service_id, "audioFormat": fmt,
                                                             "samplingRate": 16000}}],
            "inputData": {"audio": [{"audioContent": base64.b64encode(audio).decode()}]},
        }
        r = httpx.post(url, json=body, headers={"Authorization": key}, timeout=60)
        r.raise_for_status()
        text = r.json()["pipelineResponse"][0]["output"][0]["source"]
        return Transcript(text, language, 0.9, self.name)

    def translate(self, text: str, source: str, target: str) -> str:
        task = {"taskType": "translation", "config": {"language": {"sourceLanguage": source, "targetLanguage": target}}}
        url, key, service_id = self._config(task)
        task["config"]["serviceId"] = service_id
        r = httpx.post(url, json={"pipelineTasks": [task], "inputData": {"input": [{"source": text}]}},
                       headers={"Authorization": key}, timeout=60)
        r.raise_for_status()
        return r.json()["pipelineResponse"][0]["output"][0]["target"]


class AI4BharatASR:
    """Self-hosted AI4Bharat IndicConformer / IndicWhisper behind a simple JSON endpoint."""
    name = "ai4bharat"

    def __init__(self, url: str):
        self.url = url

    def transcribe(self, audio: bytes, language: str, content_type: str = "audio/wav") -> Transcript:
        r = httpx.post(self.url, timeout=60, json={"language": language,
                                                   "audio_b64": base64.b64encode(audio).decode()})
        r.raise_for_status()
        data = r.json()
        return Transcript(data["text"], language, float(data.get("confidence", 0.85)), self.name)


def get_asr(provider: str):
    from api.config import get_settings

    s = get_settings()
    if provider == "bhashini":
        return BhashiniASR(s.bhashini_user_id, s.bhashini_api_key, s.bhashini_pipeline_id, s.bhashini_config_url)
    if provider == "ai4bharat":
        return AI4BharatASR(s.ai4bharat_asr_url)
    return MockASR()


def transcribe(db, provider: str, audio: bytes, language: str, content_type: str = "audio/wav",
               device_transcript: str | None = None) -> Transcript:
    """Prefer an on-device transcript when the phone produced one (works offline); otherwise run ASR.
    Falls back to the mock provider if the real one fails, so a capture is never lost."""
    if device_transcript and device_transcript.strip():
        return Transcript(device_transcript.strip(), language, 0.85, "on-device")
    key = hashlib.sha256(b"asr:" + language.encode() + b":" + audio).hexdigest()
    cached = _cache_get(db, "asr", key)
    if cached:
        return Transcript(**cached)
    try:
        t = get_asr(provider).transcribe(audio, language, content_type)
    except Exception as e:  # network, quota, bad audio
        log.warning("ASR provider %s failed (%s); using mock", provider, e)
        t = MockASR().transcribe(audio, language, content_type)
        t.confidence = min(t.confidence, 0.5)
    _cache_put(db, "asr", key, t.__dict__)
    return t


# ------------------------------------------------------------------ translation

class MockTranslator:
    """No network: returns the source text tagged for human review. Listing text for en/hi/bn/mr is produced
    natively by the template writer, so this is only hit for free text (e.g. stories) in other languages."""
    name = "mock"

    def translate(self, text: str, source: str, target: str) -> str:
        return text


class IndicTrans2Translator:
    name = "indictrans2"

    def __init__(self, url: str):
        self.url = url

    def translate(self, text: str, source: str, target: str) -> str:
        r = httpx.post(self.url, timeout=60, json={"text": text, "src_lang": source, "tgt_lang": target})
        r.raise_for_status()
        return r.json()["translation"]


def get_translator(provider: str):
    from api.config import get_settings

    s = get_settings()
    if provider == "bhashini":
        return BhashiniASR(s.bhashini_user_id, s.bhashini_api_key, s.bhashini_pipeline_id, s.bhashini_config_url)
    if provider == "indictrans2":
        return IndicTrans2Translator(s.indictrans2_url)
    return MockTranslator()


def translate(db, provider: str, text: str, source: str, target: str) -> tuple[str, bool]:
    """Returns (text, machine_translated_ok). False means 'needs review' (mock or provider failure)."""
    if not text or source == target:
        return text, True
    key = hashlib.sha256(f"mt:{provider}:{source}:{target}:{text}".encode()).hexdigest()
    cached = _cache_get(db, "mt", key)
    if cached:
        return cached["text"], cached["ok"]
    try:
        tr = get_translator(provider)
        out, ok = tr.translate(text, source, target), tr.name != "mock"
    except Exception as e:
        log.warning("translation provider %s failed (%s)", provider, e)
        out, ok = text, False
    _cache_put(db, "mt", key, {"text": out, "ok": ok})
    return out, ok
