"""Resumable chunked uploads for audio/photos captured offline. Idempotency keys make retries safe."""
import hashlib

from fastapi import APIRouter, Depends, File, HTTPException, Query, Request, UploadFile
from sqlalchemy import select
from sqlalchemy.orm import Session

from ai.image import quick_quality

from ..config import get_settings
from ..db import get_db
from ..models import Upload, User
from ..schemas import UploadCreate, UploadStatus
from ..security import current_user
from ..storage import LocalStorage, get_storage

router = APIRouter(prefix="/capture", tags=["capture"])

EXT = {"audio/wav": "wav", "audio/x-wav": "wav", "audio/mp4": "m4a", "audio/aac": "aac", "audio/ogg": "ogg",
       "audio/webm": "webm", "audio/mpeg": "mp3", "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp",
       "image/heic": "heic"}


def _status(up: Upload) -> UploadStatus:
    return UploadStatus(upload_id=up.id, received=up.received, total_size=up.total_size, status=up.status,
                        storage_key=up.storage_key if up.status == "complete" else None)


def _part_key(up: Upload) -> str:
    return f"uploads/{up.id}.part"


@router.post("/uploads", response_model=UploadStatus)
def create_upload(body: UploadCreate, user: User = Depends(current_user), db: Session = Depends(get_db)):
    existing = db.execute(select(Upload).where(Upload.idempotency_key == body.idempotency_key)).scalar_one_or_none()
    if existing:
        if existing.owner_user_id != user.id:
            raise HTTPException(409, "idempotency key already used")
        return _status(existing)  # resume: client continues from `received`
    up = Upload(owner_user_id=user.id, idempotency_key=body.idempotency_key, kind=body.kind,
                content_type=body.content_type, total_size=body.total_size, sha256=body.sha256)
    db.add(up)
    db.commit()
    return _status(up)


@router.get("/uploads/{upload_id}", response_model=UploadStatus)
def upload_status(upload_id: str, user: User = Depends(current_user), db: Session = Depends(get_db)):
    up = db.get(Upload, upload_id)
    if not up or up.owner_user_id != user.id:
        raise HTTPException(404, "upload not found")
    return _status(up)


@router.put("/uploads/{upload_id}", response_model=UploadStatus)
async def put_chunk(upload_id: str, request: Request, offset: int = Query(ge=0), user: User = Depends(current_user),
                    db: Session = Depends(get_db)):
    """Append a chunk at `offset`. A chunk the server already has is ignored (safe to retry after a drop)."""
    up = db.get(Upload, upload_id)
    if not up or up.owner_user_id != user.id:
        raise HTTPException(404, "upload not found")
    if up.status == "complete":
        return _status(up)
    data = await request.body()
    if offset > up.received:
        raise HTTPException(409, f"gap: server has {up.received} bytes")
    data = data[up.received - offset:] if offset < up.received else data
    if up.received + len(data) > up.total_size:
        raise HTTPException(413, "more data than declared total_size")
    storage = get_storage()
    if isinstance(storage, LocalStorage):
        storage.append(_part_key(up), data)
    else:  # S3: keep parts on local scratch until complete, then put once
        scratch = LocalStorage(get_settings().data_dir / "scratch")
        scratch.append(_part_key(up), data)
    up.received += len(data)
    db.commit()
    return _status(up)


@router.post("/uploads/{upload_id}/complete", response_model=UploadStatus)
def complete_upload(upload_id: str, user: User = Depends(current_user), db: Session = Depends(get_db)):
    up = db.get(Upload, upload_id)
    if not up or up.owner_user_id != user.id:
        raise HTTPException(404, "upload not found")
    if up.status == "complete":
        return _status(up)
    if up.received != up.total_size:
        raise HTTPException(409, f"incomplete: {up.received}/{up.total_size}")
    storage = get_storage()
    src = storage if isinstance(storage, LocalStorage) else LocalStorage(get_settings().data_dir / "scratch")
    data = src.get(_part_key(up))
    digest = hashlib.sha256(data).hexdigest()
    if up.sha256 and up.sha256 != digest:
        src.delete(_part_key(up))
        up.received = 0
        db.commit()
        raise HTTPException(422, "checksum mismatch; re-upload")
    key = f"captures/{user.id}/{up.id}.{EXT.get(up.content_type, 'bin')}"
    storage.put(key, data, up.content_type)
    src.delete(_part_key(up))
    up.sha256, up.storage_key, up.status = digest, key, "complete"
    db.commit()
    return _status(up)


@router.post("/uploads/simple", response_model=UploadStatus)
async def simple_upload(idempotency_key: str, kind: str, file: UploadFile = File(...),
                        user: User = Depends(current_user), db: Session = Depends(get_db)):
    """Single-request upload for good connections (web kiosk / tests)."""
    data = await file.read()
    up = db.execute(select(Upload).where(Upload.idempotency_key == idempotency_key)).scalar_one_or_none()
    if up and up.status == "complete":
        return _status(up)
    ctype = file.content_type or ("audio/wav" if kind == "audio" else "image/jpeg")
    if not up:
        up = Upload(owner_user_id=user.id, idempotency_key=idempotency_key, kind=kind, content_type=ctype,
                    total_size=len(data))
        db.add(up)
        db.flush()
    key = f"captures/{user.id}/{up.id}.{EXT.get(ctype, 'bin')}"
    get_storage().put(key, data, ctype)
    up.received, up.sha256, up.storage_key, up.status = len(data), hashlib.sha256(data).hexdigest(), key, "complete"
    db.commit()
    return _status(up)


@router.post("/photo-quality")
async def photo_quality(file: UploadFile = File(...), user: User = Depends(current_user)):
    """Quick hints for the camera ('too dark', 'move closer'). Advisory only — never blocks capture."""
    return quick_quality(await file.read())
