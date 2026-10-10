# 01a120e9-1b71-73ba-bbbf-094249da2840
[Open replay](https://us.posthog.com/project/638414/replay/01a120e9-1b71-73ba-bbbf-094249da2840) · 2026-10-09 13:45 UTC · 126s (active 26s / inactive 100s) · 13 clicks · start `/auth` · Mobile/Android (Flutter) · 7 events

## Timeline
- 13:45:09 Installed → Opened (same second — fresh install)
- 13:45:44 `/auth` screen (35s gap — onboarding/auth screen dwell)
- 13:45:54 `$identify` → root (login completes in 10s, healthy)
- 13:46:09 `$exception` **[ConcurrentModificationError]** — 15s after first root, the showcase-tour crash
- 13:46:46 root again, recording ends

## What the user does
Fresh install → auth → login OK → hits root → crash → one more root view → gone. Textbook first-run-killed-by-tour.

## Weird moment
The bug is still live on Oct 9 (newest session in the set): 9 days after the first recorded instance (Oct 1), same `ConcurrentModificationError`, same 5–15s-after-root timing, same showcaseview frames. Zero evidence of a fix in the observation window.

## Delays
100s inactive of 126 (79%) — auth dwell (35s) + post-crash stall. Login itself was fast (10s).

## Emotion arc
Hopeful (new install, smooth login) → confused (tour glitches/crashes 15s in) → gone. No rage — never got attached.

## Improvements
1. Kill the showcase tour or guard `_changeSequence` with a list copy — this exact crash now spans Oct 1→9 across 20+ sessions.
2. First-root experience must survive the tour dying: if showcase throws, fall back to plain root, never blank/half-overlay.
