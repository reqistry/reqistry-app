# 01a1166c-9101-765e-936e-fee5f7825144
[Open replay](https://us.posthog.com/project/638414/replay/01a1166c-9101-765e-936e-fee5f7825144) · 2026-10-07 12:52 UTC · 31s (active 3s) · 2 clicks · start `reqistry.dev/` · Desktop/Linux/Chrome · 3 events

## Timeline
- 12:52:56 `$pageview /`
- 12:52:56 `$dead_click /` (same second — **first click landed on a dead element**)
- 12:53:01 `$web_vitals /`, then 28s idle, end.

## What the user does
Lands on homepage, immediately clicks something that does nothing, idles, leaves.

## Weird moment
The `$dead_click` in the same second as pageview: the very first interaction with the homepage misfired. Same signature on all three Oct-7 homepage sessions (`…5144`, `…91af`, `…5598`) and the Oct-3 Edge pair — this is a homepage element that looks clickable and isn't (likely a hero CTA / card with no handler on first paint).

## Delays
28s inactive — tab parked, not app delay.

## Emotion arc
Click → nothing → disengage. Micro-frustration, low stakes.

## Improvements
1. Find the dead element on `/` (replay at 12:52:56 +0s) and either wire it or remove the affordance. Five sessions across 4 days share this signature.
2. Don't double-count the `…5144`/`…91af` pair (41s apart, same UA) as two humans.
