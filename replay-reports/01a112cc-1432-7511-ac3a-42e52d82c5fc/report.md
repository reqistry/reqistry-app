# 01a112cc-1432-7511-ac3a-42e52d82c5fc
[Open replay](https://us.posthog.com/project/638414/replay/01a112cc-1432-7511-ac3a-42e52d82c5fc) · 2026-10-06 19:58–20:04 UTC · 281s (active 190s) · 84 clicks · start `/auth` · Mobile/Android · 32 events, ZERO detail views

## Timeline
- 19:58:48 Installed → Opened → `/auth` → 19:59:35 bg → back → 19:59:42 `$identify` → root
- 19:59:53 `$exception` **[ConcurrentModificationError]** @root (10s after root)
- 19:59:57–20:01:35 projects ×4 with an 88s stall mid-loop (reading a project, or stuck list)
- 20:01:36 root → submit → root → submissions → submit → root (submit↔submissions flip — checking status?)
- 20:02:17 account ×2 → root → projects → root → watchlists ×2 → root
- 20:03:15 `/search` → 20:03:16 root (**1.5 seconds** — search opened and instantly closed: mis-tap or empty-search scare) → 20:04:00 bg, end

## What the user does
Same human as `…76be` (30s apart, likely reinstall/second tab): configures everything — projects, submit, submissions, account, watchlists, search-peek — opens zero APIs.

## Weird moment
The 1.5s search open/close is a micro-signal: either an accidental tap (then touch targets are too easy to hit) or search opened empty/unfocused and they fled (then search first-run state is broken).

## Delays
91s inactive (32%) — mild; the 88s projects stall is the only long read.

## Emotion arc
Setup diligence, no rage, no payoff. Account ×2 mid-flow hints at profile friction.

## Improvements
1. Instrument the 1.5s-search pattern globally — if common, search entry is misfiring.
2. Card-tap success rate on root: 84 clicks → 0 details here vs 1 detail next door (`…76be`). Same human, opposite outcomes 30s apart = the difference is one discoverable affordance.
