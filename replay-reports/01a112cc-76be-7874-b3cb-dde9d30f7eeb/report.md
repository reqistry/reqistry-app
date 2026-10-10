# 01a112cc-76be-7874-b3cb-dde9d30f7eeb
[Open replay](https://us.posthog.com/project/638414/replay/01a112cc-76be-7874-b3cb-dde9d30f7eeb) · 2026-10-06 19:59–20:03 UTC · 270s (active 40s!) · 24 clicks · start `/auth` · Mobile/Android · 25 events

## Timeline
- 19:59:13 Installed → Opened → `/auth` → 19:59:48 bg (35s auth dwell) → back → 20:00:07 `$identify` → root
- 20:00:14 `$exception` **[ConcurrentModificationError]** @root (7s after first root — the standard timing)
- 20:01:03 category → 20:01:18 slug + detail → 20:01:31 `$exception` **[ConcurrentModificationError]** @slug (13s after detail)
- 20:01:54–20:02:31 slug ×3 (reloads?) → `folder_created` → `api_project_add` → `project_api_added` (24s — **organized the API into a project, success**)
- 20:02:37 category → root → 20:03:15 projects → `projects/:id` → projects → root → submit (end)

## What the user does
The SUCCESS story: two crashes, then saves the API into a project folder anyway and goes to verify it in `projects/:id`. The project-add flow works even when the showcase flow throws.

## Weird moment
`folder_created` + `project_api_added` are the only such events in the Oct-6 cluster — this user discovered project-organization that wanderers (`…1432`, `…c8`) circled around without finding.

## Delays
230s inactive (85%) — but the active slices convert. Slow, deliberate, successful.

## Emotion arc
Patient throughout; crashes didn't deter; finished with an organized library. The anti-rage case.

## Improvements
1. Make the project-add path (`folder_created` → `api_project_add`) discoverable from the wanderer sessions — same cluster, opposite outcomes, one flow apart.
2. The 13s-detail→exception gap recurs (`…c5fc` 11s, `…967` 12s): audit what fires ~10s after detail render (delayed tour step? related-APIs fetch?).
