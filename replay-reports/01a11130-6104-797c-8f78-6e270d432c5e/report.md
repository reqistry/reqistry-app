# 01a11130-6104-797c-8f78-6e270d432c5e
[Open replay](https://us.posthog.com/project/638414/replay/01a11130-6104-797c-8f78-6e270d432c5e) · 2026-10-06 12:29 UTC · 4s active, 8s wall · start `…/apis/exa-search-api` · Desktop/Firefox · 2 events

## Timeline
- 12:29:06 `$pageview /apis/exa-search-api` (deep link, likely Google/LLM)
- 12:29:14 `$pageleave /apis/exa-search-api` (7.5s later). Clean exit, no dead click, no vitals.

## What the user does
Deep-links to one API page, reads ~7s, leaves. No second page.

## Weird moment
A clean pageleave (not a rage-close): the page rendered, the verdict took 7 seconds. Title/summary didn't match the query intent.

## Delays
None.

## Emotion arc
"Wrong answer" snap judgment — but polite (full read of above-the-fold, then leave).

## Improvements
1. Check this slug's SEO/social-card metadata — deep-link visitors decide in <8s on title + first paint.
2. Related-APIs module: even a mismatched landing should convert to a second page; this one had zero.
