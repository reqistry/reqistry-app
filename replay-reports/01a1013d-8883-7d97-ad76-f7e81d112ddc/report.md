# 01a1013d-8883-7d97-ad76-f7e81d112ddc
[Open replay](https://us.posthog.com/project/638414/replay/01a1013d-8883-7d97-ad76-f7e81d112ddc) · 2026-10-03 10:09 UTC · 9s · start `reqistry.dev/` · Desktop/Windows/Edge · 3 events

## Timeline
- 10:09:32 `$pageview /`
- 10:09:34 `$dead_click /` (2s in)
- 10:09:37 `$web_vitals`, end. Twin `…6c39` started 7s earlier with the same shape.

## What the user does
Homepage → dead click → vitals → gone. Same element, same outcome as the Linux pair.

## Weird moment
The pair structure (same `01a1013d` prefix, 7s apart, Edge): one actor, two tabs/sessions. Twin `…6c39` went on to `/categories/open-data`; this one didn't — same dead click, divergent recoveries.

## Delays
None.

## Emotion arc
None individually — but as a pair: tried twice, one path recovered, one didn't.

## Improvements
1. Same dead-element fix (now 5 sessions, 2 OSs, 2 browsers — shipped-broken control).
2. Check for synthetic-monitor signature (Edge + sub-10s + pairs = uptime checker?) before counting these as human bounces.
