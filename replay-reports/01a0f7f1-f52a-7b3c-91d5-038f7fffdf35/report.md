# 01a0f7f1-f52a-7b3c-91d5-038f7fffdf35
[Open replay](https://us.posthog.com/project/638414/replay/01a0f7f1-f52a-7b3c-91d5-038f7fffdf35) · 2026-10-01 14:50 UTC · 300s wall (active 10s!) · 0 clicks · start `…/bank-negara-malaysia-open-data` · Desktop/Windows/Chrome · 3 events

## Timeline
- 14:50:25 `$pageview` bank-negara → 14:50:31 `$web_vitals` (6s) → 14:50:46 `$web_vitals` (15s later), end. Two vitals pings, zero interaction, 290s wall.

## What the user does
Opens the API page (same slug as `…49fc`), never clicks, never scrolls (no autocapture at all — compare `…49fc`'s 8 autocaptures), tab stays open 5 min.

## Weird moment
Zero autocapture across 300s: no mouse, no scroll, no key — tab opened and never focused, or a reader who never moved the mouse. Either way the "session" is parking, and vitals kept reporting a healthy page to an empty room.

## Delays
290s inactive (97%). Not friction — absence.

## Emotion arc
"Save for later" without saving — intent without the bookmark action (web has no save parity, same gap as `…49fc`).

## Improvements
1. Web save/collect parity (or "email me this link") so parked-tab intent survives.
2. Dwell-without-interaction should trigger a different metric than bounce — this 300s/0-click shape is currently indistinguishable from a 9s bounce in aggregates.
