from fastapi import HTTPException
from sqlalchemy.orm import Session

from api.models import Upload, User


def completed_upload(db: Session, upload_id: str, user: User, kind: str | None = None) -> Upload:
    up = db.get(Upload, upload_id)
    if not up or up.owner_user_id != user.id:
        raise HTTPException(404, f"upload {upload_id} not found")
    if up.status != "complete":
        raise HTTPException(409, f"upload {upload_id} is not complete ({up.received}/{up.total_size} bytes)")
    if kind and up.kind != kind:
        raise HTTPException(400, f"upload {upload_id} is {up.kind}, expected {kind}")
    return up
