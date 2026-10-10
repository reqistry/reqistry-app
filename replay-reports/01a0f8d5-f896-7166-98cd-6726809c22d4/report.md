# 01a0f8d5-f896-7166-98cd-6726809c22d4
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8d5-f896-7166-98cd-6726809c22d4) · 2026-10-01 18:59 UTC · 0s · 4 keypresses · start `reqistry.dev/` · Desktop/Linux/Chrome · 1 event (`$pageview /` only — no vitals, no leave)

## Timeline
- 18:59:30 single `$pageview`. Zero-second duration, 4 keypresses (close chord), no `$pageleave` flushed.

## What the user does
Tab opened and keyboard-closed in the same second. Phantom visit.

## Weird moment
No vitals, no leave — the instrumentation barely noticed either. Pairs with `…ff71` (same shape, next evening): keyboard-close phantoms are a recurring ~4% of traffic.

## Delays
None.

## Emotion arc
None — noise.

## Improvements
1. Exclude 0s single-pageview sessions from engagement denominators (same filter as `…ff71`).
