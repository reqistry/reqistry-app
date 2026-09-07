# google-play-subscriptions-production - Work Plan

## TL;DR (For humans)
**What you'll get:** Production-safe Android subscriptions with account-bound purchases, reliable refund and renewal handling, durable acknowledgement, automated reconciliation, complete Play/Google Cloud setup, staged rollout, monitoring, and rollback procedures.

**Why this approach:** Backend remains entitlement source of truth. Every paid-state transition is authenticated, idempotent, recoverable, and proven first on Play test tracks before customer rollout.

**What it will NOT do:** No iOS billing, Stripe/web checkout, lifetime products, discounts, referrals, tax system, or paywall redesign.

**Effort:** XL
**Risk:** High - live money, account ownership, production schema, Google Cloud IAM, and store-controlled lifecycle transitions.
**Decisions to sanity-check:** Two products at $4.99 monthly / $39.99 yearly; one active base plan and zero separate offers per product; seven-day grace; thirty-day hold; Docker Compose deployment; server-issued opaque account binding.

Your next move: run the plan in a separate worker session, or request high-accuracy plan review first. Full execution detail follows below.

---

> TL;DR (machine): XL/high-risk cross-repo rollout: secure account-bound Play verification, complete RTDN/refund handling, durable ack/reconciliation, production GCP/Play setup, and gated internal-to-100% release.

## Scope
### Must have
- Android Google Play subscriptions only, using `reqistry_pro_monthly` / `monthly` and `reqistry_pro_yearly` / `yearly`.
- Server-authoritative entitlements, server-issued opaque billing account ID, canonical email-account restore, Play token ownership, linked-token migration, and backend enforcement for every Pro endpoint.
- `subscriptionsv2.get` verification, allowlisted product/base-plan validation, durable acknowledgement retry, authenticated/idempotent RTDN, test-notification acceptance, voided/refund revocation, and nightly reconciliation.
- Expand-only Prisma migration, production config validation, Docker Compose deployment order, Android Publisher API/service-account permissions, Pub/Sub OIDC push, exact public RTDN audience, and machine-captured setup evidence.
- Internal-track lifecycle verification, closed-track canary, 10% staged production release, full rollout, monitoring, alert thresholds, and rollback runbook.
- TDD for all logic changes, synchronized `openapi.mobile.json` in both repos, `flutter analyze`, `flutter test`, debug/release builds, API/worker/MCP tests, and full pnpm workspace build.
### Must NOT have (guardrails, anti-slop, scope boundaries)
- No iOS/StoreKit, Stripe, web checkout, consumables, lifetime purchase, coupons, referrals, family sharing, tax/invoice system, or paywall redesign.
- No client-authoritative Pro grant, service-account material in APK/source/logs, raw purchase-token logging, unauthenticated RTDN, destructive edits to the existing migration, or schema rollback during incident response.
- No additional billing abstraction/framework; extend current `BillingService`, `PaywallCubit`, Play gateway, Prisma store, BullMQ worker, and existing tests.
- No multiple active base plans/offers per product until offer-aware selection UI and contract exist.
- No reset/revert/stash of unrelated dirty-worktree changes. Stage only explicit payment paths if execution later authorizes commits.

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: TDD. Dart `flutter_test`; Node `node:test` through package scripts; Fastify `inject`; Prisma migration validation against disposable PostgreSQL; Play/GCP validation through authenticated browser/API/`gcloud` commands; real Android purchase flow through internal-track build and Play Billing Lab.
- Evidence: <attemptDir>/task-<N>-google-play-subscriptions-production.<ext> (attemptDir = currentAttemptDir from 'omo-agent-toolkit ulw-loop status --json', .omo/evidence/ulw/<session>/<goalId>/a<attempt>; outside ulw-loop use .omo/evidence/)
- Every external-resource task must save sanitized command output or screenshot evidence. Never save tokens, service-account JSON, order IDs, purchase tokens, email addresses, or unredacted headers.
- A Play Console or GCP authentication/MFA pause is `[blocked]`, not a failed product test. Resume only in the same authenticated browser/session after user approval.

## Execution strategy
### Parallel execution waves
> Target 5-8 todos per wave. Fewer than 3 (except the final) means you under-split.
- Wave 1 - Code and data safety: tasks 1-8. Tasks 1 and 7 can begin in parallel; tasks 2/3/5/6/8 follow the dependency matrix, including task 4 after 3.
- Wave 2 - Reliability and production resources: tasks 9-14. Reliability code (9), preflight (10), GCP (11), Play catalog (12), and public endpoint prep (13) can overlap; deployment (14) waits for all.
- Wave 3 - Store validation and rollout: tasks 15-19, sequential promotion with explicit stop gates.
- Final wave: F1-F4 run only after task 19 evidence exists. Any rejection blocks completion.

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 1 | - | 2, 3, 14 | 4, 7 |
| 2 | 1 | 15 | 3, 6, 8 |
| 3 | 1 | 4, 6, 15 | 2, 7 |
| 4 | 3 | 15 | 2, 7, 8 |
| 5 | 7 | 6, 15 | 2, 3, 4, 8 |
| 6 | 3, 5, 7 | 9, 15 | 2, 4, 8 |
| 7 | - | 5, 6, 8, 9, 14 | 1, 4 |
| 8 | 7 | 14, 15 | 2, 4, 6 |
| 9 | 3, 6, 7 | 14, 18 | 10, 11, 12, 13 |
| 10 | 1, 5, 7 | 14 | 9, 11, 12, 13 |
| 11 | - | 13, 14 | 9, 10, 12 |
| 12 | - | 15 | 9, 10, 11, 13 |
| 13 | 11 | 14, 15 | 9, 10, 12 |
| 14 | 1-13 | 15 | - |
| 15 | 2-14 | 16 | - |
| 16 | 15 | 17 | - |
| 17 | 16 | 18 | - |
| 18 | 17 | 19 | - |
| 19 | 18 | F1-F4 | - |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->
- [ ] 1. Add opaque billing-account, client-build gate, and structured-error contract
  What to do / Must NOT do: Send integer `X-Reqistry-App-Build` from shared Dio options; extend backend entitlements with `billingAccountId = deviceToken.id` and server-derived `purchasesEnabled = PLAY_PURCHASES_ENABLED && build >= PLAY_MINIMUM_BILLING_BUILD`; extend Flutter `Entitlements`; refresh entitlements before product load and immediately before `buy()`; synchronize both OpenAPI copies; preserve `email_required`, `inactive_subscription`, `upgrade_required`, and ownership codes in typed `Failure`. Missing/old build fails purchase verification with `upgrade_required`. `purchasesEnabled=false` blocks new billing-sheet launch in updated clients but never blocks verification, acknowledgement, RTDN, or reconciliation. Must not expose fingerprint, email, purchase token, or order ID.
  Parallelization: Wave 1 | Blocked by: none | Blocks: 2, 3, 14
  References (executor has NO interview context - be exhaustive): `../reqistry-web-api-mcp-admin/apps/api/src/routes/v1/billing.ts:37-47,119-145`; `lib/app/data/models/pro.dart`; `lib/app/services/fetch_api/failure.dart`; `lib/app/services/fetch_api/remote_service.dart:536-582`; `lib/app/blocs/paywall/paywall_cubit.dart:246-255`; both `openapi.mobile.json` billing paths.
  Acceptance criteria (agent-executable): backend tests prove current build returns opaque UUID/enabled flag, missing/old build returns disabled plus typed upgrade error on verify, and sensitive fields stay absent; Flutter tests prove build header on both Dio clients, pre-purchase refresh, disabled Buy, and typed errors; OpenAPI copies match byte-for-byte.
  QA scenarios (name the exact tool + invocation): `pnpm --filter @public-apis/api test`; `flutter test test/pro_models_test.dart test/paywall_cubit_test.dart test/dio_client_test.dart`; fixtures cover flag off, missing header, minimum-minus-one, and current build; Evidence `<attemptDir>/task-1-google-play-subscriptions-production.txt`.
  Commit: Y | `feat(billing): expose opaque account contract`
  Recommended task executor category: `deep` - cross-repo API/model/error contract.

- [ ] 2. Bind Android purchases to billingAccountId and enforce one-offer policy
  What to do / Must NOT do: Pass task-1 ID as `PurchaseParam.applicationUserName` (Android obfuscated account ID); preserve automatic `GooglePlayProductDetails.offerToken`; make product loading reject or deterministically select only expected one-base-plan-per-product rows; include selected base-plan evidence in state/verification. Must not hash email, use device fingerprint, or hardcode localized prices.
  Parallelization: Wave 1 | Blocked by: 1 | Blocks: 15
  References: `lib/app/services/billing/billing_service.dart:9-52`; `lib/app/blocs/paywall/paywall_cubit.dart:75-148,235-287`; installed `in_app_purchase_android-0.5.3/lib/src/in_app_purchase_android_platform.dart:152-177`; `google_play_product_details.dart:54-117,149-154`.
  Acceptance criteria: tests prove account ID reaches purchase parameter, duplicate offers fail closed, monthly/yearly retain store prices, and purchase never launches without ID.
  QA scenarios: `flutter test test/paywall_cubit_test.dart test/pro_models_test.dart`; failure fixture returns duplicate offer rows and expects load error; Evidence `<attemptDir>/task-2-google-play-subscriptions-production.txt`.
  Commit: Y | `feat(billing): bind Play purchases to account`
  Recommended task executor category: `deep` - Android billing plugin-specific behavior.

- [ ] 3. Validate Play external account identifiers with timestamped enforcement
  What to do / Must NOT do: Parse optional `externalAccountIdentifiers.obfuscatedExternalAccountId` and purchase `startTime` from `subscriptionsv2.get`; compare against authenticated canonical account ID. Add `PLAY_ACCOUNT_BINDING_MODE=observe|enforce` and immutable `PLAY_ACCOUNT_BINDING_ENFORCE_AFTER`. Observe mode accepts missing IDs with redacted metrics but always rejects non-null mismatch. Enforce mode accepts missing ID only when authoritative Play `startTime` predates cutoff; missing ID on/after cutoff returns `upgrade_required`; matching bound purchases pass. Before switching, set purchases false, deactivate base plans, record adoption/legacy restore counts, deploy cutoff, then reactivate. Stale builds may still open a reactivated backward-compatible plan and will be rejected/refunded; document and monitor this unavoidable residual. RTDN validates identifier against recorded token owner. Must not trust client product/order/account fields.
  Parallelization: Wave 1 | Blocked by: 1 | Blocks: 4, 6, 15
  References: `../reqistry-web-api-mcp-admin/apps/api/src/lib/play-billing.ts:78-107,164-179`; `billing-service.ts:47-91`; `prisma-billing-store.ts:31-118`; Google Play backend/security and obfuscated-account documentation cited in draft.
  Acceptance criteria: tests cover match, mismatch, observe-mode null, pre-cutoff null restore, post-cutoff null rejection, missing/invalid cutoff config, forged client fields, and RTDN owner match; mismatch/post-cutoff null never grants or changes ownership.
  QA scenarios: `pnpm --filter @public-apis/api test`; inspect test output for external-account cases; Evidence `<attemptDir>/task-3-google-play-subscriptions-production.txt`.
  Commit: Y | `fix(billing): verify purchaser account binding`
  Recommended task executor category: `ultrabrain` - security-sensitive ownership invariant.

- [ ] 4. Prove canonical-account restore and reject cross-account transfer
  What to do / Must NOT do: Preserve existing unique-email auth behavior: login/link resolves one canonical `deviceToken.id`, so restore on another physical device uses the same billing account ID. If a purchase token belongs to any different account ID, keep 409 even when strings resemble the same email; no cross-ID transfer path. Add integration tests covering anonymous-to-email merge, second-device login returning canonical ID, restore on that ID, different-account rejection, and concurrent claims. RTDN compares external account ID to recorded canonical owner.
  Parallelization: Wave 1 | Blocked by: 3 | Blocks: 15
  References: `../reqistry-web-api-mcp-admin/apps/api/src/lib/billing-service.ts:62-91`; `prisma-billing-store.ts:31-68`; `billing-service.test.ts:104-168`; `rtdn-ownership.ts:19-47`.
  Acceptance criteria: second-device same-email login returns original account ID and restore succeeds idempotently; distinct IDs always remain 409; anonymous purchase remains blocked; concurrent claims have one owner.
  QA scenarios: `pnpm --filter @public-apis/api test`; run canonical-login/restore and concurrent-token tests 20 times without flake; Evidence `<attemptDir>/task-4-google-play-subscriptions-production.txt`.
  Commit: Y | `test(billing): lock canonical restore identity`
  Recommended task executor category: `ultrabrain` - transactional ownership/race logic.

- [ ] 5. Model every current RTDN variant with durable event-kind storage
  What to do / Must NOT do: After task-7 schema lands, replace subscription-only event shape with exhaustive union for `subscriptionNotification`, `oneTimeProductNotification`, `voidedPurchaseNotification`, `testNotification`, and `pendingRefundReviewNotification`. Validate outer message ID/data/package and exactly one payload variant. Persist event kind with nullable purchase token/notification type plus applicable order/product/refund fields. Test and one-time events durably deduplicate then 200/no-op; pending-refund-review creates redacted urgent job-log alert with 24-hour response deadline but does not mutate entitlement before authoritative resolution/voided event. Reject malformed/conflicting envelopes. Must not use sentinels or treat notification type as entitlement truth.
  Parallelization: Wave 1 | Blocked by: 7 | Blocks: 6, 15
  References: `../reqistry-web-api-mcp-admin/apps/api/src/lib/rtdn.ts:5-105`; `routes/v1/billing.ts:89-117`; `rtdn.test.ts:72-133`; official RTDN reference: `https://developer.android.com/google/play/billing/rtdn-reference`.
  Acceptance criteria: tests prove all five current variants parse and durably record; test notification stores no purchase fields and returns 200; pending refund emits one deduplicated urgent alert; valid voided subscription carries purchaseToken/orderId/refundType; malformed/wrong-package/multi-variant payloads reject; one-time event returns 200/no-op.
  QA scenarios: `pnpm --filter @public-apis/api test`; Fastify inject exact official example envelopes; Evidence `<attemptDir>/task-5-google-play-subscriptions-production.txt`.
  Commit: Y | `feat(billing): model complete RTDN envelope`
  Recommended task executor category: `deep` - external schema plus exhaustive parsing.

- [ ] 6. Revoke only currently bound voided subscriptions transactionally
  What to do / Must NOT do: For validated voided subscription event, find token owner and compare event token to device's current `playPurchaseToken`. Revoke only when it is current; if it is historical/linked, fetch and apply authoritative state for the current token and preserve valid replacement entitlement. Unknown token is durably recorded/no-op. Record mutation and message in one transaction. Must not revoke for test, pending-refund-review, or one-time-product notifications.
  Parallelization: Wave 1 | Blocked by: 3, 5, 7 | Blocks: 9, 15
  References: `../reqistry-web-api-mcp-admin/apps/api/src/lib/rtdn-ownership.ts`; `prisma-billing-store.ts:69-118,139-150`; migration `play_rtdn_messages`; official voided payload fields from RTDN reference.
  Acceptance criteria: tests prove current-token refund removes Pro immediately; voided historical token preserves active replacement; inactive replacement downgrades from authoritative fetch; duplicate is idempotent; unknown token no-ops; rollback leaves entitlement unchanged if message persistence fails.
  QA scenarios: `pnpm --filter @public-apis/api test`; transactional failure injection plus duplicate replay; Evidence `<attemptDir>/task-6-google-play-subscriptions-production.txt`.
  Commit: Y | `fix(billing): revoke voided Play purchases`
  Recommended task executor category: `ultrabrain` - money-state transactional correctness.

- [ ] 7. Add expand-only acknowledgement and RTDN event schema
  What to do / Must NOT do: Add new Prisma migration after existing `20260907000000_pro_subscriptions`. On `play_purchase_tokens` add mapped columns `product_id`, `acknowledgement_pending`, `acknowledgement_status`, `acknowledgement_attempts`, `acknowledgement_next_attempt_at`, `acknowledgement_last_error`, and `acknowledged_at`. On `play_rtdn_messages` add `event_kind`; make `purchase_token` and `notification_type` nullable; add nullable `order_id`, `product_type`, and `refund_type`. Extend stores so grant persists pending ack before API response and successful ack clears it. Never rewrite existing migration or use sentinel values.
  Parallelization: Wave 1 | Blocked by: none | Blocks: 5, 6, 8, 9, 14
  References: `../reqistry-web-api-mcp-admin/packages/database/prisma/schema.prisma:678-700`; migration `20260907000000_pro_subscriptions/migration.sql:11-31`; `billing-service.ts:76-91`; `billing-service.test.ts:148-168`.
  Acceptance criteria: disposable PostgreSQL applies all migrations from empty and current pre-change DB; test notification stores null token/type with event kind; grant+ack success clears pending; ack failure leaves Pro grant plus retryable pending row; rollback is previous-image deploy only.
  QA scenarios: create disposable DB, run `pnpm --filter @public-apis/database migrate:deploy`, query new columns/indexes; inject ack outage; Evidence `<attemptDir>/task-7-google-play-subscriptions-production.txt`.
  Commit: Y | `feat(database): persist Play acknowledgement state`
  Recommended task executor category: `deep` - schema plus transaction contract.

- [ ] 8. Add BullMQ acknowledgement retry worker, DB rescan, and alerts
  What to do / Must NOT do: Add dedicated billing queue/worker using existing Redis/BullMQ. Retry new-token acknowledgement at 30s, 2m, 10m, then hourly until acknowledged or authoritative purchase becomes inactive; update attempt/backoff/error/ack timestamps and alert if oldest pending reaches one hour. A periodic DB scan re-enqueues due rows so enqueue loss/restart cannot strand acknowledgement. Redact tokens; never terminally discard pending work. API returns activated after durable grant even when immediate ack fails.
  Parallelization: Wave 1 | Blocked by: 7 | Blocks: 14, 15
  References: `../reqistry-web-api-mcp-admin/apps/worker/src/index.ts:14-25,265-296`; `worker-reliability.ts`; `apps/worker/src/log.ts`; `apps/api/src/lib/play-billing.ts:172-179`; `billing-service.ts:88-91`.
  Acceptance criteria: worker tests prove success, duplicate idempotency, exponential retry, enqueue failure then DB-rescan recovery, process restart recovery, terminal alert, and no token leakage; API test proves ack outage returns active entitlement with durable pending row.
  QA scenarios: `pnpm --filter @public-apis/worker test && pnpm --filter @public-apis/api test`; Redis-backed local job run where available; Evidence `<attemptDir>/task-8-google-play-subscriptions-production.txt`.
  Commit: Y | `feat(worker): retry Play acknowledgements`
  Recommended task executor category: `deep` - distributed retry/idempotency.

- [ ] 9. Add nightly Play entitlement reconciliation
  What to do / Must NOT do: Schedule bounded batches over token rows, call `subscriptionsv2.get`, reuse the same ownership/state transition path as RTDN, enqueue missing acknowledgements, record mismatch counters, and checkpoint progress. Do not create a second entitlement algorithm or log purchase data.
  Parallelization: Wave 2 | Blocked by: 3, 6, 7 | Blocks: 14, 18
  References: `../reqistry-web-api-mcp-admin/apps/worker/src/index.ts:299-395`; `pro-digest.ts`; `apps/api/src/lib/play-billing.ts`; `prisma-billing-store.ts`; `rtdn-ownership.ts`.
  Acceptance criteria: tests cover active→expired, expired→recovered, missing token, Play 429/5xx retry, resume checkpoint, and no duplicate mutations; one local scheduled run writes sanitized job logs.
  QA scenarios: `pnpm --filter @public-apis/worker test`; fake gateway batch of mixed states; Evidence `<attemptDir>/task-9-google-play-subscriptions-production.txt`.
  Commit: Y | `feat(worker): reconcile Play entitlements`
  Recommended task executor category: `deep` - batch lifecycle state machine.

- [ ] 10. Build production billing preflight, exact pair config, and fail-closed checks
  What to do / Must NOT do: Replace independent product/base-plan allowlists with `PLAY_ALLOWED_SUBSCRIPTION_PAIRS=reqistry_pro_monthly:monthly,reqistry_pro_yearly:yearly`; add `PLAY_ACCOUNT_BINDING_MODE`, `PLAY_ACCOUNT_BINDING_ENFORCE_AFTER`, `PLAY_PURCHASES_ENABLED`, and `PLAY_MINIMUM_BILLING_BUILD`; add read-only preflight validating production mode, package, service-account JSON shape without printing it, exact pairs, binding mode/cutoff, build gate, HTTPS RTDN audience/path, OIDC email, DB/Redis, migration status, and endpoint reachability. Preserve fail-closed boot validation.
  Parallelization: Wave 2 | Blocked by: 1, 5, 7 | Blocks: 14
  References: `../reqistry-web-api-mcp-admin/packages/config/src/index.ts:39-44`; `.env.example:43-48`; `docker-compose.yml:15-20,55-82`; `apps/api/src/lib/billing-config.test.ts`.
  Acceptance criteria: command exits 0 only for exact sanitized fixture; cross-paired product/base-plan is rejected; each missing/mismatched field fails with field name but no secret; `curl -X POST $RTDN_AUDIENCE` without bearer returns 401 after deployment.
  QA scenarios: run preflight against valid fixture and six invalid fixtures; save redacted output; Evidence `<attemptDir>/task-10-google-play-subscriptions-production.txt`.
  Commit: Y | `chore(billing): add production preflight`
  Recommended task executor category: `quick` - contained validation script/tests.

- [ ] 11. Configure Android Publisher API and service-account permissions
  What to do / Must NOT do: In target GCP project enable Android Publisher API; create/select dedicated server service account; link it in Play Console; grant only app-scoped View financial data/orders/cancellation responses and Manage orders/subscriptions permissions; store JSON in production secret channel. Must not grant owner/editor or place JSON in files, shell history, evidence, APK, or logs.
  Parallelization: Wave 2 | Blocked by: none | Blocks: 13, 14
  References: official `https://developers.google.com/android-publisher/getting_started`; authorization docs; approved Docker Compose deployment.
  Acceptance criteria: `gcloud services list --enabled` includes `androidpublisher.googleapis.com`; service account identity exists; authenticated read-only `subscriptionsv2.get` smoke against a license-test token reaches Google (200/404 acceptable, 401/403 fail); secret scan finds no private key.
  QA scenarios: valid scoped credential and deliberately unauthorized credential; browser/API evidence redacted; Evidence `<attemptDir>/task-11-google-play-subscriptions-production.txt`.
  Commit: N | external production resource
  Recommended task executor category: `deep` - authenticated cloud/Play configuration.

- [ ] 12. Configure exact Play subscription catalog and policies
  What to do / Must NOT do: Create/verify monthly product USD 4.99 with one active base plan `monthly` and yearly product USD 39.99 with one active base plan `yearly`; activate both; localize regional pricing; configure 7-day grace and 30-day hold; keep app package exact. Configure zero separate trial/intro/promo offers until offer-aware UI exists. This task validates console/API catalog only; client product query belongs to task 15.
  Parallelization: Wave 2 | Blocked by: none | Blocks: 15
  References: `lib/app/services/billing/billing_service.dart:12-36`; `../reqistry-web-api-mcp-admin/.env.example:45-46`; `play-billing.ts:71-107`; official subscription setup/lifecycle docs.
  Acceptance criteria: Play Console/API export shows exact package/products/base plans/prices/status/grace/hold, one active base plan per product, zero separate offers, and exact backend pair config.
  QA scenarios: authenticated browser/API inspection; negative check for extra active offers or ID mismatch; Evidence `<attemptDir>/task-12-google-play-subscriptions-production.{json,png}`.
  Commit: N | external Play catalog
  Recommended task executor category: `deep` - Play Console/browser work.

- [ ] 13. Provision RTDN resources before handler deployment
  What to do / Must NOT do: Create source topic, push subscription, and DLQ topic. Grant `google-play-developer-notifications@system.gserviceaccount.com` `roles/pubsub.publisher` on source topic. Create dedicated OIDC service account; grant provisioning principal `roles/iam.serviceAccountUser`; grant Pub/Sub service agent `roles/iam.serviceAccountTokenCreator` on OIDC account, `roles/pubsub.publisher` on DLQ topic, and `roles/pubsub.subscriber` on source subscription. Do not attach source topic in Play Console until task 14 deploys handler. Set exact endpoint/audience/email and retry/DLQ policy. Do not send test notification yet.
  Parallelization: Wave 2 | Blocked by: 11 | Blocks: 14, 15
  References: `../reqistry-web-api-mcp-admin/apps/api/src/lib/rtdn.ts:63-87`; `routes/v1/billing.ts:89-117`; compose binds API locally (`docker-compose.yml:72`) so external reverse proxy must route path; official RTDN setup/reference docs.
  Acceptance criteria: `gcloud pubsub topics/subscriptions describe` and IAM policy output prove topic, DLQ, endpoint, audience, OIDC SA, publisher, actAs, token-creator, DLQ forwarding roles, and retry settings; Play Console remains unattached until task 15.
  QA scenarios: authenticated resource inspection plus negative IAM simulation from unauthorized principal; Evidence `<attemptDir>/task-13-google-play-subscriptions-production.txt` plus redacted screenshot.
  Commit: N | external GCP/Play resource
  Recommended task executor category: `deep` - cloud IAM + public webhook security.

- [ ] 14. Run complete predeploy gate, then deploy expand-only backend
  What to do / Must NOT do: Capture initial status/diff/hash evidence for both dirty repos; snapshot DB and tag current API/worker image IDs with immutable rollback tags; run full command gate; execute `docker compose build database-setup api worker`, `docker compose run --rm database-setup`, `docker compose up -d --no-deps api`, wait for `curl --fail http://127.0.0.1:${API_PORT:-4001}/health`, then `docker compose up -d --no-deps worker`; run preflight; verify old mobile compatibility. Rollback retags/starts captured API/worker images with additive schema retained. Never down-migrate, edit applied SQL, or include unrelated dirty changes.
  Parallelization: Wave 2 | Blocked by: 1-13 | Blocks: 15
  References: `../reqistry-web-api-mcp-admin/docker-compose.yml:55-82`; both Prisma migrations; config/preflight task 10; worker tasks 8-9.
  Acceptance criteria: before deploy save exit-0 output for `flutter analyze`, `flutter test`, `flutter build apk --debug`, signed `flutter build appbundle --release`, `pnpm --filter @public-apis/api test`, `pnpm --filter @public-apis/worker test`, `cd apps/mcp && npx tsx --test src/*.test.ts`, `pnpm --recursive run build`, both OpenAPI equality, and migrations against empty/current disposable DB; then backup/migration/health/preflight/queue/reconciliation/old-client checks pass.
  QA scenarios: exact command transcript above; staging migration failure leaves old services running; previous-image API/worker rollback succeeds with additive schema; Evidence `<attemptDir>/task-14-google-play-subscriptions-production.txt`.
  Commit: N | production deployment
  Recommended task executor category: `deep` - stateful production rollout.

- [ ] 15. Activate RTDN, publish internal build, and run purchase smoke matrix
  What to do / Must NOT do: After task-14 handler deploy, attach Play Console RTDN topic, send test notification and require 200 plus durable test-kind dedup row. Produce signed release AAB with version/build bump above configured minimum; upload internal track; register license testers; install from Play; verify product queries/localized prices and fresh entitlement gate before Buy; execute monthly/yearly purchase, cancel, canonical-account restore on second physical device, pre-cutoff legacy-null restore, post-cutoff null rejection, different-account rejection, restart, offline pre-purchase failure, and duplicate RTDN. Never use real customer payment.
  Parallelization: Wave 3 | Blocked by: 2-14 | Blocks: 16
  References: Flutter Android signing/version config; `BillingService`; `PaywallCubit`; task 12 catalog; task 13 RTDN; official Play Billing testing docs.
  Acceptance criteria: unauthenticated endpoint returns 401; Play test notification returns 200 and deduplicates; every purchase matrix row records entitlement, external account ID, acknowledgement within three minutes, canonical token owner, RTDN row, and UI state; no stuck spinner, duplicate charge, sensitive log, or unauthorized Pro.
  QA scenarios: `curl` reachability/OIDC failures, Play test notification, Billing Lab/license tester on Play-installed Android, network cut, wrong-account restore; Evidence `<attemptDir>/task-15-google-play-subscriptions-production.md` plus redacted captures.
  Commit: Y | `chore(android): prepare subscription release build`
  Recommended task executor category: `deep` - real device/store integration.

- [ ] 16. Complete accelerated subscription lifecycle matrix
  What to do / Must NOT do: Through Play Billing Lab validate renewal, user cancel with access through expiry, grace, account hold immediate backend denial, recovery, expiry, resubscribe/linked token, full refund/voided event, revoke, acknowledgement retry, missed-RTDN reconciliation, and duplicate/out-of-order notification delivery.
  Parallelization: Wave 3 | Blocked by: 15 | Blocks: 17
  References: `play-billing.ts:54-107`; RTDN/reconciliation tasks 5, 6, 9; tier gate `tiers.ts:32-76`; official lifecycle/testing docs.
  Acceptance criteria: backend and app states match expected matrix for every transition; all Pro endpoints deny after hold/expiry/refund; recovery restores once; job logs show no poison retry loop.
  QA scenarios: accelerated Billing Lab flows plus replayed Pub/Sub fixtures; Evidence `<attemptDir>/task-16-google-play-subscriptions-production.md`.
  Commit: N | release evidence only
  Recommended task executor category: `deep` - time-dependent real-store lifecycle QA.

- [ ] 17. Promote to closed track and validate canary cohort
  What to do / Must NOT do: Promote unchanged tested artifact to closed track; use controlled testers across upgrade/new install/restore paths; observe one accelerated renewal window; freeze billing code. Rehearse binding switch: set purchases false, deactivate both base plans, set immutable cutoff, enable enforce mode, verify legacy pre-cutoff restore, then reactivate. Pre-stage incident containment: disable purchases, deactivate plans, halt rollout, redeploy previous compatible backend images, and build higher-version hotfix AAB. Do not claim Play can downgrade installed builds or fully stop stale builds opening reactivated backward-compatible products.
  Parallelization: Wave 3 | Blocked by: 16 | Blocks: 18
  References: tasks 8-10 telemetry; task 15 artifact; Play closed testing docs.
  Acceptance criteria: cohort and staged binding switch pass; SQL query `SELECT count(*) FROM play_purchase_tokens WHERE acknowledgement_pending AND acknowledgement_next_attempt_at < now()` returns 0; job-log query shows zero pending-refund SLA breach/terminal billing failures; Pub/Sub reports zero oldest-unacked age beyond retry window; `gcloud pubsub subscriptions seek` recovery is documented; containment and higher-version hotfix rehearsal completes on staging.
  QA scenarios: execute saved SQL, `gcloud pubsub subscriptions describe`, API health/entitlement curls, Play rollout halt/deactivate rehearsal, previous-image backend deployment, and hotfix AAB build; Evidence `<attemptDir>/task-17-google-play-subscriptions-production.md`.
  Commit: N | Play release promotion
  Recommended task executor category: `deep` - release operations + observation.

- [ ] 18. Roll production to 10 percent with executable containment thresholds
  What to do / Must NOT do: Promote same artifact to 10%; poll API/job-log/DB/Pub-Sub/Play-vitals plus post-cutoff null rejection/refund metrics. On threshold breach: halt rollout (new distribution only), disable updated-client purchase launch, deactivate base plans to stop all new sales, keep verify/ack/RTDN/reconciliation active, deploy previous compatible backend images, and submit higher-version hotfix AAB. Retain additive schema; never claim installed app downgrade or remote flag control over stale builds.
  Parallelization: Wave 3 | Blocked by: 17 | Blocks: 19
  References: task 14 rollback; worker job logs; Play vitals; approved staged-release default.
  Acceptance criteria: define numeric stop thresholds before rollout (zero ownership/account-binding violations; zero ack older than 1 hour; RTDN 5xx <1%; verify 5xx <1%); clean observation for 24 hours or minimum 25 completed test/customer purchases, whichever is later.
  QA scenarios: staging fault injection commands: force Play gateway 503 fixture, pause billing worker, publish duplicate/wrong-audience RTDN, create synthetic stale ack row, and induce reconciliation mismatch; assert alert appears, containment flag flips, rollout halt is visible, previous backend deploy passes health, and hotfix AAB version is higher; Evidence `<attemptDir>/task-18-google-play-subscriptions-production.md`.
  Commit: N | staged production release
  Recommended task executor category: `deep` - live-money canary operations.

- [ ] 19. Complete rollout and establish ongoing billing operations
  What to do / Must NOT do: Promote 100% only after task-18 gate; document weekly ack backlog/reconciliation review, monthly service-account/IAM review, quarterly refund/restore drill, pending-refund-review response within 24 hours, grandfathered-null account-ID burn-down, stale-build rejection/refund support, key rotation, and incident ownership. Keep pre-cutoff legacy restores supported after enforcement.
  Parallelization: Wave 3 | Blocked by: 18 | Blocks: F1-F4
  References: all prior evidence; external resource inventories; job-log/alert surfaces; account-binding metrics from task 3.
  Acceptance criteria: 100% release active; runbook names commands/owners/thresholds without secrets; first scheduled reconciliation and alert checks succeed; null-ID count tracked with closure date.
  QA scenarios: authenticated Play Console production-release inspection proving 100% rollout with redacted capture; `docker compose exec -T postgres psql -U "${POSTGRES_USER:-publicapis}" -d "${POSTGRES_DB:-public_apis}" -c "SELECT count(*) FROM play_purchase_tokens WHERE acknowledgement_pending"` returns 0; same psql `-c "SELECT job_type, level, count(*) FROM job_logs WHERE created_at > now() - interval '7 days' AND job_type LIKE 'billing%' GROUP BY 1,2 ORDER BY 3 DESC"` shows scheduled reconciliation success rows and zero `level='error'` terminal rows; `gcloud pubsub subscriptions describe <push-sub>` shows oldest-unacked age within retry window; rollback tabletop reads task-14 image-retag/rollback commands and task-17 containment rehearsal with named owner and saves transcript; Evidence `<attemptDir>/task-19-google-play-subscriptions-production.md`.
  Commit: Y | `docs(operations): add billing production runbook`
  Recommended task executor category: `writing` - operational handoff after technical completion.

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [ ] F1. Plan compliance audit - verify all 19 evidence files, dependencies, external prerequisites, both repo contracts, migration order, and rollout gates; verdict APPROVE/REJECT with pointers. Recommended category: `unspecified-high`.
- [ ] F2. Code quality and security review - audit payment trust boundaries, token/account ownership, OIDC, secret handling, transactions, retries, no new `any`/suppression, and tests; run `security-research` when team mode exists; verdict APPROVE/REJECT. Recommended category: `ultrabrain`.
- [ ] F3. Real manual QA - independently repeat internal-track monthly/yearly purchase, restore, refund/revoke, RTDN test, offline failure, and Pro endpoint denial; every row needs artifact. Recommended category: `deep`.
- [ ] F4. Scope fidelity - confirm Android-only billing scope, no unrequested payment systems/UI redesign, no unrelated dirty-worktree changes, and exact product/deployment decisions; verdict APPROVE/REJECT. Recommended category: `unspecified-high`.

## Commit strategy
- Two repositories, separate histories. Never create a cross-repo pseudo-atomic commit.
- Preserve dirty worktrees. Before execution record `git status`, `git diff`, and hashes for every payment path. Never reset, stash, or stage unrelated changes.
- Default task commits listed above are created only when execution authorization includes commits/PR. Stage explicit paths; shared dirty files require hunk-safe staging or no commit.
- Backend order: contract/account binding -> RTDN/ownership -> acknowledgement migration -> worker reliability -> preflight/runbook.
- Flutter order: typed contract/errors -> billing account/offer behavior -> signed release metadata.
- Sync both OpenAPI copies in the same logical contract change and verify byte equality before either repo is handed off.

## Success criteria
- `PLAY_PACKAGE_NAME` equals `com.gwhyyy.publicApis`; exact product/base-plan pairs are active with approved prices, one active base plan and zero separate offers per product, 7-day grace, and 30-day hold.
- Android Publisher API and least-privilege service account work; no credentials appear in source, APK, logs, commits, or evidence.
- Every new purchase is bound to expected opaque canonical account ID, verified against Play, owned by one account, acknowledged durably, and never transferred across account IDs; same-email restore reuses canonical ID.
- RTDN test/subscription/voided envelopes return correct 2xx/4xx, authenticate OIDC audience/email, deduplicate, revoke refunds, and never poison-retry valid messages.
- Nightly reconciliation repairs missed lifecycle events and acknowledgement backlog with redacted observability.
- Expand-only migrations apply from empty and current schema; API/worker rollback keeps schema intact.
- Flutter analyze/tests/release build and all backend tests/builds pass; both OpenAPI files are identical.
- Internal and closed lifecycle matrices pass; 10% canary meets thresholds; 100% rollout occurs only after evidence-backed gate approval.
