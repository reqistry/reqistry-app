# 01a0f8bd-5617-711d-8aee-c7f815147e6a
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8bd-5617-711d-8aee-c7f815147e6a) · 2026-10-01 18:32–18:34 UTC · 151s (active 79s) · 32 clicks · start `/auth` · Mobile/Android · 16 events

## Timeline
- 18:32:34 Installed → Opened → `/auth` → 18:33:11 bg (36s auth dwell) → back → `$identify` → root
- 18:33:27 `$exception` **[ConcurrentModificationError]** @root (9s)
- 18:33:29 projects → root → 18:33:48 submit → root → 18:34:10 submit (reopened 22s later) → root → account ×2 (18:34:19–18:34:32), end

## What the user does
Would-be contributor: submit-api opened TWICE with a root visit between (open → back out → reopen → back out), then drifts to account settings. Never reaches a submit confirmation.

## Weird moment
Submit×2 with retreats both times and no `/submissions` screen after: started submitting twice, finished zero times. The funnel leak is at entry/commitment, not at a form error (no field events to show where).

## Delays
72s inactive — form-contemplation pauses (36s auth dwell + gaps around submit).

## Emotion arc
Intent → hesitation → deflection to settings. The most expensive drop in the set (supply-side user lost).

## Improvements
1. Replay the two submit entries frame-by-frame: what does submit-api show a first-timer? Auth wall? Empty form? Login-gated submit after a 36s auth dwell smells like an auth loop.
2. Save submit drafts + "finish submitting?" re-prompt on next open — catch the next `…8bd` before they deflect.
