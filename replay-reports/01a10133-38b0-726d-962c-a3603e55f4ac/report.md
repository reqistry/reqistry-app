# 01a10133-38b0-726d-962c-a3603e55f4ac
[Open replay](https://us.posthog.com/project/638414/replay/01a10133-38b0-726d-962c-a3603e55f4ac) · 2026-10-03 09:58 UTC · 9s wall, 0s active · start `reqistry.dev/` · Desktop/Linux/Chrome · 5 events

## Timeline
- 09:58:16 `$pageview /` → 09:58:22 `$web_vitals`
- 09:58:27 `$pageview /contact` → `$pageleave /` + `$pageleave /contact` (both at :27–:29). Two pageleaves = two tabs closing, or a leave fired per history entry.

## What the user does
The ONLY `/contact` visit in the set: homepage 11s → contact page ~2s → close. Looking for a human/support channel, didn't find reason to stay.

## Weird moment
activity_score 0 with 5 events — never focused the tab, or prerender. A ghost visit that still managed to be the sole contact-page data point.

## Delays
None.

## Emotion arc
Support-seeking, unmet. Low stakes, but contact-page visits are high-intent by definition.

## Improvements
1. The contact page got 2 seconds from its only visitor — audit what it offers (form? email? nothing?). A contact page that converts nobody is worse than none (it advertises unreachability).
2. Filter zero-activity replays from UX metrics; keep for performance.
