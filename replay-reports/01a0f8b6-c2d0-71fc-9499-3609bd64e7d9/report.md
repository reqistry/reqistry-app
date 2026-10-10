# 01a0f8b6-c2d0-71fc-9499-3609bd64e7d9
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8b6-c2d0-71fc-9499-3609bd64e7d9) · 2026-10-01 18:25–18:28 UTC · 245s (active 25s!) · 9 clicks · start `/auth` · Mobile/Android · 12 events

## Timeline
- 18:25:24 Installed → Opened → `/auth` → 18:25:57 bg (33s) → 18:26:40 back (**43s gap on /auth** — slow login or auth confusion) → 18:27:42 `$identify` (62s after first auth!)
- 18:27:42 root → 18:27:48 `$exception` **[ConcurrentModificationError]** (6s) → 18:28:20 category (32s) → 18:28:36 slug + detail → 18:28:44 `$exception` **[ConcurrentModificationError]** (8s), end

## What the user does
Slow login (62s on auth across a background gap), one category browse (32s), one detail, crash, end. Minimal session, maximal signal about auth.

## Weird moment
62 seconds from first `/auth` to `$identify` with a background gap in the middle: OTP/email-code wait? Password reset? The 43s backgrounded auth = left the app to fetch a code (email/SMS) and came back. Auth-by-code with no "waiting" state.

## Delays
220s inactive (90%) — auth wait dominates. The 2 exceptions (6s, 8s after render) are the standard timing.

## Emotion arc
Patient (waited out a 62s login) → brief browse → crash → done. No thrash — never got far enough.

## Improvements
1. Auth needs a waiting/progress state for code-based flows + "resend" visibility — 62s of dead auth screen is where installs die.
2. Silent background exceptions while reading (2 here, user saw nothing) are tech-debt interest — fix fetch-while-reading paths regardless.
3. Scroll-depth on slug pages to separate readers from stuck (90% idle is ambiguous).
