# 01a0f8bf-15c2-7d99-9b2d-a2a198d0b911
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8bf-15c2-7d99-9b2d-a2a198d0b911) · 2026-10-01 18:34–18:38 UTC · 263s (active 31s!) · 16 clicks · start `/auth` · Mobile/Android · 11 events

## Timeline
- 18:34:29 Installed → Opened → `/auth` → 18:35:00 bg (30s) → back → `$identify` → root
- 18:35:20 `$exception` **[ConcurrentModificationError]** @root (8s)
- **3-minute silence** → 18:38:27 root → `folder_created` (created a folder after 3 min idle!) → 18:38:46 category, end

## What the user does
Sibling of the clean session (same minute, same prefix — same human, second install/session): logs in, crashes, parks 3 minutes, returns, creates a folder, heads to categories.

## Weird moment
`folder_created` after 3 minutes of silence: the user came BACK with a plan (organize first, then browse). Intent survived a crash + a 3-min gap — then the recording ends on category entry, outcome unknown.

## Delays
232s inactive (88%) — the session IS the gap plus two 30s bookends.

## Emotion arc
Crash → park → return with purpose. Resilience, not rage.

## Improvements
1. Stitch with `…8051` (27s apart): one human, two sids — the folder created HERE is the organization the clean session was circling. Together they tell one setup story.
2. Post-crash return landing: they came back to root and built a folder — good. Ensure crash recovery always restores context (this time it did).
