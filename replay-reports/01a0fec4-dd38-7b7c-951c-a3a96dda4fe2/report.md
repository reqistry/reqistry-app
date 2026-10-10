# 01a0fec4-dd38-7b7c-951c-a3a96dda4fe2
[Open replay](https://us.posthog.com/project/638414/replay/01a0fec4-dd38-7b7c-951c-a3a96dda4fe2) · 2026-10-02 22:38 UTC · 6s · start `reqistry.dev/#mcp` · Mobile/Android/Chrome · 2 events

## Timeline
- 22:38:31 `$pageview /` → 22:38:37 `$web_vitals` (6s later), end. No pageleave — tab killed or navigated before the leave flushed.

## What the user does
First of the #mcp triplet: 6 seconds, in and out — then tries twice more (Firefox 75s read, Chrome 46s). The bounce that started a 4-minute retry loop.

## Weird moment
No `$pageleave` where sibling `…c6` fired one: the exit was abrupt (tab close / back-swipe mid-load). First impression failed before vitals even settled.

## Delays
None — instant verdict.

## Emotion arc
"That's not it" → but intent strong enough to retry twice more, switching browsers. High-value docs visitor failed by first paint.

## Improvements
1. First-paint audit of #mcp on mobile Chrome: what renders in the first 6s? If it's nav + hero with the content below the fold, the bounce is a layout verdict, not a content verdict.
2. Stitch the triplet in analytics (one human, three sids) before counting docs traffic.
