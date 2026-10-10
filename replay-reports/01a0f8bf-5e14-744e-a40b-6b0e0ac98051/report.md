# 01a0f8bf-5e14-744e-a40b-6b0e0ac98051
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8bf-5e14-744e-a40b-6b0e0ac98051) · 2026-10-01 18:34–18:37 UTC · 123s (active 112s — 91%, snappiest) · 55 clicks · start (null→/auth) · Mobile/Android · 21 events, ZERO exceptions

## Timeline
- Starts mid-flow (`$screen /auth`, no Installed — returning user) → `$identify` → root → submit → root → watchlists ×2 → root → submissions → submit → submissions → root → projects ×3 → root ×2 → search (5s: 18:36:13–18:36:18) → root (43s) → root → bg, end
- No `$exception` anywhere. The only mid-length mobile session with a clean sheet.

## What the user does
Brisk organizer: submit/submissions/projects/watchlists/search in 2 minutes, 19 screens, zero content opens, zero errors.

## Weird moment
Its cleanliness is the anomaly — same build, same flows as crashing siblings. What did this user NOT touch? No `category-apis`, no `slug`, no notifications. The crash surface narrows to category/slug/showcase paths by elimination.

## Delays
11s inactive (9%) — fastest pace in the set. Nothing waited.

## Emotion arc
Competent, brisk. No frustration, no delight spike — pure tasking.

## Improvements
1. Diff this path against crashers: the showcase tour + category fetch are the prime suspects; this session skipped both and survived.
2. Whatever empty-state copy this user saw in projects/watchlists worked at speed — reuse it app-wide.
3. The 5s search (open→close) recurs (`…c5fc` 1.5s) — search entry telemetry needed even when clean.
