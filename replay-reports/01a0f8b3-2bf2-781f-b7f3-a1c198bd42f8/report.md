# 01a0f8b3-2bf2-781f-b7f3-a1c198bd42f8
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8b3-2bf2-781f-b7f3-a1c198bd42f8) · 2026-10-01 18:21–18:26 UTC · 291s (active 180s) · 88 clicks · start `/auth` · Mobile/Android · 45 events, 3 exceptions (most per minute in set)

## Timeline
- 18:21:28 Installed → Opened → `/auth` → 18:22:01 bg (30s) → back → `$identify` → root
- 18:22:15 `$exception` **[ConcurrentModificationError]** (7s) → projects → root → root (42s) → submit → root ×3 → notifications → root → watchlists ×2 → root
- 18:23:52 search ×2 → root → 18:24:14 slug + detail → 18:24:17 `$exception` **[ConcurrentModificationError]** (3s) → save → created → 10s → deleted → save → root → created → 15s → deleted
- 18:25:19 search → root → watchlists ×2 → root ×2 → 18:25:52 slug + detail → root → 18:26:03 created → `$exception` **[_TypeError]** (same second as the create!) → bg, end

## What the user does
Full-loop user twice over: search → detail → save → verify-in-watchlist → repeat. Uses watchlists as save verification — behavior the toggle's ambiguity CREATES.

## Weird moment
The `_TypeError` fires in the SAME second as a `bookmark_created` (18:26:03.324 vs :03.485) — the save path itself throws. Only 2 `_TypeError`s in 46 sessions (other: marathon `…013` 08:09) and both sit on save-heavy flows. This is the smoking gun for the toggle bug: the create call throws TypeError, state never commits, user retries → thrash.

## Delays
111s inactive (38%) — verification laps (save → watchlist → back) cost the time.

## Emotion arc
Distrust-driven looping: save → go look → come back → save again. Mild but corrosive; ended by background, not by success.

## Improvements
1. Fix the `_TypeError` on the bookmark-create path first — stack-trace this exact 18:26:03 event; it may BE the whole save bug.
2. Kill the verification loop with inline "Saved to [Watchlist] · View" confirmation — one toast removes two round-trips per save.
