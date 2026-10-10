# 01a112e1-c718-73dc-98b5-8dae24f9ec38 — DEEP DIVE
[Open replay](https://us.posthog.com/project/638414/replay/01a112e1-c718-73dc-98b5-8dae24f9ec38) · 2026-10-06 20:22–20:42 UTC · 1194s (active 787s / inactive 407s) · 349 clicks · OnePlus8Pro/Android/Flutter v5.3.0 · 208 events (full 200-row timeline pulled) · 3 `$exception` with stacks

## Timeline
- 20:22:31 Installed → Opened → `/auth`; 20:23:08 bg→back; 20:23:09 `$identify` (fresh person)
- 20:23:10 root → 20:23:15 `$exception` **[ConcurrentModificationError**, showcaseview `_changeSequence:465 → _finishShowcase:632`]
- 20:23:17–20:28:44 onboarding wander: /projects, /submit-api, /submissions, /category-apis, /watchlists, /account-settings, /notifications — 20:25:07 `$exception` **[StateError: emit-after-close**, `CategoryApisCubit.fetchApisByCategory:91`]
- 20:28:44 /search → 20:29:34 `api_search` → 20:29:37 detail → 20:29:42 `$exception` **[ConcurrentModificationError]** @slug → save/delete thrash begins
- 20:29:36–20:41:49 the loop: 12 detail views, 15 saves, **31 created + 31 deleted**, 4 health-refreshes, 3 outbound docs (7 bgs), 2 alt-opened, 1 share, 20:37:22 **`api_detail_issue_reported`**
- 20:39:48–20:40:10 **10 deletes in 22s**, session winds down on root

## Weird moments
- Both showcase crashes share one fingerprint; the cubit race fires when category fetch outlives the page. All `handled:true` — invisible in crash-free metrics, fully visible in behavior.
- The 1:1 create:delete ratio with 15 `api_save` for 12 details = two save pipelines (`bookmark_*` + `api_save`) disagreeing about state.
- The 10-deletes-in-22s burst then exit = rage-clean then quit.

## Delays
407s inactive (34%): reading + stalls + the 7 background gaps (docs reading externally).

## Emotion arc
Confusion (7-min wander) → engagement (comparing/sharing) → frustration (explicit issue report — read its payload) → resignation (mass delete + exit).

## Improvements
1. Guard showcase `_changeSequence` (copy-before-iterate) or remove the tour. 2. `if (isClosed) return` in `CategoryApisCubit:91`. 3. One save source-of-truth + optimistic UI + toast + debounce. 4. Sticky mobile search (3 searches in 20 min). 5. In-app doc sheet. 6. Read the 20:37:22 issue payload — highest-signal feedback in the set.
