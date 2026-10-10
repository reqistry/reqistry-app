# 01a0f848-e9d6-7ccd-acd3-9f9ad823068c
[Open replay](https://us.posthog.com/project/638414/replay/01a0f848-e9d6-7ccd-acd3-9f9ad823068c) · 2026-10-01 16:25 UTC · 8s (active 6.7s) · 6 clicks · start root · Mobile/Android · 8 events

## Timeline
- 16:25:23 `$push_notification_opened` + Opened (same ms — **push-tap entry**, the only one in the set) → root → `$set`
- 16:25:25 notifications → 16:25:26 root → 16:25:27 notifications → 16:25:32 bg, end. Two notification views + two roots in 8 seconds.

## What the user does
Taps a push notification, lands on ROOT (not the promised content), checks notifications twice with root flickers between, leaves in 8s.

## Weird moment
Push-tap → root = broken deep link. The notification promised something; the app delivered the feed. The notification↔root flicker (4 screens, 8s) reads as "where is it?" hunting before giving up.

## Delays
1s inactive. None — pure wayfinding failure at speed.

## Emotion arc
Push intent extinguished in 8 seconds. Notification promise vs payload mismatch is the fastest trust-burner in mobile.

## Improvements
1. Push deep-link routing P0: every notification type must land ON its content. Replay this one at 16:25:23 +0s to see the promised-then-missing payload.
2. If the notification's content was deleted/expired, the fallback should say so ("this update is gone") — never silent root.
