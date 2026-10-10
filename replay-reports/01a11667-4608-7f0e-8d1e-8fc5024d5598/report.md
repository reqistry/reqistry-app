# 01a11667-4608-7f0e-8d1e-8fc5024d5598
[Open replay](https://us.posthog.com/project/638414/replay/01a11667-4608-7f0e-8d1e-8fc5024d5598) · 2026-10-07 12:47 UTC · 7s (fully active, score 80) · 2 clicks · start `reqistry.dev/` · Desktop/Windows/Edge · 3 events

## Timeline
- 12:47:09 `$pageview /`
- 12:47:10 `$dead_click /` (1s in)
- 12:47:14 `$web_vitals`, end. Seven seconds, fully engaged throughout.

## What the user does
Decisive visit: lands, clicks the dead element within a second, checks vitals-pace, exits. Either "not what I wanted" or "got the link I came for."

## Weird moment
Third homepage `$dead_click` in the same family — Edge this time, so the dead element is cross-browser, not a Chrome quirk.

## Delays
None — speed is the signal.

## Emotion arc
Strong intent, fast verdict. No lingering.

## Improvements
1. Same dead-element fix; now confirmed on Chrome (Linux), Edge (Windows) — treat as shipped-broken homepage control, find it in the replay at +1s.
2. Check the 2nd click's target: if outbound (docs/GitHub), the homepage works as a directory and this session is actually a success.
