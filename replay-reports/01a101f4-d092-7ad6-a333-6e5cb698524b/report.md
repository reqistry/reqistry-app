# 01a101f4-d092-7ad6-a333-6e5cb698524b
[Open replay](https://us.posthog.com/project/638414/replay/01a101f4-d092-7ad6-a333-6e5cb698524b) · 2026-10-03 13:29 UTC · 4s · start root · Mobile/Android · 4 events

## Timeline
- 13:29:44 Opened → root → `$set` (same second — returning user, props set)
- 13:29:48 root again (4s later), end. Two root views, 0 clicks captured.

## What the user does
Opens app, sees root twice (re-render or tab flicker), leaves in 4s. Glance-and-go.

## Weird moment
Two root screens 4s apart with no interaction: cold-start double-render, or root→something→back so fast the middle screen never flushed.

## Delays
None.

## Emotion arc
None — micro-bounce. (Returning user, so not a first-impression failure — more "checked, nothing new, closed.")

## Improvements
1. Root needs a reason-to-return for check-in opens (new/updated APIs since last visit, badged). This user found none in 4s.
2. Investigate the double-root render — if root rebuilds on every foreground, that's wasted work on every open.
