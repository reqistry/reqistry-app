# 01a109d0-ba42-7f01-a161-2c0a730058b3
[Open replay](https://us.posthog.com/project/638414/replay/01a109d0-ba42-7f01-a161-2c0a730058b3) · 2026-10-05 02:07 UTC · 1s active, 27s wall · start (null) · Mobile/Android · 3 events

## Timeline
- 02:07:17 Installed → Opened (same second)
- 02:07:44 Backgrounded (27s later — but 0 screens, 0 clicks captured in between)

## What the user does
Installs at 2am, opens, backgrounds within half a minute with no captured screen. Notification tap, OS restore, or pocket launch.

## Weird moment
start_url null + zero screens: cold open with no first frame. Either the app never painted (slow cold start at 2am?) or the session captured chrome without content.

## Delays
27s of nothing — if the app was showing a splash/loader that long, that's the story.

## Emotion arc
None — pocket dial. (Only overnight session in the set.)

## Improvements
1. If notification-tap cold opens produce 1s/0-screen sessions, the deep link is broken — check what (if anything) fired the 02:07 tap.
2. Cold-start timing: 27s to background with no screen event deserves one look at startup traces for this build.
