# 01a0fec0-c50f-7753-bb59-d6fcf8d8231d
[Open replay](https://us.posthog.com/project/638414/replay/01a0fec0-c50f-7753-bb59-d6fcf8d8231d) · 2026-10-02 22:34–22:43 UTC · 568s (active 132s) · 77 clicks · start `/auth` · Mobile/Android · 19 events

## Timeline
- 22:34:01 Installed → Opened → `/auth` → `$identify` → root (clean login)
- 22:34:49 bg (38s) → 22:36:14 back (84s later) → `$exception` **[ConcurrentModificationError]** @root
- 22:37:21 app-settings (67s) → root → root → 22:38:16 `$exception` **[ConcurrentModificationError]** @root
- 22:38:27 bg → **4-min gap** → 22:42:12 back → projects → root → latest → root → bg, end

## What the user does
Pre-docs app session: logs in, tours root/settings, eats 2 crashes — then the 4-min background gap (22:38:27→22:42:12) EXACTLY covers the #mcp web triplet (22:38:31, 22:39:46, 22:41:18). App failed → went to web docs (3 loads, 2 browsers) → came back → poked projects/latest → left.

## Weird moment
The cross-surface stitch: one human, one evening, one job (MCP setup?), failed in BOTH surfaces. The app's two crashes at 22:36 and 22:38 bracket the docs attempt — frustration in the app drove the docs hunt.

## Delays
436s inactive (77%) — dominated by the 4-min docs detour + slow strolls.

## Emotion arc
Slow deflation across two surfaces. No rage burst — worse: quiet double-churn. Never returned after Oct 2 (check retention for this distinct_id).

## Improvements
1. Trace this distinct_id across app+web and fix THAT job end-to-end (whatever MCP setup step they needed).
2. App-settings visit (67s) with no change event = settings confusion; audit what settings promises vs delivers.
3. Respond to double-failure evenings: if a user hits exceptions then docs within minutes, that's a rescue-opportunity push ("stuck? here's the guide") — or at minimum, don't count them as two users.
