# 01a0f8ce-89d3-7b6a-b898-b3bac3e4d678
[Open replay](https://us.posthog.com/project/638414/replay/01a0f8ce-89d3-7b6a-b898-b3bac3e4d678) · 2026-10-01 18:51–19:02 UTC · 684s (active 492s) · 212 clicks · start `/auth` · Mobile/Android · 78 events, 58 screens, ZERO details, ZERO saves

## Timeline
- 18:51:22 Installed → Opened → `/auth` → 18:51:52 bg (30s) → back → `$identify` → root
- 18:52:06 `$exception` **[ConcurrentModificationError]** @root (7s) → projects → root → projects ×4 (one 32s gap)
- 18:53:44 submit → root → category → root → 18:53:57 `$exception` **[StateError]** @root (the emit-after-close family)
- 18:54:05 root → watchlists ×4 → root → notifications → root ×3 → watchlists → root
- 18:57:45 bg → back → root → `$set` → projects → root → bg → back → root → submit → root → bg → back → root ×3 → projects → root → projects → root → compare → bg → back → compare ×2 → bg → back → root → compare → root → projects → root → bg → back → root ×2 → search ×2 (19:01:10–19:01:30) → root → account ×2 → root → submissions → submit (end)

## What the user does
The great wanderer: 11 minutes, 58 screens, 212 clicks — never opens a single API. Root ×29, projects ×9, watchlists ×5, compare ×4, two searches at minute 10 that also convert to nothing, ends on submit-api (going to contribute after failing to consume?).

## Weird moment
29 root views = pull-to-refresh spam or root↔tab oscillation every ~20s. 212 clicks → 0 details is the dataset's worst conversion. Post-crash (two exceptions by minute 3) the feed may have rendered empty for them — filter stuck? Either cards are untappable or the feed is broken for this account state.

## Delays
192s inactive + 7 backgroundings — interrupted repeatedly, possibly by the confusion itself.

## Emotion arc
Lost. No rage (nothing TO delete) — circling for 11 minutes, then a pivot to submit. Quiet-quit risk that instead became a contribution attempt; don't waste that pivot.

## Improvements
1. P0: replay this one visually. If feed renders empty for some filter/account state, that's a showstopper hiding in plain sight.
2. After 3 root returns with no detail, push a recommended API card inline — never let a user see 29 roots with 0 details.
3. Honor the submit pivot: if they opened submit-api at 19:02:00, pre-fill/recognize the effort next open.
