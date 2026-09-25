"""RQ worker entrypoint (JOB_MODE=rq). Run: python -m workers.worker"""
from redis import Redis
from rq import Queue, Worker

from api.config import get_settings

if __name__ == "__main__":
    conn = Redis.from_url(get_settings().redis_url)
    Worker([Queue("shilpsetu", connection=conn)], connection=conn).work(with_scheduler=False)
