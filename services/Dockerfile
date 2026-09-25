# One image for api, ai workers, scheduler and the ONDC adapter (different commands in docker-compose).
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1 U2NET_HOME=/data/models/rembg
RUN apt-get update && apt-get install -y --no-install-recommends libgomp1 libglib2.0-0 curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/services
COPY services/requirements.txt .
RUN pip install -r requirements.txt

COPY apps/shared/fonts /app/apps/shared/fonts
COPY seed /app/seed
COPY services /app/services

EXPOSE 8000
HEALTHCHECK --interval=15s --timeout=3s --retries=5 CMD curl -fs http://localhost:8000/health || exit 1
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
