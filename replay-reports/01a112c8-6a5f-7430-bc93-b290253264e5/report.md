# 01a112c8-6a5f-7430-bc93-b290253264e5
[Open replay](https://us.posthog.com/project/638414/replay/01a112c8-6a5f-7430-bc93-b290253264e5) · 2026-10-06 19:54–19:59 UTC · 268s (active 175s) · 90 clicks · start `/auth` · Mobile/Android · 35 events

## Timeline
- 19:54:48 Installed → Opened → `/auth` → 19:55:20 bg (31s) → back → `$identify` → root
- 19:55:33 `$exception` **[ConcurrentModificationError]** @root (6s after first root)
- 19:55:34–19:56:48 projects ×5 with root interleaved (stuck loop: 5 project views in 74s)
- 19:56:49 root ×2 → submit → root → category → root ×2 → watchlists ×3 → root
- 19:58:15 compare → root → compare ×2 → 19:58:49 bg → back → root → `$set` → projects → 19:59:38 bg, end

## What the user does
Third sibling in the 19:54–20:04 cluster: organizes — projects loop, watchlists, compare ×3 — opens zero APIs.

## Weird moment
projects ×5 in 74s right after the root exception: list likely not loading (or loading state indistinguishable from loaded), user re-enters hoping for content. Compare ×3 with zero details = comparing from lists, or empty-tray dead end.

## Delays
93s inactive; 3 backgroundings — interrupted session.

## Emotion arc
Methodical, calm. No thrash — but also no value. Circling containers.

## Improvements
1. Projects list needs visible loading vs loaded vs empty states — 5 re-entries in 74s is a loading-ambiguity signature.
2. Compare needs a first-run empty state routing INTO content; stitch this trilogy (`…64e5`/`…7eeb`/`…c5fc`, 10 min) as one journey before funnel math.
