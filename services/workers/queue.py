"""Job dispatch. JOB_MODE: sync (tests), inline (background thread in the API process — no Redis needed),
rq (Redis queue consumed by `python -m workers.worker`, scales to zero when idle)."""
from __future__ import annotations

import logging
import threading

from api.config import get_settings

log = logging.getLogger(__name__)


def enqueue(fn, *args) -> None:
    mode = get_settings().job_mode
    if mode == "sync":
        fn(*args)
    elif mode == "rq":
        from redis import Redis
        from rq import Queue

        Queue("shilpsetu", connection=Redis.from_url(get_settings().redis_url)).enqueue(fn, *args, job_timeout=600)
    else:
        threading.Thread(target=_safe, args=(fn, *args), daemon=True).start()


def _safe(fn, *args):
    try:
        fn(*args)
    except Exception:
        log.exception("background job %s failed", getattr(fn, "__name__", fn))
