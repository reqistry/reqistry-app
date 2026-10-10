# 01a101e9-0a5d-77b3-86b9-fccdd807850d
[Open replay](https://us.posthog.com/project/638414/replay/01a101e9-0a5d-77b3-86b9-fccdd807850d) · 2026-10-03 13:16–13:19 UTC · 184s (active 66s!) · 94 clicks · start `/auth` · Mobile/Android · 24 events

## Timeline
- 13:16:52 Opened → Installed → `/auth` → `$identify` → root (clean start)
- 13:16:57 `$exception` **[ConcurrentModificationError]** @root (2s after first root!)
- 13:17:04 category → 13:17:20 slug + detail → 13:17:21 `$exception` **[ConcurrentModificationError]** @slug (**1s** after detail)
- 13:17:27 category → root → `$set` → recommended → slug + detail → recommended → slug + detail → recommended → root → latest (13:17:27–13:18:03: 8 screens in 36s)
- 13:18:03 bg → 114s gap → 13:19:58 Opened, end

## What the user does
Dense browse: 94 clicks in 66 active seconds (1.4/s), 3 details via category + recommended rails, 0 saves.

## Weird moment
Two crashes in the first 30s (2s and 1s after render — the fastest crash onsets in the set), yet the user kept tapping at 1.4 clicks/sec. The tap-spam IS the crash response: mashing through error states. The 114s background gap then a bare Opened = came back, saw latest, left.

## Delays
118s inactive (64%) — mostly the final park, not mid-flow stalls.

## Emotion arc
Agitation from second 2 (crash-on-root) → frantic browsing → parked. Tap-spam is mobile for double-clicking a frozen button.

## Improvements
1. Press-state feedback on every card within 100ms — taps must visibly land even when the tour is throwing underneath.
2. The 1s-detail→exception timing here is the extreme of the ~10s pattern — audit what fires on detail mount (tour step attach?) and defer it past first paint.
