# ShilpSetu API reference

Generated from the OpenAPI schema (`docs/openapi.json`, 102 operations). Interactive docs: `http://localhost:8000/docs`. Base path `/api/v1` unless shown otherwise. Auth: `Authorization: Bearer <JWT>` from `/api/v1/auth/otp/verify`; kiosk operators add `X-Artisan-Id`.

## admin

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/admin/analytics` | Analytics |  |
| GET | `/api/v1/admin/analytics/export.csv` | Analytics Export — Anonymised, aggregated collective analytics (a revenue stream for govt / bulk buyers): state x craft. |  |
| GET | `/api/v1/admin/artisans` | All Artisans |  |
| POST | `/api/v1/admin/artisans/{artisan_id}/verify` | Verify Artisan | `VerifyArtisanIn` |
| GET | `/api/v1/admin/audit` | Audit Log |  |
| POST | `/api/v1/admin/certificates/{cert_id}/revoke` | Revoke | `RevokeIn` |
| GET | `/api/v1/admin/helpdesk` | Helpdesk |  |
| GET | `/api/v1/admin/impact` | Impact — Market opportunity (public numbers) + platform impact. Public: shown on the admin Impact page and README. |  |
| GET | `/api/v1/admin/listings` | Listings |  |
| POST | `/api/v1/admin/listings/{product_id}/moderate` | Moderate | `ModerateIn` |
| GET | `/api/v1/admin/models` | Models |  |
| POST | `/api/v1/admin/models/retrain` | Retrain Now |  |
| GET | `/api/v1/admin/notifications` | Notifications |  |
| GET | `/api/v1/admin/ondc` | Ondc Status |  |
| POST | `/api/v1/admin/ondc/sync-all` | Ondc Sync All |  |
| POST | `/api/v1/admin/ondc/{product_id}/retry` | Ondc Retry |  |
| GET | `/api/v1/admin/operators` | Operators |  |
| GET | `/api/v1/admin/schemes` | Schemes |  |
| POST | `/api/v1/admin/schemes` | Add Scheme | `SchemeLinkIn` |
| GET | `/api/v1/admin/settings` | Get Settings  |  |
| PUT | `/api/v1/admin/settings` | Put Settings | `SettingsIn` |
| GET | `/api/v1/admin/verification-queue` | Verification Queue |  |

## artisans

| Method | Path | Summary | Request body |
|---|---|---|---|
| DELETE | `/api/v1/artisans/me` | Delete My Data — DPDP Act 2023: erasure. Media and PII are deleted; financial records are kept anonymised (legal retention). |  |
| GET | `/api/v1/artisans/me` | My Profile |  |
| PUT | `/api/v1/artisans/me` | Upsert Profile | `ArtisanProfileIn` |
| GET | `/api/v1/artisans/me/dashboard` | Dashboard |  |
| GET | `/api/v1/artisans/me/export` | Export My Data — DPDP Act 2023: data principal's right to access — everything we hold about the artisan. |  |
| GET | `/api/v1/artisans/me/ledger` | Ledger — Payout ledger: gross, platform fee, logistics, net — every rupee explained. |  |
| POST | `/api/v1/artisans/me/voice-profile` | Voice Profile — Zero typing: each profile field answered by voice. Story audio is kept as-is and also transcribed. | `ArtisanVoiceProfileIn` |
| GET | `/api/v1/artisans/{artisan_id}` | Public Profile |  |

## auth

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/auth/me` | Me |  |
| PATCH | `/api/v1/auth/me` | Update Me | `application/json` |
| POST | `/api/v1/auth/otp/request` | Request Otp | `OtpRequest` |
| POST | `/api/v1/auth/otp/verify` | Verify Otp | `OtpVerify` |

## capture

| Method | Path | Summary | Request body |
|---|---|---|---|
| POST | `/api/v1/capture/photo-quality` | Photo Quality — Quick hints for the camera ('too dark', 'move closer'). Advisory only — never blocks capture. | `Body_photo_quality_api_v1_capture_photo_quality_post` |
| POST | `/api/v1/capture/uploads` | Create Upload | `UploadCreate` |
| POST | `/api/v1/capture/uploads/simple` | Simple Upload — Single-request upload for good connections (web kiosk / tests). | `Body_simple_upload_api_v1_capture_uploads_simple_post` |
| GET | `/api/v1/capture/uploads/{upload_id}` | Upload Status |  |
| PUT | `/api/v1/capture/uploads/{upload_id}` | Put Chunk — Append a chunk at `offset`. A chunk the server already has is ignored (safe to retry after a drop). |  |
| POST | `/api/v1/capture/uploads/{upload_id}/complete` | Complete Upload |  |

## certificates

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/certificates/public-key` | Public Key — Anyone can verify certificates offline with this Ed25519 key. |  |
| GET | `/api/v1/certificates/{cert_id}/pdf` | Pdf |  |
| GET | `/api/v1/certificates/{cert_id}/qr.png` | Qr |  |
| GET | `/api/v1/certificates/{cert_id}/verify` | Verify |  |

## commerce

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/artisan/orders` | Artisan Orders |  |
| GET | `/api/v1/cart` | Get Cart |  |
| POST | `/api/v1/cart` | Add To Cart | `CartLine` |
| DELETE | `/api/v1/cart/{product_id}` | Remove From Cart |  |
| POST | `/api/v1/checkout` | Checkout | `CheckoutIn` |
| GET | `/api/v1/delivery-estimate` | Delivery Estimate |  |
| POST | `/api/v1/events` | Track Events — Buyer views / add-to-cart / orders / returns — these retrain the price and ranking models. | `EventsIn` |
| GET | `/api/v1/orders` | My Orders |  |
| GET | `/api/v1/orders/{order_id}` | Get Order |  |
| POST | `/api/v1/orders/{order_id}/courier-delivered` | Courier Webhook — Logistics-partner webhook stub: marks a shipped order delivered (settles the artisan payout). |  |
| POST | `/api/v1/orders/{order_id}/status` | Update Status — Artisans accept / decline (one tap or IVR key), pack and ship; buyers cancel; courier/admin mark delivered. | `OrderStatusIn` |
| POST | `/api/v1/payments/confirm` | Confirm Payment | `PaymentConfirm` |
| POST | `/api/v1/payments/mock/{provider_order_id}/pay` | Mock Pay — Dev-only UPI sandbox: simulates the buyer completing payment and returns what the SDK would return. |  |
| POST | `/api/v1/payments/webhook` | Payment Webhook |  |
| POST | `/api/v1/reviews` | Add Review | `ReviewIn` |
| GET | `/api/v1/reviews/{product_id}` | List Reviews |  |

## meta

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/about` | About |  |
| GET | `/api/v1/config/public` | Public Config — What the apps need at start-up: languages, categories, tile behaviour, fair-price policy. |  |
| GET | `/health` | Health |  |
| GET | `/metrics` | Metrics |  |
| GET | `/ready` | Ready |  |

## notify

| Method | Path | Summary | Request body |
|---|---|---|---|
| POST | `/api/v1/notify/callback` | Request Callback — In-app 'ask a helper to call me' — same helpdesk queue as IVR menu option 3. |  |
| POST | `/api/v1/notify/ivr/incoming` | Ivr Incoming — Telephony webhook (Twilio/Exotel form-encoded). `digits_so_far` travels in the callback URL. |  |
| POST | `/api/v1/notify/ivr/order-response` | Ivr Order Response |  |
| POST | `/api/v1/notify/ivr/simulate` | Ivr Simulate — Admin / demo: walk the IVR menu without a phone line (e.g. digits='12' = Hindi, hear earnings). | `IvrSimulate` |
| POST | `/api/v1/notify/sms/incoming` | Sms Incoming — Artisan replies '1' / '2' to the new-order SMS to accept / decline their most recent pending order. | `Body_sms_incoming_api_v1_notify_sms_incoming_post` |

## ondc

| Method | Path | Summary | Request body |
|---|---|---|---|
| POST | `/ondc/{action}` | Beckn Endpoint |  |

## ondc-mock

| Method | Path | Summary | Request body |
|---|---|---|---|
| POST | `/ondc-mock/bap/{action}` | Bap Callback |  |
| GET | `/ondc-mock/buyer` | Buyer App |  |
| POST | `/ondc-mock/buyer/api/order` | Buyer Order | `BuyerOrder` |
| POST | `/ondc-mock/buyer/api/search` | Buyer Search | `BuyerSearch` |
| GET | `/ondc-mock/buyer/api/status/{order_id}` | Buyer Status |  |
| POST | `/ondc-mock/gateway/search` | Gateway Search — Gateway fan-out: forwards a BAP search to registered BPPs (here, ShilpSetu). |  |
| GET | `/ondc-mock/log` | Network Log |  |

## operators

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/operators/artisans` | My Artisans |  |
| POST | `/api/v1/operators/artisans` | Onboard Artisan — Onboard an artisan who may not own a smartphone. The artisan's spoken consent is recorded on the kiosk. | `OperatorArtisanCreate` |
| GET | `/api/v1/operators/me` | Me |  |
| PATCH | `/api/v1/operators/me` | Update Me | `application/json` |
| GET | `/api/v1/operators/stats` | Stats |  |
| GET | `/api/v1/operators/tags.pdf` | Print Tags — Batch-print certificate tags for an exhibition session (one page per item). |  |

## products

| Method | Path | Summary | Request body |
|---|---|---|---|
| POST | `/api/v1/products/drafts` | Create Draft — Create a listing from one spoken description + photo(s). Idempotent per device capture. | `DraftCreate` |
| GET | `/api/v1/products/mine` | My Products |  |
| GET | `/api/v1/products/{product_id}` | Get Product |  |
| PATCH | `/api/v1/products/{product_id}` | Edit Product — Artisan edits (from the device). Device wins for these fields on later AI re-runs. | `ProductEdit` |
| POST | `/api/v1/products/{product_id}/answers` | Add Answers — Voice answers to the AI's follow-up questions ('What is it made of?' ...). Re-runs extraction + price. | `AnswerIn` |
| POST | `/api/v1/products/{product_id}/approve` | Approve — Step 4, one tap: publish to the storefront, issue the signed certificate, queue ONDC catalog sync. |  |
| GET | `/api/v1/products/{product_id}/build` | Build Status |  |
| POST | `/api/v1/products/{product_id}/price` | Change Price — 'Change price' by voice ('make it 1,600') or number. The breakdown shows exactly what moves. | `PriceAdjust` |
| POST | `/api/v1/products/{product_id}/rerecord` | Rerecord |  |
| POST | `/api/v1/products/{product_id}/retake` | Retake Photo | `application/json` |
| POST | `/api/v1/products/{product_id}/unpublish` | Unpublish |  |

## storefront

| Method | Path | Summary | Request body |
|---|---|---|---|
| GET | `/api/v1/storefront/feed` | Feed |  |
| GET | `/api/v1/storefront/filters` | Filters |  |
| GET | `/api/v1/storefront/products/{product_id}` | Product Detail |  |
| GET | `/api/v1/storefront/search` | Search |  |

## sync

| Method | Path | Summary | Request body |
|---|---|---|---|
| POST | `/api/v1/pricing/preview` | Price Preview — Transparent what-if: how a fair price is built from these inputs (used by kiosk operators and the admin). | `PricePreviewIn` |
| GET | `/api/v1/pricing/{product_id}` | Product Price — Public 'How this price is built' for a live listing. |  |
| GET | `/api/v1/sync/status` | Sync Status — For each queued capture on the device: Queued / Processing / Needs review / Ready / Live, plus the product id. |  |

## Schemas

### Address

- `name` *: string
- `phone` *: string
- `line1` *: string
- `city` *: string
- `state` *: string
- `pincode` *: string

### AnswerIn

- `field` *: string
- `upload_id`: string | null
- `text`: string | null

### ArtisanProfileIn

- `name` *: string
- `name_native`: string | null
- `village`: string | null
- `district`: string | null
- `state`: string | null
- `craft_type`: string | null
- `years_practice`: integer | null
- `story_text`: string | null
- `story_audio_key`: string | null
- `photo_key`: string | null
- `pehchan_id`: string | null
- `shg_name`: string | null
- `csc_id`: string | null
- `cluster`: string | null
- `gi_tag`: string | null
- `gender`: string | null
- `consent`: ConsentIn

### ArtisanVoiceProfileIn

- `language`: string
- `answers`: object — field -> upload id (audio) or on-device transcript text
- `consent`: ConsentIn

### Body_photo_quality_api_v1_capture_photo_quality_post

- `file` *: string

### Body_simple_upload_api_v1_capture_uploads_simple_post

- `file` *: string

### Body_sms_incoming_api_v1_notify_sms_incoming_post

- `From` *: string
- `Body` *: string

### BuyerOrder

- `product_id` *: string
- `qty`: integer
- `name`: string
- `phone`: string
- `building`: string
- `city`: string
- `state`: string
- `pincode`: string
- `paid`: boolean

### BuyerSearch

- `q`: string

### CartLine

- `product_id` *: string
- `quantity`: integer

### CheckoutIn

- `address` *: Address
- `payment_method`: string

### ConsentIn

- `voice`: boolean
- `photo`: boolean
- `location`: boolean
- `consent_audio_key`: string | null — storage key of the recorded spoken consent

### DraftCreate

- `idempotency_key` *: string
- `device_id` *: string
- `language`: string
- `audio_upload_id`: string | null
- `photo_upload_ids`: array
- `device_transcript`: string | null — on-device ASR result, if the phone produced one
- `answers`: array
- `captured_offline_at`: string | null
- `edits`: object — artisan edits made on device (device wins)

### EventIn

- `type` *: string
- `product_id` *: string
- `meta`: object

### EventsIn

- `events` *: array

### HTTPValidationError

- `detail`: array

### IvrSimulate

- `phone` *: string
- `digits`: string

### ModerateIn

- `action` *: string
- `reason`: string | null
- `title`: string | null
- `description`: string | null

### OperatorArtisanCreate

- `name` *: string
- `name_native`: string | null
- `village`: string | null
- `district`: string | null
- `state`: string | null
- `craft_type`: string | null
- `years_practice`: integer | null
- `story_text`: string | null
- `story_audio_key`: string | null
- `photo_key`: string | null
- `pehchan_id`: string | null
- `shg_name`: string | null
- `csc_id`: string | null
- `cluster`: string | null
- `gi_tag`: string | null
- `gender`: string | null
- `consent`: ConsentIn
- `phone`: string | null — artisan may not own a phone
- `language`: string
- `attestation` *: string — operator attests to identity and consent
- `consent_audio_upload_id`: string | null

### OrderStatusIn

- `status` *: string
- `note`: string | null

### OtpRequest

- `phone` *: string
- `language`: string

### OtpRequested

- `challenge_id` *: string
- `expires_in` *: integer
- `dev_otp`: string | null — Only returned when SMS_PROVIDER=mock (dev/demo)

### OtpVerify

- `phone` *: string
- `code` *: string
- `role`: string
- `language`: string | null

### PaymentConfirm

- `provider_order_id` *: string
- `payment_id` *: string
- `signature` *: string

### PriceAdjust

- `price`: number | null
- `spoken`: string | null — e.g. 'make it 1,600' / 'सोलह सौ कर दो'

### PricePreviewIn

- `category` *: string
- `material_cost`: number | null
- `hours`: number | null
- `state`: string | null
- `techniques`: array
- `gi_craft`: string | null
- `weight_g`: number | null

### ProductEdit

- `title`: string | null
- `description`: string | null
- `category`: string | null
- `quantity`: integer | null

### ReviewIn

- `order_item_id` *: string
- `rating` *: integer
- `text`: string | null

### RevokeIn

- `reason` *: string

### SchemeLinkIn

- `scheme` *: string
- `artisan_id`: string | null
- `cluster`: string | null
- `note`: string | null

### SettingsIn

- `commission_pct`: number | null
- `fair_wage_default`: number | null
- `fair_wage_by_state`: object | null
- `supported_languages`: array | null
- `buyer_languages`: array | null
- `providers`: object | null
- `fairness_boost`: object | null
- `tile_tap_mode`: string | null
- `team_id`: string | null

### TokenOut

- `access_token` *: string
- `token_type`: string
- `user_id` *: string
- `role` *: string
- `has_profile` *: boolean

### UploadCreate

- `idempotency_key` *: string
- `kind` *: string
- `content_type` *: string
- `total_size` *: integer
- `sha256`: string | null

### UploadStatus

- `upload_id` *: string
- `received` *: integer
- `total_size` *: integer
- `status` *: string
- `storage_key`: string | null

### ValidationError

- `loc` *: array
- `msg` *: string
- `type` *: string
- `input`: 
- `ctx`: object

### VerifyArtisanIn

- `status` *: string
- `pehchan_verified`: boolean
- `note`: string | null
