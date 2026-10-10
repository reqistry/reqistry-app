# 01a0f967-96f6-7531-ae20-186ca9a2f9b8
[Open replay](https://us.posthog.com/project/638414/replay/01a0f967-96f6-7531-ae20-186ca9a2f9b8) · 2026-10-01 21:38–21:45 UTC · 434s (active 353s — 81%, densest in set) · 135 clicks · start `/auth` · Mobile/Android · 39 events

## Timeline
- 21:38:31 Installed → Opened → `/auth` → `$identify` → root (4s — fastest login in the set)
- 21:38:45 bg → back (1s!) → `$set` → 21:38:49 `$exception` **[ConcurrentModificationError]** @root (14s after first root)
- 21:39:00 bg → back → root → 21:39:04 category → **68s stall** → 21:40:12 root → recommended → 65s stall → root → projects → root ×2
- 21:41:56 bg → back → root → 21:42:03 slug + detail → 21:42:15 `$exception` **[ConcurrentModificationError]** @slug (12s after detail)
- 21:42:18 slug → 21:42:55 slug + **`api_detail_issue_reported`** (40s after the 2nd crash — deliberated, then reported)
- 21:43:14 root → slug + detail → root → slug + detail → root → recommended → 78s → root → latest, end

## What the user does
Fastest login → two crashes → keeps going through category/recommended/projects → 3 details → files an issue report → keeps browsing latest. The most ACTIVE session (81%) and a reporter.

## Weird moment
Second `api_detail_issue_reported` in the dataset. The 40s deliberation between crash #2 and the report = reproduced the problem, then wrote it up. Hero-user behavior after the app crashed on them twice in 4 minutes.

## Delays
Only 81s inactive — no waiting anywhere. Friction is functional (errors), never performance.

## Emotion arc
Engaged → blocked → constructive (reported!) → continued browsing. The ideal citizen-developer arc — do not waste it with a silent issue form.

## Improvements
1. Read BOTH issue payloads (`…9b8` + deep-dive `…ec38` 20:37:22) together — pattern-match the complaint; reporters describe the same wall twice.
2. Confirm-receipt + follow-up on issue reports; silent forms kill the only users who tell you the truth.
3. The 68s/65s category/recommended stalls mirror wanderer sessions — category rows need inline previews so stalls convert.
