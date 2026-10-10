# 01a0f6e7-815e-72b1-9234-428f9e566da2
[Open replay](https://us.posthog.com/project/638414/replay/01a0f6e7-815e-72b1-9234-428f9e566da2) · 2026-10-01 09:59 UTC · 9s (active 8.4s, score 69) · 2 clicks · start `reqistry.dev/` · Desktop/Windows/Edge · 5 events

## Timeline
- 09:59:22 `$pageview /` → 09:59:23 `$dead_click` (1.5s) → 09:59:27 `$web_vitals` → 09:59:30 `$autocapture` → 09:59:31 `$pageview /categories/open-data` (recovered 8s after the misfire)

## What the user does
Brisk homepage check that misfires then self-rescues: dead click at 1.5s, finds the working control (`$autocapture` at :30), reaches open-data category at :31, done.

## Weird moment
Fifth homepage `$dead_click` — and the second recovery (with `…6c39`): same 1–2s timing, same pattern of dead-then-real control 5–8s later. The dead element sits beside (or atop) the working one.

## Delays
None.

## Emotion arc
Evaluated, misfired, recovered, moved on. The resilient twin of `…2ddc` (which didn't recover).

## Improvements
1. Same dead-element fix — now 5 sessions strong; study the :30 `$autocapture` event for the control that works and make it the only target.
2. Pair with `…2ddc`-style non-recoveries: the ONLY difference between bounce and convert here is finding the second control. Kill the first.
