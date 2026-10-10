# 01a0f8b1-8a0e-7074-b0c5-c7150e8c5fc3
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8b1-8a0e-7074-b0c5-c7150e8c5fc3) · 2026-10-01 18:19–18:24 UTC · 256s (active 187s) · 102 clicks · start `/auth` · Mobile/Android · 43 events, 32 screens, ZERO details

## Timeline
- 18:19:41 Installed → Opened → `/auth` → 18:20:15 bg (33s) → back → `$identify` → root
- 18:20:26 `$exception` **[ConcurrentModificationError]** (5s) → projects → root → projects ×4 (18:20:38–18:21:38, 60s loop)
- 18:21:40 root ×2 → submit → root → category → root → 18:22:15 `$exception` **[StateError]** (the emit-after-close family, 2nd of only 2 in the set)
- 18:22:24 root → watchlists ×3 → root → projects → root → submissions → submit → submissions → root → notifications → root ×2 → account ×2 → root → bg → back → root → `$set` → bg, end

## What the user does
Prequel to `…8b3`/`…8b6` (same 18:19–18:28 cluster, same human, first of three): 32 screens of pure setup — projects, watchlists, submit, submissions, settings — zero content. Nesting before hunting.

## Weird moment
Two DIFFERENT exception types in one session (ConcurrentModification + StateError): the showcase race AND the cubit race both bit the same user 2 minutes apart. And 102 clicks → 0 details while the very next session (`…8b3`, 7 min later) converts searches to details — same human, setup-mode vs consume-mode.

## Delays
69s inactive only — fast, purposeful circling. No stalls.

## Emotion arc
Nesting instinct: preparing projects/watchlists BEFORE having anything to put in them. No frustration — but onboarding that lets setup run 32 screens deep before value is upside-down.

## Improvements
1. Invert the funnel: first-run lands on content with one-tap save-to-default-watchlist; organization comes second.
2. Read the trilogy (`…8fc3` → `…42f8` → `…e7d9`, 18:19→18:28) as ONE 9-minute journey across 3 sids — and fix whatever splits sessions here (auth refresh? process death?).
