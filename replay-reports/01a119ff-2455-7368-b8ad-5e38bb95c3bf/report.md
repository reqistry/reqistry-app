# 01a119ff-2455-7368-b8ad-5e38bb95c3bf
[Open replay](https://us.posthog.com/project/638414/replay/01a119ff-2455-7368-b8ad-5e38bb95c3bf) · 2026-10-08 05:31 UTC · 4s · 0 clicks · start `reqistry.dev/#mcp` · Mobile/Android/Chrome · 1 event (`$pageview /`)

## Timeline
- 05:31:54 `$pageview /` — a single pageview, no vitals, no autocapture, no pageleave. 4 seconds, gone.

## What the user does
Deep link to `#mcp`, bounces instantly. No scroll, no click captured.

## Weird moment
No `$pageleave` fired (compare `01a0fec6`, which did fire pageleave after 75s of reading). Either the tab died instantly or the anchor never resolved and they killed it.

## Delays
None — verdict in 4s.

## Emotion arc
"Wrong place" snap judgment. Docs-seeking intent, immediate abandon.

## Improvements
1. Verify the `#mcp` anchor resolves on mobile Chrome (it drew 3 more visits Oct 2 — the triplet — with mixed results).
2. Add a TL;DR + copy-paste MCP snippet above the fold so even a 4s visit can convert.
