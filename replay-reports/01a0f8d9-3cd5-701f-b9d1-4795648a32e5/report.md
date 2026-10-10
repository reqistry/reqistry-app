# 01a0f8d9-3cd5-701f-b9d1-4795648a32e5
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8d9-3cd5-701f-b9d1-4795648a32e5) · 2026-10-01 19:03–19:06 UTC · 118s (active 100s!) · 48 clicks · start `/auth` · Mobile/Android · 22 events

## Timeline
- 19:03:03 Installed → Opened → `/auth` → 19:03:37 bg (34s auth dwell) → back → `$identify` → root
- 19:03:47 `$exception` **[ConcurrentModificationError]** @root (4s after first root)
- 19:03:49 projects → root → submit → root → projects ×2 → projects (20s gap) → projects (40s) → projects (64s — lengthening reads)
- 19:05:58 root → account ×4 (19:05:59–19:06:20, last three within 16s — toggling settings), end

## What the user does
Account-first session: projects ×6 with deepening dwell (20s→40s→64s — actually reading project pages), then account-settings ×4. Zero API content the whole 2 minutes.

## Weird moment
The lengthening project dwells look like growing interest — then a hard pivot to account lately: either "I need to log in to do more" or settings curiosity killed the browsing. The crash 4s after root may have wiped whatever feed state they started with.

## Delays
18s inactive only — brisk throughout. No stalls.

## Emotion arc
Task-oriented, brisk, no rage. But zero content views = job unfinished if the job was "use the app" rather than "set up the app."

## Improvements
1. Defer settings behind first value: this user spent their first 2 minutes in projects/account with zero API views. Gate organization behind first detail, not before.
2. No save/settings-change events captured at all — verify settings writes flush (silent settings loss = repeat visits like this one).
