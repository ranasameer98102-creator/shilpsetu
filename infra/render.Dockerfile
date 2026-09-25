# Public demo API for Render (or any container host with a free tier and an ephemeral disk).
# The demo data is seeded while the image builds, so the server starts instantly and every restart
# (free instances sleep after ~15 idle minutes) comes back to a clean, fully seeded demo.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 \
    U2NET_HOME=/app/models/rembg REMBG_MODEL=u2netp ENV=demo SHOW_ADMIN_OTP=false
RUN apt-get update && apt-get install -y --no-install-recommends libgomp1 libglib2.0-0 curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/services
COPY services/requirements.txt .
RUN pip install -r requirements.txt

COPY apps/shared/fonts /app/apps/shared/fonts
COPY seed /app/seed
COPY services /app/services

# Seed into the image: SQLite database, media, certificate/PII keys and the trained price model.
RUN rm -rf .data && python -m scripts.seed

EXPOSE 10000
CMD ["sh", "-c", "uvicorn api.main:app --host 0.0.0.0 --port ${PORT:-10000} --proxy-headers --forwarded-allow-ips='*'"]
