# 01a0f8ba-5d4c-733c-8f10-c6632824860b
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8ba-5d4c-733c-8f10-c6632824860b) · 2026-10-01 18:29–18:34 UTC · 276s (active 181s) · 91 clicks · start `/auth` · Mobile/Android · 45 events

## Timeline
- 18:29:20 Installed → Opened → `/auth` → 18:29:51 bg (31s) → back → `$identify` → root
- 18:30:02 `$exception` **[ConcurrentModificationError]** @root (5s) → projects → root → watchlists ×3 → root → submit → root ×3
- 18:31:39 search ×2 → root → search → root ×3 → 18:32:31 bg (16s) → back → `$set` → category
- 18:32:50 `bookmark_created` (from the CATEGORY list — saved BEFORE opening detail!) → 18:32:51 slug + detail → 18:32:54 `$exception` **[ConcurrentModificationError]** (3s)
- 18:32:55 save → created → 10s → deleted → save → created → 10s → deleted → save → created → 18:33:39 health-refresh → deleted → 18:34:16 bg, end

## What the user does
Rare search-led session: /search ×3 → detail → the full save-thrash cycle (4 creates / 3 deletes / 3 saves in 45s) → health check → delete → leave.

## Weird moment
The pre-detail `bookmark_created` (18:32:50, one second BEFORE the detail view): quick-save from the category card WORKS — then the detail page's own toggle thrashes. Same backend, two affordances, opposite outcomes. The bug is in the detail-page toggle state, not the save pipeline.

## Delays
95s inactive (34%) — normal reading rhythm between bursts.

## Emotion arc
Hope (search worked! found it!) → friction (can't cleanly keep it) → gave up via health-check + final delete. A search win poisoned by the toggle.

## Improvements
1. Protect search wins first: the save toggle on search-sourced details is the highest-leverage fix location — this session proves discovery works and retention fails.
2. Clone the card quick-save behavior onto the detail toggle (it succeeded where detail failed 60s later).
3. Log the query that led here; replicate successful-search patterns in empty-state suggestions.
