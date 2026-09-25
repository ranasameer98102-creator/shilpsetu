"""assistant streak days

Revision ID: 7b1c2d3e4f50
Revises: 4d790816dda4
Create Date: 2026-09-25 22:00:00

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "7b1c2d3e4f50"
down_revision: Union[str, Sequence[str], None] = "4d790816dda4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "assistant_days",
        sa.Column("user_id", sa.String(length=32), nullable=False),
        sa.Column("day", sa.String(length=10), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("user_id", "day"),
    )


def downgrade() -> None:
    op.drop_table("assistant_days")
