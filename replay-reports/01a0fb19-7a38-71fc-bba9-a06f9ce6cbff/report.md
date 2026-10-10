# 01a0fb19-7a38-71fc-bba9-a06f9ce6cbff
[Open replay](https://us.posthog.com/project/638414/replay/01a0fb19-7a38-71fc-bba9-a06f9ce6cbff) · 2026-10-02 05:32–05:58 UTC · 1556s (26 min, active 370s) · 242 clicks · start root · Mobile/Android · 42 events

## Timeline
- 05:32:26 Opened (returning user) → root → `$set` → category↔root ping-pong ×4 (05:32:54–05:34:07, ~15s rhythm)
- 05:34:42 bg → **16-min gap** → 05:50:30 back → category → 05:51:08 slug + detail (first detail after 18 min!)
- 05:51:12 `$exception` **[ConcurrentModificationError]** @slug (4s after detail)
- 05:52:10 bg (58s) → back → health-refresh → outbound doc → bg → back
- 05:54:04–05:58:19 category↔root ×12 more (13 category screens total), recommended once, bg, end. Zero saves.

## What the user does
Second marathon: 26 min, 13 category screens, ONE detail view. Reads its health + docs, then grazes categories to the end.

## Weird moment
13:1 category-to-detail ratio with the single detail arriving after 18 minutes of ping-pong + a 16-min phone-down gap. Either categories are interesting but contents disappoint on open, or detail entry from category rows is unclear — and the ONE detail that did open crashed 4s later, yet the user still refreshed its health and opened its docs. Maximum persistence, minimum reward.

## Delays
1186s inactive (76%) — the 16-min phone-down + slow grazing pace. 05:32–05:58 (night hours?) — tired browsing compounds it.

## Emotion arc
Grazing, low urgency, no rage — but also no value captured in 26 min. The crash 4s into the only detail could have ended it; instead they read on. Loyal grazer, unconverted.

## Improvements
1. Category→detail CTR is the metric (13:1 here): previews + inline save inside category rows so grazers convert without committing to a page.
2. Night readability/dark-mode contrast check on category screens.
3. The 16-min-gap return landed on root, not back on the category — restore pre-background screen; return-state worked for `…06` and failed here by luck of the draw.
