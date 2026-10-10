# 01a0fb16-a40d-7785-8c90-9d1c5dd09d1b
[Open replay](https://us.posthog.com/project/638414/replay/01a0fb16-a40d-7785-8c90-9d1c5dd09d1b) · 2026-10-02 05:29–05:31 UTC · 123s (active 19s) · 17 clicks · start `/auth` · Mobile/Android · 10 events

## Timeline
- 05:29:20 `/auth` screen fires BEFORE Installed/Opened (out-of-order by ~100ms — clock skew or reinstall-over-existing)
- 05:29:20 Installed → Opened → 05:29:24 `$identify` → root
- 05:29:33 `$exception` **[ConcurrentModificationError]** @root (9s after root)
- 05:29:54 `/compare` → 05:30:10 bg (16s) → 05:31:17 back (67s later) → 05:31:38 bg, end
- Companion marathon `…b19` starts 48s after this session's last event (05:31:38 → 05:32:26 — same human, continuous)

## What the user does
Opens compare with (almost certainly) nothing in it, backgrounds twice around it, hands off to the 26-min graze session.

## Weird moment
Out-of-order first events (screen before install) + compare opened in a 10-event session with zero saves/details anywhere: empty-compare dead end. Third empty-compare in the set (`…64e5`, `…c8` loop).

## Delays
104s inactive (85%) — two background gaps (16s, 67s).

## Emotion arc
Poke-around then settle into the long session. No frustration yet — the frustration comes later, in `…b19`'s 13:1 category grind.

## Improvements
1. Never show blank compare: seed with suggestions or teach the add-gesture inline.
2. Stitch `…b16`→`…b19` (48s apart) as one journey; the compare attempt belongs to the marathon's story.
