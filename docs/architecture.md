# ShilpSetu — architecture

ShilpSetu turns **one photo and one spoken sentence** into a fair-priced, trust-verified, marketplace-ready
listing. This document explains how the pieces fit together and where each responsibility lives in the code.

## Five layers

```
ACCESS              CAPTURE                 AI PROCESSING                 TRUST & PRICING              DISTRIBUTION
Android app  ──►   one photo +        ──►   image enhancement      ──►    fair-value price +     ──►   app storefront +
or assisted        one spoken sentence      ASR / NLU / listing           provenance certificate       ONDC network
kiosk entry        (saved on the phone      translation, price model      (Ed25519-signed, QR)
                    first, synced later)
```

| Layer | Where | What happens |
|---|---|---|
| Access | `apps/mobile` (artisan, buyer, kiosk modes), `apps/admin_web` | Voice-first Flutter app; kiosk mode lets a CSC/SHG operator act for an artisan (`X-Artisan-Id`). |
| Capture | `apps/mobile/lib/offline/*`, `services/api/routers/capture.py` | Audio + photos go to the on-device Drift DB/file store; the `SyncQueue` uploads in resumable chunks with idempotency keys and exponential backoff. |
| AI processing | `services/api/domain/pipeline.py`, `services/ai/*` | ASR → NLU extraction → listing → translation → image enhancement → price → certificate draft, each step visible and spoken; any failure marks fields *needs review* but never loses the capture. |
| Trust & pricing | `services/ai/pricing.py`, `services/api/domain/pricing_service.py`, `services/api/certs.py`, `services/api/domain/publishing.py` | Transparent cost-plus price + quantile market model; one Ed25519-signed certificate per item, SHA-256 record hash, hash-chained audit log. |
| Distribution | `services/api/routers/storefront.py`, `services/ondc_adapter/*` | Storefront ranking (learned model + fairness boost), ONDC Beckn BPP with catalog sync and a mock gateway/buyer. |

## Runtime components

```
                    ┌──────────────────────────── docker-compose ─────────────────────────────┐
 Flutter app ──────►│ api (FastAPI)  ── RQ ──► ai (workers: ASR/NLU/CV/pricing)                │
 (Android / web)    │   │   │                    workers (scheduler: nightly retrain, ONDC sync)│
 Admin web ────────►│   │   └── ondc_adapter (Beckn BPP at the public subscriber URI)          │
 Buyer apps on ONDC►│   │                                                                     │
 IVR / SMS gateway ►│   ├── postgres (SQLAlchemy 2 + Alembic)   redis (queue)   minio (S3 media)│
                    └─────────────────────────────────────────────────────────────────────────┘
```

Without Docker the same code runs as one process: SQLite, local file storage, jobs in a background thread
(`JOB_MODE=inline`) — this is how the test-suite and the no-Docker dev setup run.

## Provider interfaces (mock by default)

Every external dependency is an interface with a mock implementation chosen by an env var (and switchable at
runtime from **Admin → Settings**). The whole system runs locally with no keys.

| Concern | Interface | Mock | Real adapters |
|---|---|---|---|
| Speech-to-text | `ai/speech.py: get_asr` | known-clip lookup + on-device transcript | Bhashini ULCA pipeline, AI4Bharat IndicConformer/IndicWhisper endpoint |
| Listing NLU | `ai/nlu.py: get_nlu` | rule-based multilingual extractor + template writer | Claude (`claude-opus-5`, JSON-schema structured output, refusal fallbacks) |
| Translation | `ai/speech.py: get_translator` | native templates for en/hi/bn/mr | Bhashini NMT, IndicTrans2 endpoint |
| Background removal | `ai/image.py: foreground_mask` | OpenCV GrabCut | rembg U²-Net (default when installed) |
| Object storage | `api/storage.py` | local disk + HMAC-signed URLs | S3 / MinIO presigned URLs |
| SMS / IVR | `notify/providers.py` | console + `notifications` table | Twilio, Exotel |
| Payments | `api/domain/payments.py` | signed UPI sandbox | Razorpay (orders, signature, webhook) |
| Logistics | `api/domain/logistics.py` | rate + tracking stub | partner adapter slot |
| ONDC | `ondc_adapter/bpp.py` | in-process mock gateway + fake buyer app | Beckn HTTP with Ed25519/BLAKE2b signatures |

## The 5-step flow in detail

1. **Speak** — `CaptureScreen` records audio with `record` (kept as-is) and, where the phone has one, runs the
   on-device recogniser for a live transcript. Both are saved locally.
2. **Snap** — in-app camera with a framing guide; a brightness check speaks a hint ("move towards the light")
   but never blocks. Steps 1 and 2 work in either order, in airplane mode.
3. **AI builds it** — `SyncQueue` uploads when online (`/capture/uploads`, chunked, resumable) then creates a
   draft (`/products/drafts`, idempotent). `pipeline.run` executes the seven steps; the app polls
   `/products/{id}/build`, speaks each step, and asks follow-up questions ("How many days did it take?") that
   the artisan answers by voice (`/products/{id}/answers` re-runs extraction and price).
4. **You approve** — one review card, read aloud; one big Approve. Secondary: change price by voice
   ("make it 1,600" / "सोलह सौ"), retake photo, re-record.
5. **Goes live** — `publishing.publish` sets the listing live, signs the certificate, sends "listing live" +
   "certificate issued" SMS in the artisan's language, and queues ONDC catalog sync.

**Learning loop:** buyer events (`view`, `add_to_cart`, `order`, `return`) and sale prices feed
`workers/jobs.py: retrain` — a new market-model version (sales weighted 5×, returns excluded) and a new ranking
model; every price quote records the model version that produced it.

## Fair price (how the price is built)

```
labour         = hours × fair wage (state skilled-wage floor, admin-configurable)
overheads      = (materials + labour) × 12 %
craft premium  = base × (complexity − 1 + GI premium 8 %)
fair floor     = (materials + labour + overheads + craft premium + logistics) / (1 − commission)
recommended    = fair floor, lifted halfway towards the market p50 when the market pays more
                 (the uplift is shown as a "market premium" line that goes to the artisan)
artisan share  = price − platform fee − logistics
```

The market model is three `HistGradientBoostingRegressor` quantile models (p20/p50/p80) over category, log
material cost, hours, GI, complexity and weight, bootstrapped on seed comparables and retrained on real sales.
Missing inputs are estimated and flagged; a price the artisan sets below the fair floor is allowed but warned
("below fair wage") and shown honestly in the breakdown.

## Certificates

Payload (artisan, craft, cluster/GI, Pehchan status, materials, story, fair-price basis, original-photo hash,
listing id, timestamps) → canonical JSON (sorted keys) → Ed25519 signature + SHA-256 record hash. The QR
encodes `/v/{certificate_id}?s={signature}`; the public page re-verifies the signature, the stored hash, that
the QR signature belongs to this certificate, and revocation. The public key is published at
`/api/v1/certificates/public-key` so anyone can verify offline. Issue/revoke events go into the append-only,
hash-chained `audit_log` (ORM event guards refuse updates and deletes; `GET /admin/audit` re-verifies the chain).

## Offline-first rules

- Every capture is written to the phone before anything else; nothing needs a network until upload.
- Uploads are chunked (64 KB, 16 KB in low-data mode) and resumable from the server's `received` offset;
  overlapping retried chunks are de-duplicated; a checksum mismatch forces a clean re-upload.
- Idempotency keys make retried drafts return the same product.
- Conflict policy: **server wins** for model outputs (status, title, price quote); **device wins** for the
  artisan's own edits (`device_edited_fields` survive AI re-runs).
- Per-item status: Queued → Uploading → Processing → Needs review / Ready → Live (and Failed for 4xx errors).

## Security & privacy

OTP login (SMS Retriever auto-read on Android) → JWT; role-based access (artisan / operator / buyer / admin);
phone numbers, Pehchan IDs and notification recipients encrypted at rest (Fernet) with keyed hashes for lookup;
media served only through expiring signed URLs; consent recorded per data type with timestamps (spoken consent
audio kept for kiosk onboarding); DPDP export (`GET /artisans/me/export`) and erasure (`DELETE /artisans/me`,
anonymises financial records kept for legal retention). Structured JSON logs with request IDs, `/health`,
`/ready`, `/metrics`.
