# 01a10106-20c8-7fa1-8fec-7deaf12dde8e
[Open replay](https://us.posthog.com/project/638414/replay/01a10106-20c8-7fa1-8fec-7deaf12dde8e) · 2026-10-03 09:09–09:20 UTC · 672s (active 130s) · 74 clicks · start `/apis/:slug` · Mobile/Android · 18 events, ZERO exceptions

## Timeline
- 09:09:01 Opened **directly on slug** (deep link, no auth — returning user) → slug → 09:09:22 save + `bookmark_created` (4s apart — one gesture, two events) → slug → 09:09:42 save + created again → slug ×2 → root → recommended (38s) → slug + detail
- 09:13:17 bg → **6.5-min gap** → 09:19:40 back → save + created → 09:20:14 bg, end

## What the user does
Deep-links in, saves twice cleanly (3 saves + 3 creates, 0 deletes — the HEALTHY saver), browses recommended, leaves phone for 6.5 min, returns, saves once more, done.

## Weird moment
The 6.5-min background gap ending in a save: deferred intent that CONVERTED. Compare the 27-min gap in `…9fee` (died) — the difference is landing back on the save-ready detail page vs root. Deep-link return state matters.

## Delays
542s inactive (81%) — reading + the 6.5-min away. No stalls.

## Emotion arc
Satisfied collector throughout. Zero exceptions (no category/showcase path touched — further proof of the crash surface). The control case proving save CAN work first try.

## Improvements
1. Study what this slug page did right and port it to thrash pages — same gesture, opposite outcome vs the deep-dive.
2. Return-state: always restore the last detail (not root) on foreground — this session converts because of it.
3. The double-event save (save + created 4s apart for one gesture) still suggests pipeline duplication — harmless here, toxic elsewhere. Unify.
