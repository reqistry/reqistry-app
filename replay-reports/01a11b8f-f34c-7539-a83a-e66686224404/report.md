# 01a11b8f-f34c-7539-a83a-e66686224404
[Open replay](https://us.posthog.com/project/638414/replay/01a11b8f-f34c-7539-a83a-e66686224404) · 2026-10-08 12:49 UTC · 14s (active 11s) · 12 clicks · start root · platform UNKNOWN — zero rows in `events` for this `$session_id`

## Timeline
No event timeline exists. Replay shows ~14s of root interaction (12 clicks, 24 mouse moves, activity score 61 — genuinely engaged, not a bot).

## What the user does
Unknowable from telemetry — clicks around root for 14s with nothing recorded. Highest click-density of any short session (~1/sec) vanishing into a blind spot.

## Weird moment
The session itself: a replay with no events means the SDK recorded visuals but the event pipeline (consent, batching, session-stitch) dropped everything. Cross-check: homepage web sessions the day before/after all show `$dead_click`s — if this user hit the same dead element 12 times, we'd never know which one.

## Delays
None measurable.

## Emotion arc
Curiosity only — opened, clicked fast, left. Impossible to say whether frustrated or satisfied.

## Improvements
1. Fix session stitching (replay↔events join on `$session_id`) — this is a telemetry P0 hiding inside a UX report.
2. Until fixed, treat "replay without events" as its own alert category; 1/46 blind is tolerable, a trend is not.
