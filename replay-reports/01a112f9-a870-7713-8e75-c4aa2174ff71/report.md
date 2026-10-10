# 01a112f9-a870-7713-8e75-c4aa2174ff71
[Open replay](https://us.posthog.com/project/638414/replay/01a112f9-a870-7713-8e75-c4aa2174ff71) · 2026-10-06 20:48 UTC · 1s · 0 clicks, 4 keypresses · start `reqistry.dev/` · Desktop/Linux/Chrome · 1 event (`$pageview /`)

## Timeline
- 20:48:36 single `$pageview`. No vitals, no autocapture, no pageleave. Four keypresses (a chord — Ctrl+W/Ctrl+T class) and the tab died within the same second.

## What the user does
Opens homepage, closes it via keyboard in <1s. Accidental open, or "nope" at first paint.

## Weird moment
Keypress-without-click on a 1s visit: the close chord raced the page load.

## Delays
None.

## Emotion arc
None — noise. (Pairs with `01a0f8d5` as the dataset's two keyboard-close phantoms.)

## Improvements
1. Exclude sub-2s single-pageview sessions from engagement denominators; they're tab accidents, and there are at least 2 of 46 here (~4%).
