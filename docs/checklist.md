# Build checklist — every section of the brief → code

Legend: ✅ implemented and tested · 🟡 implemented, verified manually or partially · 🔌 real adapter written but not exercised against the live service (needs keys/registration) · ⚠️ stub or known gap

## §1 Project identity
| Item | Status | Where |
|---|---|---|
| Name, tagline, hero line, pitch, promise | ✅ | `apps/mobile/lib/l10n/*.arb` (`tagline`, `heroLine`, `promise`), `README.md`, `services/api/main.py` (`ABOUT`) |
| "ShilpSetu · SIH 2026 · PS ID SIH26090" + "Team HACKER LOBBY" on About and admin footer | ✅ | `apps/shared/lib/src/widgets.dart` (`Credits`), `apps/mobile/lib/ui/about_screen.dart`, `apps/admin_web/lib/widgets.dart` (`Footer`) |
| Configurable Team ID placeholder `[Your Team ID]` | ✅ | `TEAM_ID` env / Admin → Settings / `--dart-define=TEAM_ID` |

## §2 Problem & market opportunity
| Item | Status | Where |
|---|---|---|
| Problem copy (About, README) | ✅ | `about_screen.dart`, `README.md` |
| Market numbers + framing + sources on admin Impact page | ✅ | `services/api/routers/admin.py` (`MARKET`, `/admin/impact`), `apps/admin_web/lib/pages.dart` (`ImpactPage`) |

## §3 Before → after
| Item | Status | Where |
|---|---|---|
| One photo, AI-enhanced | ✅ | `services/ai/image.py`, pipeline step `image` |
| Transparent fair price shown to every buyer | ✅ | `services/ai/pricing.py`, `PriceBreakdown` widget, `/pricing/{id}` |
| QR certificate proves artisan and story | ✅ | `services/api/certs.py`, `/v/{id}` page |

## §4 Five steps + learning loop
| Step | Status | Where |
|---|---|---|
| 1 Speak (voice, either order, zero typing) | ✅ | `ui/artisan/capture_screen.dart`, `core/recorder.dart`, `core/voice.dart` |
| 2 Snap | ✅ | `ui/artisan/camera_screen.dart` |
| 3 AI builds it | ✅ | `services/api/domain/pipeline.py`, `ui/artisan/build_screen.dart` |
| 4 You approve (single tap) | ✅ | `ui/artisan/review_screen.dart`, `POST /products/{id}/approve` |
| 5 Goes live (storefront + ONDC) | ✅ | `domain/publishing.py`, `ondc_adapter/bpp.py: sync_product` |
| Event tracking + scheduled retraining of price and ranking models | ✅ | `models.Event`, `POST /events`, `workers/jobs.py: retrain`, `workers/scheduler.py` (02:00 IST) |

## §5 Differentiators — one automated test per row
All six in `services/tests/test_differentiators.py` ✅ (offline also in `apps/mobile/test/sync_queue_test.dart`).

## §6 Architecture & technologies
| Item | Status | Where / note |
|---|---|---|
| Flutter Android + web storefront | ✅ web build + tests · 🟡 Android | Release APKs build (29–35 MB per ABI); not yet run on a device or emulator |
| Offline-first cache (Drift + upload queue + local files) | ✅ | `apps/mobile/lib/offline/*` |
| FastAPI (Python 3.11+) | ✅ | `services/api` (tested on 3.14; Docker image 3.12) |
| PostgreSQL 15+, SQLAlchemy 2, Alembic | ✅ models/migration · 🟡 Postgres | migration generated and applied on SQLite, `alembic check` clean; Postgres runs only in docker-compose (Docker unavailable on the build machine) |
| Bhashini / AI4Bharat ASR, IndicTrans2 / Bhashini NMT | 🔌 | `services/ai/speech.py`; mock in use |
| LLM listing generation | 🔌 | `services/ai/nlu.py: ClaudeNLU` (`claude-opus-5`); falls back to rule-based |
| CV cleanup (rembg, WB, exposure, denoise, crop, variants) | ✅ | `services/ai/image.py` |
| Price model (cost-plus + GBM market estimator, retrained) | ✅ | `services/ai/pricing.py`, `workers/jobs.py` |
| ONDC BPP (search/select/init/confirm/status/cancel, catalog sync) + mock gateway + fake buyer | ✅ mock · 🔌 network | `services/ondc_adapter/*`; registry lookup of BAP keys for inbound signature verification is left to deployment (unsigned calls are rejected outside mock mode) ⚠️ |
| S3 / MinIO | 🟡 | `api/storage.py: S3Storage` (compose); local storage tested |
| SMS / IVR provider interface + mock + Twilio/Exotel | ✅ mock · 🔌 real | `services/notify/*` |
| Repository layout as specified | ✅ | `apps/`, `services/`, `infra/`, `docs/`, `seed/` |
| `docker compose up` + `flutter run` | 🟡 | `infra/docker-compose.yml` written, **not run** (no Docker on this machine); the no-Docker path is fully verified |

## §7 Users & roles
Artisan, operator (kiosk), buyer, admin, public verifier — ✅ `api/security.py` (`require_roles`, `acting_artisan`), `/v/{id}` needs no login.

## §8 Design system
| Item | Status | Where |
|---|---|---|
| Colour tokens (exact hex) | ✅ | `apps/shared/lib/src/theme.dart` (`SS`) |
| Poppins UI, Lora stories, Noto for 11 Indic scripts, 16sp body, 18sp+ buttons, 56dp targets | ✅ | same file; fonts bundled in `apps/shared/fonts` (offline) |
| Rounded cards, soft shadows, spoken label for every icon | ✅ | `SpeakTile`, `SpeakButton`, `spokenMessage` |

## §9 Screens & features
| § | Feature | Status | Where |
|---|---|---|---|
| 9.1 | Language tiles in own script + audio; 14 languages, all 22 accepted | ✅ | `ui/start/language_screen.dart`, `core/languages.dart` |
| 9.1 | OTP over SMS + auto-read | ✅ / 🟡 | `routers/auth.py`, `ui/start/login_screen.dart` (SMS Retriever; the app-hash suffix in the SMS is a placeholder that must match the release signing key ⚠️) |
| 9.1 | Pehchan ID (voice digits), SHG, CSC, cluster, GI; verified state | ✅ | `routers/artisans.py`, admin Verification page |
| 9.1 | Voice profile (zero typing), story audio kept + transcribed + translated | ✅ | `ui/start/voice_profile_screen.dart`, `POST /artisans/me/voice-profile` |
| 9.1 | Spoken consent per data type | ✅ | `ui/start/consent_screen.dart`, `consent_flags` |
| 9.2 | Capture screen exactly like mockup 2 (mic, dashed ochre rings, waveform, "Listening in…", photo tile text) | ✅ | `ui/artisan/capture_view.dart` + widget test |
| 9.2 | Tap-to-talk and hold-to-talk, 60 s max, offline | ✅ | `MicButton`, `VoiceRecorder.maxDuration` |
| 9.2 | Camera with framing guide, spoken non-blocking quality hints | ✅ | `camera_screen.dart`, `photo_quality.dart` (brightness; blur/move-closer hints server-side) |
| 9.2 | Up to 5 photos; AI follow-up questions answered by voice | ✅ | `CaptureView`, `nlu.follow_up_questions`, `build_screen.dart` |
| 9.3 | Seven-step async pipeline, visible + spoken, fallbacks → needs review | ✅ | `domain/pipeline.py`, `test_needs_review_when_ai_cannot_understand` |
| 9.3 | Fixed category taxonomy, tags, SEO title, story-rich description crediting the artisan | ✅ | `ai/lexicon.py`, `ai/nlu.py` |
| 9.4 | Fair-price engine: inputs, market range, artisan share ₹/%, voice nudge, buyer breakdown, versioned models | ✅ | `ai/pricing.py`, `test_price_engine.py` |
| 9.5 | Per-item Ed25519-signed certificate, SHA-256, audit log, public verify page (Lora, voice), A6 + label PDF, Verified badge | ✅ | `api/certs.py`, `routers/certificates.py`, `test_certificates.py` |
| 9.6 | One-tap review, read aloud; change price by voice, retake, re-record | ✅ | `review_screen.dart` |
| 9.7 | Storefront home like mockup 1; sections by craft / state / women-led / GI / near you; filters; ranking with fairness boost | ✅ | `store_home.dart`, `search_screen.dart`, `routers/storefront.py`, `ai/ranking.py` |
| 9.8 | Product page like mockup 3 (badge, ₹1,450 vs struck ₹2,100, QR card, breakdown, 128 reviews, meet the artisan, Add to Cart) | ✅ | `product_screen.dart` + widget test + screenshot |
| 9.9 | Cart, address, delivery estimate, UPI sandbox + COD, lifecycle, SMS + IVR in artisan's language, accept by tap/IVR/SMS, payout ledger | ✅ | `routers/commerce.py`, `domain/orders.py`, `notify/*`, `test_five_step_flow_to_payout` |
| 9.9 | Logistics tracking | ⚠️ stub | `domain/logistics.py: MockLogistics` (time-based events) |
| 9.10 | Audio-first home tiles, tap-to-speak then open (configurable), earnings visual + spoken summary, sync indicator | ✅ | `home_screen.dart`, `earnings_screen.dart`, `SyncBanner` |
| 9.11 | Kiosk: operator login, switch artisans, capture on behalf with recorded consent, batch mode, print tags, bulk sync, operator stats | ✅ | `ui/kiosk/*`, `routers/operators.py`, `test_kiosk_operator_captures_for_artisan` |
| 9.12 | Airplane-mode capture, retry + backoff, resumable chunks, idempotency, conflict policy, per-item status, low-data mode | ✅ | `offline/sync_queue.dart`, `routers/capture.py`, `test_sync.py`, `sync_queue_test.dart` |
| 9.12 | Optional on-device ASR | ✅ | `speech_to_text` (Android on-device / Chrome Web Speech); server ASR otherwise |
| 9.12 | Low-bandwidth: compressed thumbnails, WebP, text-first | 🟡 | WebP thumbs + gzip + smaller chunks in low-data mode; no separate text-only storefront mode ⚠️ |
| 9.13 | Missed-call/IVR menu (orders / earnings / callback), regional SMS templates, mock visible in admin | ✅ | `notify/service.py: ivr_session`, admin SMS/IVR page |
| 9.14 | ONDC catalog mapping, Beckn calls → orders, mock gateway + fake buyer, admin sync status/retry | ✅ | `ondc_adapter/*`, admin ONDC page |
| 9.15 | Verification queue, moderation, revocation, collective analytics (+CSV), impact, settings, scheme tagging | ✅ | `routers/admin.py`, `apps/admin_web` |

## §10 Data model
All listed tables ✅ (`services/api/models.py`, migration `alembic/versions/*_initial_schema.py`), plus `uploads`,
`otp_challenges`, `model_versions`, `settings`, `scheme_links`, `helpdesk_callbacks`, `ai_cache`, `cart_items`.

## §11 API
All groups ✅ — 102 operations with JSON schemas (`docs/api.md`, `docs/openapi.json`).

## §12 Non-functional
| Item | Status | Note |
|---|---|---|
| Audio for every label, icons+colour+text, spoken errors, large targets | ✅ | |
| Android 8+ (minSdk 26), APK < 40 MB | ✅ size · 🟡 device | split-ABI release APKs: armeabi-v7a 29.0 MB, arm64 32.9 MB, x86_64 35.3 MB; not run on a device |
| ARB localisation, RTL Urdu | ✅ | 13 languages fully/mostly translated; **Santali is a partial draft** ⚠️ needing native review; Odia/Assamese translate all artisan-facing strings (a few buyer/kiosk strings fall back to English) |
| Listing < 30 s; storefront < 3 s on 3G | 🟡 | seed pipeline ≈ 1.4 s/product on a laptop CPU; not measured on 3G |
| OTP + JWT, RBAC, PII encrypted at rest, signed media URLs, consent per type, DPDP export/delete | ✅ | `test_dpdp_export_and_delete` |
| Cost: pay-per-use, workers scale to zero, ASR/translation cache | ✅ | RQ workers, `ai_cache` table |
| Structured logs, request IDs, metrics, health | ✅ | `api/main.py` |
| Tests: price engine, certificates, sync queue, NLU fixtures, 5-step integration, 3 mockup widget tests, 6 differentiators | ✅ | 63 Python (incl. 8 security) + 11 mobile + 1 admin + 3 shared Flutter |

## §13 Business model
Commission (configurable, shown to both sides) ✅ · collective analytics module + CSV export ✅ · logistics adapter ✅ (mock).

## §14 Feasibility integrations
CSC/SHG kiosk mode ✅ · Pehchan ID linking and verification ✅ (manual admin verification; no live Pehchan API ⚠️) · NHDP/CHCDS/SFURTI scheme tagging ✅.

## §15 Scope priority
All nine priorities implemented; see above for the stubs.

## §16 Seed & demo
47 artisans (most of them women) across 35+ art forms and 80 products, all through the real pipeline, exact mockup vase (₹1,450 / ₹2,100 / 5★ / 128 reviews / verified / certificate) ✅ · demo audio clip + transcript 🟡 (synthesised locally with Windows TTS in an English voice; replace `seed/audio/demo_blue_pottery_vase.wav` with a real recording) · `docs/demo_script.md` ✅.
Product photos are procedurally drawn stand-ins (`services/scripts/seed_images.py`), not real craft photos ⚠️.

## Environment notes (this build machine)
- **Docker is not installed** → docker-compose, PostgreSQL, Redis/RQ and MinIO paths are written but unverified.
- **Android**: release APKs build; Gradle auto-installed SDK Platforms 35/36 and CMake 3.22.1 (accepting their licences). No emulator/device was available to run them.
- Windows Smart App Control blocks Flutter's `font-subset.exe`, so web/APK builds use `--no-tree-shake-icons`.

## Bug-fix pass (security & UX)
Covered by `services/tests/test_security.py`:
- The courier webhook needs `X-Webhook-Token` (`WEBHOOK_TOKEN`) or an admin token. Twilio SMS/IVR hooks verify the request signature, and the IVR simulator is admin-only.
- Nobody can sign themselves up as an operator or admin. Admins create operators with `POST /admin/operators`, and operators see only their own artisans' orders.
- OTP requests are limited to 5 per 15 minutes per phone. Stock is locked while an order is placed, so the same item cannot be oversold.
- Mock ASR no longer invents a product from unknown audio; it asks what the product is. Media links follow the host the request came in on.

App: localised titles and categories in lists and orders; image placeholders while loading; ₹ coins; per-status order icons; delivered orders show Delivered; artisans can type an answer or send a recording when speech recognition is unavailable; the server address can be changed in About; launcher icon and favicon.

## Additions: assistant, theme, catalogue
- **Assistant:** Shilpi (greeting with streak, goal, badges and craft of the day; chat with product cards and shortcuts) ✅ `test_assistant.py`, `assistant_theme_test.dart`.
- **Theme:** navy + cyan with light/dark switch ✅ · opening title animation ✅ · new launcher icon ✅.
- **Catalogue:** 50 real Wikimedia Commons photos with credits (`seed/images/CREDITS.json`) ✅ · art-form stories in English and Hindi, other languages fall back to English 🟡.
- **Cart:** fixed for artisan accounts and logged-out buyers ✅.
