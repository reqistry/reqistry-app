# Session Replay Reports — 46 replays, 2026-10-01 → 2026-10-09 (ENRICHED)

Project: Default (638414) — [Replay list](https://us.posthog.com/project/638414/replay)
Range: last 30d (retention 30d), filter_test_accounts=true. Method: full per-session event timelines (3 bulk streams + marathon buckets + deep-dive 200-row pull) + session-scoped `$exception_types` for every replay.
Note: list API labels all `snapshot_source: web`, but `session-recording-get` proves the Android rows are `mobile / posthog-flutter` — Mobile/Android rows below are the Flutter app, Desktop rows the website.

## Totals
- 46 replays: Mobile 33 / Desktop 12 / Unknown 1 (replay, no events)
- Duration: bounce (<10s) 13 · short (10-60s) 6 · medium (1-5m) 16 · long (5-15m) 7 · extended (>15m) 4
- 36 session-scoped exceptions: **ConcurrentModificationError ×32, StateError ×2, _TypeError ×2** — every mobile session with events throws; bug live Oct 1→9 with zero fix evidence

## Headline findings (new in enriched pass)
1. **Homepage `$dead_click` ×5** (`…5144`, `…91af`, `…5598`, `…2ddc`, `…6da2`) — same dead control, 2 OSs, 2 browsers, 4 days. Two users recovered via a second control; three bounced.
2. **Save-path `_TypeError`** (`…8b3` 18:26:03, same second as `bookmark_created`; marathon `…013` 08:09) — the create call itself throws. Prime suspect for the whole save-thrash epidemic.
3. **Detail-page toggle vs card quick-save**: `…8ba` saved from the category card cleanly, then thrashed on the detail toggle 60s later. Bug is in detail state, not the pipeline.
4. **Push deep-link broken** (`…848`): `$push_notification_opened` → root, hunt, gone in 8s.
5. **Search double-fire** (`…9fee` two `api_search` 2s apart) — no debounce/loading lock.
6. **Crash timing signature**: root crashes 2–15s after first root; slug crashes 1–13s after detail (outlier `…00df` 114s — a late timer). Whatever mounts late (tour step? related-fetch?) is the trigger.
7. **Cross-surface journeys**: `…fec0`'s 4-min app background = the #mcp web triplet; `…503`'s 27-min gap = sleeping phone inflating duration metrics (split sessions after 10-min idle).
8. **Clean control** (`…8051`): 19 screens, 0 exceptions — skipped category/slug/showcase, survived. Crash surface confirmed by elimination.
9. **Two issue reports** (`…ec38` 20:37:22, `…9b8` 21:42:55) — both filed ~40s after a crash. Read both payloads.
10. **Session splitting**: `…8fc3`→`…42f8`→`…e7d9`, `…64e5`/`…7eeb`/`…c5fc`, `…8051`/`…b911`, `…b16`→`…b19` — stitch before funnel math.

## Folders
Each folder = full session ID → `report.md` (timeline with timestamps, exact exception types, quantified delays, emotion arc, concrete fixes).
Deep-dive: `01a112e1-c718-73dc-98b5-8dae24f9ec38` · Marathon: `01a11013-b27b-71f7-b2d3-1e0f757e7d03` · Sharer: `01a0f8d8-7109-7c1a-b711-05585ed121bb` · Wanderer: `01a0f8ce-89d3-7b6a-b898-b3bac3e4d678`
