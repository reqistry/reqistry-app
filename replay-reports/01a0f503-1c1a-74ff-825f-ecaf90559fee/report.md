# 01a0f503-1c1a-74ff-825f-ecaf90559fee
[Open replay](https://us.posthog.com/project/638414/replay/01a0f503-1c1a-74ff-825f-ecaf90559fee) · 2026-10-01 01:10–01:39 UTC · 1775s wall (active 97s — 5%!) · 113 clicks · start `/auth` · Mobile/Android · 27 events

## Timeline
- 01:10:17 Installed → Opened → `/auth` → `$identify` → root (5s — fast midnight login)
- 01:10:25 `$exception` **[ConcurrentModificationError]** @root (3s)
- 01:10:39 search → 01:10:48 search → 01:10:49 `api_search` → 01:10:51 `api_search` (**double-fired 2s apart** — double-tap or no debounce)
- 01:11:05 root → category → 01:11:40 slug + detail → 01:11:42 `$exception` **[ConcurrentModificationError]** (2s!) → category → root → change-feed → root → `$set` → recommended → root → app-settings → root
- 01:12:15 bg → **27.5-min gap** → 01:39:55 Opened → 01:39:57 bg (2s — pocket-check "am I still here?"), end

## What the user does
Midnight burst (2 min, 113 clicks, 2 searches, 1 detail, 2 crashes) → settings glance → phone down 27 min → one 2s check → done. Real intent, dead phone battery of attention.

## Weird moment
The double `api_search` 2s apart is the only duplicated search-fire in the set — search submit has no debounce/loading lock. And the 01:39:55→01:39:57 Opened→Backgrounded pair is a tatoo of a dead session: OS woke the app, nobody home.

## Delays
1678s inactive (94%) — but the truth is a 2-min session wearing a 30-min coat. Session TTL recorded a sleeping phone.

## Emotion arc
Midnight curiosity (fast login, double search) → crash → drift to settings → abandon. No rage — the hour did the quitting.

## Improvements
1. Debounce search submit + loading lock (double-fire wastes a query and confuses ranking).
2. Cap idle recording / split sessions after >10-min gaps — this one inflates average duration hugely and pollutes every duration metric.
3. Re-engagement over UX: next-day "pick up where you left off" with the 1 viewed API + 2 searches restored.
