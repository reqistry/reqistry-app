# 01a1013d-6c39-70df-a516-a60e5975c6d5
[Open replay](https://us.posthog.com/project/638414/replay/01a1013d-6c39-70df-a516-a60e5975c6d5) · 2026-10-03 10:09 UTC · 9s · start `reqistry.dev/` · Desktop/Windows/Edge · 5 events

## Timeline
- 10:09:25 `$pageview /`
- 10:09:26 `$dead_click /` (1s in)
- 10:09:30 `$web_vitals` → `$autocapture` → 10:09:33 `$pageview /categories/open-data` (recovered via another control 7s after the misfire)

## What the user does
Same dead click as twin `…2ddc`, but recovers: finds another path to `/categories/open-data` 7s later. The only dead-click session site-wide that converts onward.

## Weird moment
The recovery proves the dead element is redundant (a second control reaches the same place) — likely overlapping handlers where one fires and the other doesn't, depending on click coordinates.

## Delays
None.

## Emotion arc
Micro-frustration → self-rescue. Resilient clicker.

## Improvements
1. Same dead-element fix; study THIS session's recovery click (the `$autocapture` at 10:09:30) — that's the control that works. Make it the only one.
2. Stitch the twin pair; report as 1 human, 2 sessions, 1 recovery.
