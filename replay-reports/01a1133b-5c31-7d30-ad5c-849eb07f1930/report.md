# 01a1133b-5c31-7d30-ad5c-849eb07f1930
[Open replay](https://us.posthog.com/project/638414/replay/01a1133b-5c31-7d30-ad5c-849eb07f1930) · 2026-10-06 22:00–22:05 UTC · 356s (active 233s) · 103 clicks · start `/auth` · Mobile/Android · 49 events

## Timeline
- 22:00:20 Installed → Opened → `/auth` → `$identify` → root (25s, clean login)
- 22:00:32 background → back (8s — notification or app-switch during onboarding)
- 22:00:40 `$exception` **[ConcurrentModificationError]** @root
- 22:00:57 slug → detail → 22:01:08 `$exception` **[ConcurrentModificationError]** @slug (11s after detail)
- 22:01:27–22:02:40 slug ×5 + **4 `api_detail_alternative_opened` in 55s** — comparison sprint
- 22:03:07 outbound doc → bg → back → 2 bookmarks → root → `/search` ×6 (22:03:30→22:05:45, gaps up to 2 min — typing/thinking), ends on search

## What the user does
The comparison shopper: login → survives 2 crashes → compares 4 alternatives in under a minute → checks docs externally → saves twice → ends searching.

## Weird moment
Two crashes bracketing the core loop (one on root, one 11s into the first detail) changed nothing — user powered through. Either the crashes are visually subtle (tour overlay flicker) or this user is unusually tolerant.

## Delays
123s inactive (35%) — legit reading + the 2-min search-think at the end.

## Emotion arc
Resilient engagement throughout; no deletes (2 creates, 0 deletes — healthy saving), no report. Highest-intent healthy session in the Oct-6 cluster.

## Improvements
1. Clone this path: side-by-side alternatives would compress the 4-opens-in-55s sprint into one screen.
2. The closing 2-min search that ends the session with no detail view = search returned nothing useful — log that query; it's a content gap, not a UX gap.
