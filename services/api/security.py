"""OTP + JWT auth, role-based access, and 'act as artisan' for kiosk operators."""
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import Depends, Header, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from .config import get_settings
from .db import get_db
from .models import Artisan, Operator, User

bearer = HTTPBearer(auto_error=False)


def create_token(user: User) -> str:
    s = get_settings()
    payload = {
        "sub": user.id,
        "role": user.role,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=s.jwt_ttl_minutes),
    }
    return jwt.encode(payload, s.jwt_secret, algorithm="HS256")


def _decode(token: str) -> dict:
    try:
        return jwt.decode(token, get_settings().jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "invalid or expired token")


def optional_user(
    creds: HTTPAuthorizationCredentials | None = Depends(bearer), db: Session = Depends(get_db)
) -> User | None:
    if not creds:
        return None
    user = db.get(User, _decode(creds.credentials)["sub"])
    if not user or user.deleted_at:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "unknown user")
    return user


def current_user(user: User | None = Depends(optional_user)) -> User:
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "login required")
    return user


def require_roles(*roles: str):
    def dep(user: User = Depends(current_user)) -> User:
        if user.role not in roles:
            raise HTTPException(status.HTTP_403_FORBIDDEN, f"requires role: {', '.join(roles)}")
        return user

    return dep


def acting_artisan(
    user: User = Depends(require_roles("artisan", "operator")),
    x_artisan_id: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> Artisan:
    """Artisans act as themselves; kiosk operators act on behalf of an artisan they onboarded."""
    if user.role == "artisan":
        artisan = db.query(Artisan).filter_by(user_id=user.id).one_or_none()
        if not artisan:
            raise HTTPException(status.HTTP_409_CONFLICT, "complete your artisan profile first")
        return artisan
    if not x_artisan_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "operators must send X-Artisan-Id")
    operator = db.query(Operator).filter_by(user_id=user.id).one()
    artisan = db.get(Artisan, x_artisan_id)
    if not artisan or artisan.onboarded_by_operator_id != operator.id:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "artisan is not managed by this operator")
    return artisan


def operator_for(user: User, db: Session) -> Operator | None:
    return db.query(Operator).filter_by(user_id=user.id).one_or_none() if user.role == "operator" else None
