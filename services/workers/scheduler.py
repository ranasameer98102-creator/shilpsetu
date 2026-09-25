"""Tiny scheduler: nightly retraining at 02:00 IST and ONDC catalog sync every 5 minutes.
Run: python -m workers.scheduler"""
import logging
import time
from datetime import datetime, timedelta, timezone

from .jobs import ondc_sync_pending, retrain

IST = timezone(timedelta(hours=5, minutes=30))
log = logging.getLogger("shilpsetu.scheduler")


def main() -> None:
    logging.basicConfig(level=logging.INFO)
    last_retrain_day = None
    while True:
        now = datetime.now(IST)
        try:
            n = ondc_sync_pending()
            if n:
                log.info("synced %d listings to ONDC", n)
            if now.hour == 2 and last_retrain_day != now.date():
                log.info("nightly retrain: %s", retrain())
                last_retrain_day = now.date()
        except Exception:
            log.exception("scheduled job failed")
        time.sleep(300)


if __name__ == "__main__":
    main()
