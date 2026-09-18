---
slug: google-play-subscriptions-production
status: awaiting-approval
intent: clear
review_required: true
pending-action: execute via separate `$ulw-execute google-play-subscriptions-production` session
approach: Harden current two-product Google Play subscription architecture, bind purchases to server-issued opaque account IDs, complete RTDN lifecycle support, configure production Play/GCP resources, deploy migration safely, verify through internal track and staged rollout, and add reconciliation/monitoring before full release.
---

# Draft: google-play-subscriptions-production

## Components (topology ledger)
<!-- Lock the SHAPE before depth. One row per top-level component that can succeed or fail independently. -->
<!-- id | outcome (one line) | status: active|deferred | evidence path -->
client-purchase | Correct Play product/base-plan selection, account binding, restore, and completion | active | lib/app/services/billing/billing_service.dart; lib/app/blocs/paywall/paywall_cubit.dart
server-verification | Google API verification, allowlists, token ownership, acknowledgement | active | apps/api/src/lib/play-billing.ts; apps/api/src/lib/billing-service.ts
entitlements | Durable schema plus server-enforced Pro gates and downgrade behavior | active | packages/database/prisma/migrations/20260907000000_pro_subscriptions/migration.sql; apps/api/src/lib/tiers.ts
rtdn | Authenticated, idempotent subscription/test/voided notification processing | active | apps/api/src/lib/rtdn.ts; apps/api/src/routes/v1/billing.ts
production-config | Play Console, Android Publisher API, Pub/Sub OIDC, secrets, migration deployment | active | .env.example; packages/config/src/index.ts; docker-compose.yml
release-operations | Internal-track lifecycle validation, staged rollout, telemetry, reconciliation, rollback | active | test/paywall_cubit_test.dart; apps/api/src/lib/*billing*.test.ts; apps/api/src/lib/rtdn.test.ts

## Open assumptions (announced defaults)
<!-- Record any default you adopt instead of asking, so the user can veto it at the gate. -->
<!-- assumption | adopted default | rationale | reversible? -->
platform scope | Android Google Play only; no iOS StoreKit | Request names Google Play and current backend implements Play only | yes
product types | Recurring subscriptions only; no consumables or one-time Pro | Existing client uses buyNonConsumable with subscription IDs | yes
scale | Current Docker/Postgres/Redis topology; idempotency remains DB-backed across replicas | Existing deployment and stores already use these systems | yes
release policy | Internal test, closed test, 10% production, then 100% after clean observation window | Lowest-risk reversible rollout | yes
offer policy | Exactly one active base plan and zero separate offers per product until explicit offer UI exists | Client maps products by product ID and collapses multiple purchase options | yes

## Findings (cited - path:lines)
- Android application ID is `com.gwhyyy.publicApis` (`android/app/build.gradle.kts:28,44`); production `PLAY_PACKAGE_NAME` must match exactly.
- Client product IDs are `reqistry_pro_monthly` and `reqistry_pro_yearly` (`lib/app/services/billing/billing_service.dart:12-15`); backend allowlists both product and base-plan IDs (`apps/api/src/lib/play-billing.ts:71-75`).
- Installed Android plugin automatically forwards a `GooglePlayProductDetails.offerToken`, but client reduces duplicate offer rows to one value per product ID (`billing_service.dart:29-36`; pub cache `in_app_purchase_android-0.5.3/lib/src/in_app_purchase_android_platform.dart:157-170`).
- Client listens continuously, verifies server-side before local grant, and completes pending purchases only after active entitlement (`paywall_cubit.dart:31,201-287`).
- Backend uses `purchases.subscriptionsv2.get`, validates product/base plan and lifecycle state, then acknowledges (`apps/api/src/lib/play-billing.ts:78-107,164-179`).
- Purchase-token ownership, linked-token handoff, and durable grant ordering exist (`apps/api/src/lib/billing-service.ts:47-91`; `apps/api/src/lib/prisma-billing-store.ts:31-118`).
- RTDN validates Pub/Sub OIDC audience/email, package name, and message IDs, then re-fetches Play state transactionally (`apps/api/src/lib/rtdn.ts:63-104`).
- RTDN parser accepts only `subscriptionNotification`; `testNotification` and `voidedPurchaseNotification` currently return HTTP 400 (`rtdn.ts:74-87`; `billing.ts:105-106`).
- Client does not set `applicationUserName`/`obfuscatedAccountId`, and backend does not compare `externalAccountIdentifiers`; first token claim is not cryptographically bound to expected app account.
- Production config fails closed unless Play/RTDN variables exist (`packages/config/src/index.ts:39-44`), but repo contains no real secrets or proof Play Console/Pub/Sub resources exist.
- Migration creates token ownership, RTDN dedup, agent key, watchlist, and stack snapshot structures, but has not been proven applied to production (`packages/database/prisma/migrations/20260907000000_pro_subscriptions/migration.sql`).
- Local verification is green: Flutter analyze 0, Flutter tests 80/80, API tests 42/42, worker 12/12, MCP 7/7, workspace build, and debug APK build.

## Decisions (with rationale)
- Preserve server-authoritative entitlement model and email-link prerequisite.
- Keep secrets server-side; never embed service-account JSON in APK.
- Process RTDN as trigger only; always fetch current `subscriptionsv2` state before mutation.
- Add durable acknowledgement/reconciliation instead of relying only on client repeat verification.
- Test strategy default: TDD for code gaps, contract/integration tests for API + database, then Play internal-track lifecycle matrix and staged rollout evidence.
- Production deployment uses existing Docker Compose topology with encrypted host/environment secrets and `prisma migrate deploy` through the existing database-setup service.
- Initial Play catalog uses two subscription products: `reqistry_pro_monthly` at USD 4.99/month with base plan `monthly`, and `reqistry_pro_yearly` at USD 39.99/year with base plan `yearly`; Google Play localizes regional pricing. Exactly one active base plan and zero separate offers per product until offer-aware UI exists.
- Purchase binding uses a server-issued stable opaque non-PII billing account ID, passed as Play `obfuscatedAccountId` and compared against `externalAccountIdentifiers` during verification.
- Current app `5.2.0+14` sends no build header, fetches no entitlement gate before `buy()`, and can open Play billing whenever products load; rollout must add both controls and still account for stale builds (`pubspec.yaml:2`; `dio_client.dart:40-64,259-264`; `paywall_cubit.dart:75-147`).
- Same-email link/login canonicalizes email, merges into the existing email-linked device/account, deactivates the anonymous device, and returns replacement tokens; restore should reuse canonical account ID rather than transfer ownership (`anonymous.ts:149-269`; `auth_cubit.dart:202-260`).
- Official RTDN currently has five mutually exclusive variants; test notification has no purchase fields, and pending-refund-review requires response within 24 hours (`https://developer.android.com/google/play/billing/rtdn-reference`).
- Normal acknowledgement deadline is three days after `PURCHASED`; license-test purchases refund after about three minutes, so retries need a stricter test-track assertion (`https://developer.android.com/google/play/billing/integrate`; `https://developer.android.com/google/play/billing/test`).
- Deactivating a base plan blocks new purchases while existing subscriptions continue; reactivation can expose backward-compatible plans to stale builds, so remote client flags alone are not full containment (`https://developers.google.com/android-publisher/api-ref/rest/v3/monetization.subscriptions.basePlans/deactivate`; `https://developer.android.com/google/play/billing/compatibility`).
- `subscriptionsv2.get.externalAccountIdentifiers` is optional for legacy purchases; safe enforcement needs mismatch rejection immediately plus a purchase-time cutoff for missing IDs (`https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2`).

## Scope IN
- Flutter purchase/account-binding changes, backend Play verification and RTDN lifecycle gaps, schema/migration validation, production environment wiring, Play Console/GCP setup, observability, reconciliation, test tracks, staged rollout, and rollback.

## Scope OUT (Must NOT have)
- iOS/App Store billing, web checkout, Stripe, consumables, lifetime purchases, coupons/referrals, family sharing, custom tax/invoice systems, or paywall redesign.

## Open questions
- None. User continued after recommended defaults were presented; skipped owner questions resolve to first recommended options per CLEAR-path contract.

## Approval gate
status: plan-written
brief: Plan current architecture through code hardening, migration, Play/GCP setup, RTDN lifecycle support, account binding, internal-track lifecycle tests, staged rollout, monitoring, reconciliation, and rollback using recorded defaults.
next: Plan created after approval; mandatory Metis gap analysis folded in. Offer optional high-accuracy plan review or execute separately with `$ulw-execute google-play-subscriptions-production`.
metis: bg_8a9de07d completed; G1-G12 folded into tasks 1-19.

## Review state
phase: review_round_complete
round_status: approved
workspace_root: /home/gwhyyy/Downloads/projects/real_projects/reqistry/reqistry-app
runtime_home: null
target: .omo/plans/google-play-subscriptions-production.md
plan_sha256: 3dda7931fbb707bbc9135ee5974e613994afe4467a46f517af57e6e00580da8c
review_round_id: billing-review-r3-1788806124
max_rounds: 5
momus_status: approved
momus_launch_id: momus-1788806124
momus_session: ses_f82d81407ffe36FxnthaQhjEx1
momus_task: bg_b78d8128
momus_result: okay; all cited files verified in both repos; no contradictions; two non-blocking notes (plugin path omits lib/src/types segment; test/dio_client_test.dart created by task 1)
independent_status: approved
independent_launch_id: oracle-1788806124
independent_session: ses_f82d8014effeT8ncXftCjfn2uB
independent_task: bg_7c16cb70
independent_result: approve; zero blocking findings; all 12 audit dimensions verified against code plus official RTDN reference
accepted_blockers: [canonical-account restore semantics, staged null-to-bound account transition, complete current RTDN event union and nullable durable schema, current-versus-historical voided-token handling, split RTDN resource setup from post-deploy validation, executable rollout containment and hotfix path, complete predeploy commands, acknowledgement enqueue-loss recovery, exact product-base-plan pair validation]
non_blocking_notes: [Use one active base plan and zero separate offers per product; preserve verification/acknowledgement/RTDN/reconciliation during purchase containment; worker must treat client-side-already-acknowledged as success and test that path explicitly (task 8); task-15 post-cutoff-null live row deferred to task-17 rehearsal, unit coverage in task 3; plugin reference `google_play_product_details.dart` lives under lib/src/types/]
round_1: sha=f28a6d1fe6c6a697558662739f23fca6f97b2b98d3da0d4086827858c7353cb6; momus=changes_requested; oracle=changes_requested; findings folded into round 2
round_2: sha=3171c13c23775d0460ffa296ea9b76af6099bf0e441a5fd62cc652392e65b616; momus=changes_requested (task-7 migration script name, task-19 QA not executable); oracle=approve (wave-1 prose/matrix task-4 parallelism note); all three folded into round 3
round_3: sha=3dda7931fbb707bbc9135ee5974e613994afe4467a46f517af57e6e00580da8c; momus=okay; oracle=approve; plan approved for execution
<!-- When exploration is exhausted and unknowns are answered, set status: awaiting-approval. -->
<!-- That durable record is the loop guard: on a later turn read it and resume at the gate instead of re-running exploration. -->
