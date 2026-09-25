"""Alembic environment: uses the app's DATABASE_URL and model metadata."""
import sys
from logging.config import fileConfig
from pathlib import Path

from alembic import context
from sqlalchemy import engine_from_config, pool

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from api import models  # noqa: E402,F401  (registers tables)
from api.config import get_settings  # noqa: E402
from api.db import Base  # noqa: E402

config = context.config
config.set_main_option("sqlalchemy.url", get_settings().database_url)
if config.config_file_name is not None:
    fileConfig(config.config_file_name)
target_metadata = Base.metadata


def render_item(type_, obj, autogen_context):
    """Render app-specific column types as plain SQLAlchemy types in migration files."""
    import sqlalchemy as sa

    from api.crypto import EncryptedString

    if type_ == "type":
        if isinstance(obj, EncryptedString):
            return f"sa.String(length={obj.impl.length})"  # ciphertext stored as text
        if isinstance(obj, sa.JSON) and getattr(obj, "_variant_mapping", None):
            autogen_context.imports.add("from sqlalchemy.dialects import postgresql")
            return "sa.JSON().with_variant(postgresql.JSONB(), 'postgresql')"
    return False


def run_migrations_offline() -> None:
    context.configure(url=config.get_main_option("sqlalchemy.url"), target_metadata=target_metadata, render_item=render_item,
                      literal_binds=True, dialect_opts={"paramstyle": "named"}, render_as_batch=True)
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(config.get_section(config.config_ini_section, {}), prefix="sqlalchemy.",
                                     poolclass=pool.NullPool)
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata, render_as_batch=True,
                          render_item=render_item)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
