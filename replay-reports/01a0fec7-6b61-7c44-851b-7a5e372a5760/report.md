# 01a0fec7-6b61-7c44-851b-7a5e372a5760
[Open replay](https://us.posthog.com/project/638414/replay/01a0fec7-6b61-7c44-851b-7a5e372a5760) · 2026-10-02 22:41 UTC · 46s (active 8s) · 0 clicks · start `reqistry.dev/#mcp` · Mobile/Android/Chrome · 3 events

## Timeline
- 22:41:18 `$pageview /` → 22:41:23 `$web_vitals` → 22:42:06 `$web_vitals` (second vitals ping 43s later — page alive, being read or re-measured)

## What the user does
Third of the #mcp triplet (22:38 → 22:39 → 22:41, Chrome/Firefox/Chrome): opens #mcp, 8 mouse moves, no clicks, 38s, out.

## Weird moment
The triplet + the app session `…fec0` (whose 4-min background gap exactly covers the triplet window): app failed them at 22:38 → tried docs 3× across 2 browsers → came back to the app at 22:42. Cross-surface perseverance for ONE job (MCP setup?).

## Delays
38s on-page — reading or waiting on render. Vitals fired twice, so the page was alive.

## Emotion arc
Docs-hunting persistence bordering on stubbornness (3 loads). Browsers switched mid-hunt ("maybe Firefox renders it").

## Improvements
1. Cross-browser test #mcp on mobile Chrome vs Firefox — the browser switch mid-hunt says one of them renders badly.
2. Highest-priority docs fix in the set: a user tried THREE times to read this page. Find what they wanted and put it above the fold.
