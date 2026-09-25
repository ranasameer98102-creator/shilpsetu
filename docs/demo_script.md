# 5-minute judge demo

**Story:** Meena Devi, a blue-pottery artisan in Sanganer, has no signal in her workshop. She lists a vase by
speaking one sentence and taking one photo. It goes live with a fair price and a signed certificate, a buyer
on another ONDC app finds it, and Meena hears about the order on a basic phone call.

## Before you start (2 minutes, off-stage)

```bash
# 1. Backend with demo data (mock AI/SMS/ONDC, no keys)
cd infra && docker compose up -d                 # or, without Docker:
#   cd services && python -m scripts.seed --reset && uvicorn api.main:app --port 8000
# 2. Artisan app on an Android phone/emulator (or Chrome)
cd apps/mobile && flutter run --dart-define=API_BASE=http://<laptop-ip>:8000
# 3. Admin dashboard in a browser tab
cd apps/admin_web && flutter run -d chrome
```

Open these tabs: **Admin** (sign in `+919000000000`), **mock ONDC buyer app** `http://localhost:8000/ondc-mock/buyer`.
Demo logins — OTP codes appear on screen in mock SMS mode:

| Who | Phone | Language |
|---|---|---|
| Meena Devi (artisan) | +919000000002 | Hindi |
| Asha Rao (buyer) | +919000000001 | English |
| CSC Sanganer (kiosk) | +919000000009 | Hindi |
| Admin (MoSJE) | +919000000000 | English |

## The demo

| Time | Do | Say / point at |
|---|---|---|
| 0:00 | Phone: sign in as Meena → Hindi home screen. Tap **उत्पाद जोड़ें** once — it speaks — tap again. | "Every tile talks. No reading needed." |
| 0:20 | **Turn on airplane mode.** | "Her workshop has no network." |
| 0:30 | Tap the maroon mic, say **"Blue pottery vase, hand-painted"** (or play `seed/audio/demo_blue_pottery_vase.wav`). Rings pulse, waveform moves, *Listening in Hindi…*. | Matches mockup screen 2. |
| 0:50 | Tap the photo tile, shoot the vase on any background. *"Photo captured — enhancing background & light automatically"*. Tap **मेरी लिस्टिंग बनाओ**. | Banner: *Saved on phone — will upload when network returns.* |
| 1:10 | **Turn airplane mode off.** Banner flips to uploading, then the AI steps light up one by one, spoken in Hindi. | "Resumable uploads, idempotent — a retry can never create a duplicate listing." |
| 1:40 | The app asks aloud **"इसे बनाने में कितने दिन लगे?"** — answer "छह घंटे" (six hours); then materials — "एक सौ बीस" (₹120). | "Missing facts are asked by voice and feed the fair price." |
| 2:00 | Review card reads out the title and **"You get ₹…"**. Say **"make it 1,450"** via *Change price*. Tap the big green **Approve**. | "One tap. The breakdown shows exactly what moves when she changes the price." |
| 2:20 | *Your product is live · also on ONDC · certificate ready* with a QR. | |
| 2:30 | Browser, storefront (`/#/store`) → the vase: **₹1,450** vs struck **₹2,100**, ★★★★★ (128), **✓ Verified Artisan**, *How this price is built*, *₹… goes directly to the artisan*. | Mockup screens 1 & 3. |
| 2:50 | Scan the QR with any phone camera → public verify page: **✓ Verified**, Meena's story in Lora, fair-price basis, SHA-256, Ed25519 key. | "Tamper-evident. Change one rupee in the record and verification fails." |
| 3:15 | Mock ONDC buyer tab: search **vase** → it appears from the network with *% to artisan* and the certificate link → **Buy via ONDC**. Log shows `select → init → confirm`. | "Published straight to ONDC — any buyer app can sell it." |
| 3:40 | Admin → **SMS / IVR**: Meena got the new-order SMS and an IVR call *in Hindi*: "Press 1 to accept". Use the IVR simulator: keys **1 2** → *"इस महीने आपने … कमाए"*. | "Works on a feature phone." |
| 4:05 | Phone: **Orders** → Accept → Packed → Shipped. (Or the courier webhook marks it delivered.) | |
| 4:20 | Phone: **Earnings** → coins + *"This month you earned ₹…"* read aloud; ledger: sale − platform fee − shipping = net, matching the share promised at listing. | "Every rupee explained." |
| 4:40 | Admin → **Overview**: artisans, % women, GMV, **average artisan share of price**, offline-sync health; **Impact** page with the market numbers. | "Collective analytics are also a revenue stream." |
| 5:00 | Close on the About screen: *ShilpSetu · SIH 2026 · PS ID SIH26090 · Team HACKER LOBBY*. | "From handmade to headline-worthy — every craft, always in market." |

## If something goes wrong

- **No microphone / recogniser on the device:** the recording is still saved and transcribed by the server's
  ASR provider after sync; or type-free fallback — play the seed clip into the mic.
- **Network on stage is flaky:** that is the point — the queue retries with backoff; tap the sync banner to
  retry now.
- **Reset the demo:** `python -m scripts.seed --reset` (SQLite) or `docker compose down -v && docker compose up`.
