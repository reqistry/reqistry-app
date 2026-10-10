# 01a11339-f038-7a9b-8763-6fe87bc69ec2
[Open replay](https://us.posthog.com/project/638414/replay/01a11339-f038-7a9b-8763-6fe87bc69ec2) · 2026-10-06 21:58–22:09 UTC · 28s recording, events span 11 min · 27 clicks · start root · Mobile/Android · 27 events, ZERO exceptions

## Timeline
- 21:58:46 Opened (+`Application Updated` — update-driven session) → root → bg → back (7s)
- 21:58:56–21:59:12 **flicker loop**: category↔slug ×8 with 5 `api_detail_view`, one flip per ~1s (16 screen events in 16s)
- 21:59:12 root → **5-minute silence** → 22:04:16 backgrounded → 22:09:51 Opened, end

## What the user does
Update-opens-app, speed-flips 5 API details in 16 seconds (comparing cards at a glance), parks the app for 5 minutes, returns briefly, done. Zero saves, zero searches.

## Weird moment
The 1-flip-per-second rhythm for 16s straight is too regular for reading — rapid visual comparison (covers/screenshots) or accidental auto-advance. Then a 5-min park mid-root with no background event (screen-on idle, not app-switch).

## Delays
No waiting on the app — the 5-min gap is user-side parking.

## Emotion arc
Update curiosity → fast visual scan → "meh, later" park. One of the few sessions with NO exception at all — the app behaved, the content didn't hook.

## Improvements
1. Post-update sessions need a "what's new / recommended since update" hook — this user gave 16 seconds and got nothing worth saving.
2. Long-press quick-save on cards would convert flicker-loops like this (5 views, 0 saves).
