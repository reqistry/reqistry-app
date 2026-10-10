# 01a1166b-f03e-7231-987e-4d91b00291af
[Open replay](https://us.posthog.com/project/638414/replay/01a1166b-f03e-7231-987e-4d91b00291af) · 2026-10-07 12:52 UTC · 16s (active 3s) · 1 click · start `reqistry.dev/` · Desktop/Linux/Chrome · 3 events

## Timeline
- 12:52:15 `$pageview /`
- 12:52:17 `$dead_click /` (2s in — same dead element as twin `…5144`)
- 12:52:20 `$web_vitals`, 13s idle, end.

## What the user does
Identical to twin `…5144` 41 seconds earlier: homepage → instant dead click → idle → gone.

## Weird moment
Two sids, same `01a1166*` prefix, same page, same dead click, 41s apart — one human, two tabs (or reload that minted a new session). The dead click reproduced twice for the same person.

## Delays
None in-app.

## Emotion arc
Tried twice, misfired twice, left. Quiet homepage churn.

## Improvements
1. Same dead-element fix as `…5144` — this pair proves it bites repeat visitors too.
2. Stitch tab-pairs before computing bounce rate; this is 1 frustrated human, not 2 bounces.
