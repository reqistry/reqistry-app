# 01a11013-b27b-71f7-b2d3-1e0f757e7d03 — MARATHON
[Open replay](https://us.posthog.com/project/638414/replay/01a11013-b27b-71f7-b2d3-1e0f757e7d03) · 2026-10-06 07:18–08:25 UTC · 4033s (67 min, active 1834s) · 1178 clicks · start `/auth` · Mobile/Android · 592 events

## Timeline (10-min buckets)
- 07:10 — 8 evts, 1 exc **[ConcurrentModificationError]** (07:18:42), warm-up
- 07:20 — 93 evts, **20 details**, 1 exc, 1 bg — full speed by minute 2
- 07:30 — 24 evts, 5 details, 2 bg — breather
- 07:40 — 161 evts, **34 details**, 7 bmk_c — peak grind, saving while sweeping
- 07:50 — 100 evts, 20 details, 3 bmk_c, 3 bg
- 08:00 — 71 evts, 15 details, 1 exc **[_TypeError]** (08:09:44), 3 bg
- 08:10 — 108 evts, 23 details, 2 bg
- 08:20 — 27 evts, 3 details, 4 bg, ends on root — winding down
- Totals: 120 detail views, 192 slug screens, 58 category, 29 recommended, 31 alt-opened, 13 bmk_c / 0 deleted, 5 outbound, 1 search (!!)

## What the user does
The power evaluator: 120 APIs in 67 min (~1/33s sustained for over an hour), browse-driven (1 search total — categories + recommended do the work), compares 31 alternatives, cross-checks 5 docs externally, saves 13 with ZERO deletes (decisive, not thrashy).

## Weird moment
192 slug screens but 120 detail events: 72 views without a detail ping (back-button revisits? prefetch over-fire?). And the only `_TypeError` outside the save-thrash cluster lands at 08:09 mid-grind with no behavior change — swallowed error.

## Delays
2199s inactive (55%) — sustained reading pace, not stalls. Pace variance across buckets (24→161 evts) = human rhythm, not bot uniform.

## Emotion arc
Flow state for an hour, then a quiet wind-down (last bucket 27 evts, ends on root). No rage, no report — but also no conversion event captured. Decision-fatigue risk: 120 options, 31 comparisons, 13 loose saves.

## Improvements
1. Compare-tray + shortlist UX: multi-select → side-by-side → export. Give marathoners a way to FINISH.
2. "Recently viewed" rail — nobody holds 120 APIs in working memory.
3. Reconcile the 72 slug-views-without-detail gap (event definition vs navigation).
