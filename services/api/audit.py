"""Append-only, hash-chained audit log."""
import hashlib
import json
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from .models import AuditLog, now

GENESIS = "0" * 64


def _ts(dt: datetime) -> str:
    dt = dt.replace(tzinfo=timezone.utc) if dt.tzinfo is None else dt.astimezone(timezone.utc)
    return dt.isoformat()


def _digest(prev_hash: str, ts: str, actor: str | None, action: str, entity: str, entity_id: str, data: dict) -> str:
    body = json.dumps([prev_hash, ts, actor, action, entity, entity_id, data], sort_keys=True, default=str)
    return hashlib.sha256(body.encode()).hexdigest()


def record(db: Session, action: str, entity: str, entity_id: str, data: dict | None = None,
           actor_id: str | None = None) -> AuditLog:
    last = db.execute(select(AuditLog).order_by(AuditLog.id.desc()).limit(1)).scalar_one_or_none()
    prev = last.hash if last else GENESIS
    ts = now()
    data = data or {}
    row = AuditLog(ts=ts, actor_id=actor_id, action=action, entity=entity, entity_id=entity_id, data=data,
                   prev_hash=prev, hash=_digest(prev, _ts(ts), actor_id, action, entity, entity_id, data))
    db.add(row)
    db.flush()
    return row


def verify_chain(db: Session) -> tuple[bool, int | None]:
    """Returns (ok, first_bad_row_id)."""
    prev = GENESIS
    for row in db.execute(select(AuditLog).order_by(AuditLog.id)).scalars():
        expected = _digest(prev, _ts(row.ts), row.actor_id, row.action, row.entity, row.entity_id, row.data)
        if row.prev_hash != prev or row.hash != expected:
            return False, row.id
        prev = row.hash
    return True, None


def _no_updates(*_):
    raise RuntimeError("audit_log is append-only")


from sqlalchemy import event  # noqa: E402

event.listen(AuditLog, "before_update", _no_updates)
event.listen(AuditLog, "before_delete", _no_updates)
