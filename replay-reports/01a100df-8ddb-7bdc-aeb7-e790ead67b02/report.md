# 01a100df-8ddb-7bdc-aeb7-e790ead67b02
[Open replay](https://us.posthog.com/project/638414/replay/01a100df-8ddb-7bdc-aeb7-e790ead67b02) · 2026-10-03 08:26–08:32 UTC · 320s (active 131s) · 93 clicks · start root · Mobile/Android · 15 events

## Timeline
- 08:26:53 Opened (returning user, no install) → root → `$set` → 08:27:13 slug + detail
- 08:29:07 `$exception` **[ConcurrentModificationError]** @slug (114s after detail — the SLOWEST crash onset in the set)
- 08:29:11 alt-opened + detail (4s later — **opened an alternative as crash recovery**)
- 08:31:02 alt-opened + detail again (111s later) → slug → 08:32:13 outbound → bg, end

## What the user does
Browse → compare → docs: 3 details, 2 alternative-opens, 1 outbound doc, backgrounds once to read it, returns, ends. Determined evaluator.

## Weird moment
114s-detail→exception is an outlier (rest of set: 1–15s). A delayed trigger — tour step on timer? related-fetch on scroll-depth? Whatever fires late on slug pages. And the user answered it by opening an alternative within 4 seconds: alt-open AS error recovery, twice.

## Delays
189s inactive (59%) — doc-reading gap, healthy.

## Emotion arc
Diligent throughout; error met with workaround, not complaint. Zero deletes.

## Improvements
1. Find the late-firing slug trigger (~2 min). If it's a timed tour step, kill it — interrupting a reading user is the worst moment to crash.
2. The outbound-then-return loop works — shorten it with in-app doc preview so the 59% gap doesn't risk losing them.
