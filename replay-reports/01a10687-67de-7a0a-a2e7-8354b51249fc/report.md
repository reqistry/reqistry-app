# 01a10687-67de-7a0a-a2e7-8354b51249fc
[Open replay](https://us.posthog.com/project/638414/replay/01a10687-67de-7a0a-a2e7-8354b51249fc) · 2026-10-04 10:48–11:03 UTC · 512s (active 125s) · 17 clicks · start `…/bank-negara-malaysia-open-data` · Desktop/Windows/Chrome · 31 web events

## Timeline
- 10:48:20 pageview bank-negara → vitals (first touch, then **11-min gap** — tab parked immediately)
- 10:59:33 pageview bank-negara (return) → vitals → autocapture → /categories
- 11:00:01 commerce → /categories → vitals → business (+2 autocaptures — reading) → /categories
- 11:01:51 `$dead_click` @/categories → travel → airbnb-api (+3 autocaptures — deep read)
- 11:02:50 /categories → cloud-infrastructure → `$dead_click` @aws-apigateway-api link → navigated anyway 3s later → aws page → vitals, end

## What the user does
The only true web-category browser: niche API entry (Bank Negara Malaysia Open Data, likely Google) → tours commerce → business → travel (airbnb deep read) → cloud-infra (aws). Category-led discovery working as designed. No search, no save.

## Weird moment
Two `$dead_click`s (categories page, aws API link) — the aws one self-healed (navigated 3s later via another control), so the dead element is a redundant/overlapping tap target, not a dead end. The 11-min park between first and second bank-negara view = tab-as-bookmark.

## Delays
387s inactive (76%) — slow deliberate reading, not app delay.

## Emotion arc
Curious explorer, zero frustration despite 2 dead clicks (both recovered). No saves only because web has no save parity.

## Improvements
1. Web bookmark/save parity (or login nudge) — this intent evaporated into a parked tab.
2. Fix the double-tap-target on category cards + API links (dead_click with recovery = overlapping handlers).
3. Cross-category rails ("travel × commerce") — this user already walks them manually.
