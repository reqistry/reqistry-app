# Reqistry App — Client Upgrade Plan

**From API catalog to agent command center.**
Scope: **client only** (`reqistry-app`, Flutter, v5.4.0+18). Backend items appear only as *consumption targets* or *explicit asks*.
Date: 2026-10-17. Basis: static audit of this repo + backend inventory of the existing mobile contract + current (Oct 2026) external design patterns. Visual/layout findings are marked plausible until rendered on device (see §11).

---

## 0. TL;DR

Five moves, four waves, ~14–18 weeks:

1. **Rebrand to Reqistry, everywhere** — kill all "API Scout"/`publicApis` user-visible residue; reframe store + in-app copy to the agent story.
2. **Evidence engine** — one reusable `EvidenceSheet`/factor component rendered from data the catalog *already returns* (trust factors, health observations, ship-check checks). This is the product's differentiator made visible.
3. **Agent Console** — a real MCP onboarding screen: endpoint, per-client install snippets, one-time key reveal, usage/quota, revoke, honest failure states. Today the app shows a key with no way to use it.
4. **Ask (structured first)** — replace the search FAB with one omnibox: Search · Ask (requirement chips → filters) · Go to. An LLM answer layer lights up later behind a documented client contract; no fake "coming soon" chat.
5. **Briefing + Stack** — Home becomes a "since last visit" triage queue (changes, stack deltas, watchlist hits); Saved+Projects merge into one Stack surface. Habits via explicable relevance, never streaks or engagement feeds.

North star (unchanged from product strategy): **qualified capability decisions**. Client proxies: compare completions, ship-checks run, APIs saved, agent keys connected, briefing return rate.

---

## 1. Where the app stands today (condensed audit)

### 1.1 Shell and screens

- 5 tabs + a search FAB: **Home, Explore (discover), Intelligence, Saved, You** (`lib/app/modules/views/main_shell_view.dart:36-42`), 19 GoRouter routes (`lib/config/routes.dart`), 24 view folders, 14 cubits, 220 Dart files, ES+EN l10n (~2,674 ARB lines each).
- **Intelligence tab** is a compare builder (2–8 picker, history chips) + curated collections + change feed (`intelligence_view.dart:117-143`). Evidence framing already in the hero copy ("DECIDE WITH EVIDENCE.").
- **Ship-check** exists but is buried as a row inside API detail (`ship_check_row.dart`, `ship_check_sheet.dart`).
- **Agent keys** exist in You→settings: create, copy-once, used-today, revoke (`agent_keys_section.dart`, 255 lines).
- **Watchlists** exist (GET/POST/DELETE; UI can create keyword watches; project monitors via `monitor_toggle.dart`; category watch via `category_watch_button.dart`).
- **Change feed, stack history, use-case collections, compare, health checks, reports, submissions** are all live and consumed.

### 1.2 What's genuinely strong (keep and build on)

- A **distinctive visual language**: flat bordered containers, no rounded Material cards/shadows, Phosphor icons, tabular numerals (`app_colors.dart`, `app_text_styles.dart:withTabular`). Do not throw this away for generic "AI gradient" styling.
- Design-system discipline enforced by AGENTS.md (AppColors/AppSpacing/AppTextStyles), dark mode + theme color choice, ES localization, analytics (PostHog) + error capture, Shorebird OTA configured, 35 test files incl. auth recovery, compare verdict, notification routing.
- Monitoring UX with real evidence data underneath (health observations, uptime 24h/7d/30d, trust factors with `computedAt`, verification timestamps).

### 1.3 Verified defects (fix first; each is small and high-leverage)

| # | Defect | Evidence | Impact |
|---|---|---|---|
| D1 | **First-run tours never fire.** `RootShowcase.maybeStart` has zero callers; detail tour gate requires `resetForReplay()` first | `main_shell_view/widgets/root_showcase.dart:41`; `api_detail_view/widgets/api_detail_showcase.dart:36-40`; only caller `settings_view.dart:257` | New users get no onboarding at all |
| D2 | Compare picker allows 8, docs/UX comment says 2–4 | `api_picker_sheet.dart:34` (`maxSelection = 8`) vs `compare_result_view.dart:19` | Unusable side-by-side on a phone; inconsistency |
| D3 | Dead widget, 137 lines | `intelligence_view/widgets/change_feed_section.dart` — zero references | Dead weight |
| D4 | Ad "dead slot" bookkeeping copy-pasted 4× | `favorites_view.dart:31-34`, `api_collection_view.dart:35-38`, `category_apis_view.dart:30-33`, `search_results_list.dart:28-31` | 4× maintenance for one behavior |
| D5 | Submit API form duplicated | `home_view/widgets/submit_api_sheet.dart` vs `submit_api_view/submit_api_view.dart` | Drift risk; 2× l10n surface |
| D6 | Settings IA split across 3 screens | `settings_view.dart`, `/app-settings`, `/account-settings`, same destinations reachable 2–3× | Navigation maze |
| D7 | Watchlist swipe-delete has no undo (notifications list does have undo) | `watchlists_view.dart:155-210` vs `notifications_view.dart:117-125` | Data-loss feel |
| D8 | RTL unhandled: hardcoded `caretRight`/`arrowRight`/`arrowLeft` (~17 sites) | e.g. `all_projects_view.dart:39`, `search_body.dart:65`, `submissions_view.dart:62` | Broken for RTL locales; flag-team-quality issue |
| D9 | Tap targets: bare `GestureDetector`s &lt;44dp in shared cards | `stat_box.dart:24`, `project_card.dart:25,76`, `latest_api_card.dart:23`, `registry_changes_section.dart:103` … | Accessibility |
| D10 | Text-scaling risk: fixed heights, 5-label 64px navbar, 9–10px labels in 2.6 aspect grid | `main_shell_view.dart:135`, `continue_work_section.dart:98-99`, `category_apis_view.dart:281-311` | Overflow at 200% font |
| D11 | GoogleFonts fetched at runtime, no bundled fonts | `app_text_styles.dart`, `pubspec.yaml` | Wrong typeface offline / cold start cost |
| D12 | Hardcoded non-l10n strings | `ship_check_sheet.dart:126-190`, `compare_result_view.dart:327-336`, `api_health_section.dart:32-36`, `settings_view.dart:138,276` ('MCP') | l10n gaps |
| D13 | Ad layout shift: native ad card renders nothing until filled; banner reserves height | `catalog_native_ad_card.dart:119-121` vs `ad_banner_slot.dart:84-85` | List jumpiness |
| D14 | Unused import + file | `advanced_filters_sheet.dart:9` → `quick_filter_chip.dart` (class unused) | Dead weight |
| D15 | Naming drift: nav "Saved" vs title "BOOKMARKS"; change feed rendered on both Home and Intelligence via same widget | `main_shell_view.dart:169`, `favorites_view.dart:49`, `home_view.dart:226`, `intelligence_view.dart:142` | Confusion, duplication |

### 1.4 API consumption state (client side of the contract)

37 documented mobile paths; ~30 consumed. Unconsumed / underconsumed today:

| Endpoint | Status | Plan |
|---|---|---|
| `GET /v1/trust-scores/{id}` | **not consumed** (only a doc-comment mention, `data/models/intelligence.dart:4`) | Use in Stack rows / lightweight trust chips without loading full detail (§5 F2) |
| `GET /v1/categories`, `/v1/categories/{id}/apis` | App uses legacy `/categories*` instead | Migrate after contract cleanup (§6 backend asks) |
| Legacy `GET /recommend` (`type=best|similar|usecase`) | not consumed | Leave; `/v1/recommend` is superior |
| `GET /metadata?url=` | not consumed | Optional: link preview in submit form (§5 backlog) |
| `POST /track` | not consumed (PostHog used instead) | Skip — one analytics pipe is enough |
| `GET /v1/categories/{id}`, `/{id}/image` | **documented but no v1 handler exists** (verified in `apps/api/src/routes/v1/categories.ts` — only `/` and `/:id/apis`) | Keep using legacy; contract fix requested (§6) |

### 1.5 Agent surface today (the biggest product gap)

- Backend MCP server: 13 read-only tools at `https://mcp.reqistry.dev/mcp`, public, optional `X-Agent-Key`.
- App: agent-key create/copy/revoke exists, but the app **never shows the MCP endpoint, an install snippet, or what to do with the key** — a settings row links out to `reqistry.dev/#mcp` (`settings_view.dart:276-278`).
- `/v1/agent-keys` responses carry `dailyQuota`, `usedToday`, `lastUsedAt` — the usable "is my agent actually working?" data, only partly surfaced.
- In-app AI: **none**. No ask/chat/assistant surface anywhere; `/search` is keyword-only (`q` matches name+description).
- Ship-check auth quirk: `/v1/ship-check` requires bearer/agent key while MCP's `assess_api_production_safety` internally uses trust-scores — client must not promise anonymous ship-check.

---

## 2. Product thesis for the client

Two users in one app, one loop:

- **The engineer** who needs to decide fast, watch what changed, and wire their agent to the same evidence.
- **The agent** (indirect): gets its catalog access from this app (key + config), and produces questions ("compare these 2", "what changed") the human answers in the app.

Three jobs, in order:

1. **Decide with evidence** — every score/recommendation/warning is drillable to factor rows with method, source and freshness. Tap-to-evidence, never hover (mobile has no hover).
2. **Wire your agent** — from "install" to "my key works" in under 2 minutes, with the full config shown verbatim (not summarized — Cursor's own advisories exist because install dialogs hid arguments).
3. **Stay current without noise** — one briefing/triage queue of explicable changes; batched, rate-limited, opt-out-able. No predicted-engagement feed, no streaks.

Design principles (added to AGENTS.md design rules):

- Evidence over opinion; honest "unknown" ("Not measured yet", "Last verified 4d ago") beats a green badge we can't back.
- Show the full command/config/secret once, exactly as it will be pasted.
- Deterministic first: ship the structured version of a feature (requirement chips → filters); layer the model on top when a real endpoint exists.
- Copy-paste-native: everything an engineer would paste into a terminal/PR/issue is a copyable block.

Anti-goals: no generic chat bolted on; no engagement-optimized feed; no streak counters; no push per event; no dark patterns; no paywall in this cycle (current monetization is ads; see §10).

---

## 3. Rebrand plan (client side)

### 3.1 Decision

Keep **Reqistry** (per `product/reqistry.md` §13). Descriptor: *API intelligence for builders and agents*. Tagline: *Find the right API. Give your agents the right tools.*

### 3.2 Surface-by-surface

| Surface | Current | Target | Evidence |
|---|---|---|---|
| Android launcher name | `${appName}` from env = "Reqistry" | ✅ keep (verify `.env.prod` in release pipeline) | `AndroidManifest.xml:6`, `.env.example` |
| iOS display name | "Api Scout" | "Reqistry" | `ios/Runner/Info.plist:9-10` |
| iOS bundle name | `api_scout` | `reqistry` (cosmetic; bundle id separate) | `Info.plist:17-18` |
| In-app title/description strings | `appTitle`: "API Scout", `appDescription`: "API Scout - …" | "Reqistry" + agent descriptor | `lib/l10n/app_en.arb:3,11` (+es) |
| Pubspec description | already correct | keep; rename package `api_scout` only as part of a descoped mechanical refactor (open decision) | `pubspec.yaml` |
| Store listing (Play) | "Reqistry: APIs for You & AI" / "APIs for you & AI agents: discover, compare, trust, connect." | "Reqistry — API intelligence for builders & agents"; short: "Find the right API. Give your agents the right tools." | `fastlane/metadata/android/en-US/*` |
| Share URL | Play link w/ old package id | keep package id (install continuity), so URL unchanged | `.env.example`, `Env.appShareUrl` |
| App icon / splash / feature graphic | legacy identity | new mark: neutral, technical, evidence-like (grid/node or registry-entry motif), no AI gradients/robots | `android/app/src/main/res`, `ios/Runner/Assets.xcassets` |
| Store screenshots (6) | catalog browsing | 1) Evidence card drilldown 2) Compare verdict 3) Ship Check 4) Agent Console / MCP connect 5) Briefing 6) Stack health | `fastlane/.../phoneScreenshots` |

### 3.3 Open rebrand decisions (owner input needed)

- **Package id**: keep `com.gwhyyy.publicApis` (recommended — install update continuity) vs new `dev.reqistry.app` (clean identity, loses existing installs). Recommend keep until 6.0, revisit with a migration note in the store listing.
- **Code package rename** `api_scout` → `reqistry_app`: mechanical but touches 220 files; recommend deferring to a quiet window, or never (it's internal).

---

## 4. Information architecture & screen plan

### 4.1 Tabs (same 5 slots, re-scoped)

| # | Today | Target | Why |
|---|---|---|---|
| 0 | Home (sections: activity, projects, latest, changes…) | **Desk** — briefing triage queue + stack status + own activity | The recurring reason to return |
| 1 | Explore (catalog) | **Catalog** — search, categories, collections, recently added | Unchanged role, cleaner entry |
| 2 | Intelligence (compare + collections + change feed) | **Decide** — Ask bar, compare builder, ship-check history | Where decisions happen |
| 3 | Saved (bookmarks) + Projects elsewhere | **Stack** — projects/folders + bookmarks unified, per-API monitoring, stack health | Favorites vs projects overlap resolved |
| 4 | You (settings hub) + 2 more settings screens | **You** — single settings screen (sections), account sheet | One settings IA |
| FAB | Search FAB | **Omnibox sheet** — Search / Ask / Go to | One global entry; replaces FAB+search screen split |

Tab labels change **with their screen**, never earlier: Decide ships with the wave-2 Intelligence rework, Desk/Stack labels with wave 3. Until then users see today's labels — no intermediate rename release.

### 4.2 Screen disposition

| Screen | Fate | Notes |
|---|---|---|
| `home_view` | **rework** → Desk/Briefing | remove duplicate change-feed render; keep activity + projects summary |
| `discover_view` | keep | becomes Catalog home |
| `intelligence_view` | **rework** | ask bar + compare + ship history; move change feed out (it lives in Desk) |
| `favorites_view` | **merge** into Stack | nav label fixes ("Saved"/"BOOKMARKS" consistency) |
| `project_apis_view`, `all_projects_view` | keep, re-parent under Stack | unify naming: "Projects" everywhere; folders = backend entity, call them Projects |
| `api_detail_view` | keep, extend | add EvidenceSection (factor drilldown), Ship Check promotion, "Compare with…" quick action |
| `api_collection_view`, `category_apis_view`, `search_screen` | keep | share one list-ad-slot component (D4) |
| `watchlists_view` | keep, upgrade | add undo, kinds clarity, limit counter (max 10 server-side) |
| `change_feed_view` | keep | add filter by my stack; becomes Desk's "view all" |
| `compare_result_view` | keep, rebrand as **Decision report** | verdict + evidence rows + share |
| `submit_api_view` + sheet | **merge** into one form widget | two entry points, one widget |
| `settings_view` + `app_settings_view` + `account_settings_view` | **merge** | sections: Account (sheet), Preferences, Notifications, Agent access, About; keep old routes as redirects |
| `notifications_view` | keep | keep undo pattern; add preference parity |
| `auth/` | rework onboarding | fix D1 gating; 3-step first run (§5 F9) |
| `contact_view`, `privacy_view`, `submissions_view` | keep | low touch |
| **NEW: Agent Console** | add (`/agent`) | MCP connect + keys (§5 F3) |
| **NEW: Ship Check history** | add (inside Decide or `/ship-checks`) | list + detail + share |
| `apis_view/widgets`, `general/loading` | keep as shared widget homes | not screens |
| `change_feed_section.dart` (widget) | **delete** (D3) | zero refs |
| `quick_filter_chip.dart` | **delete** + fix import (D14) | zero class usage |

---

## 5. Feature plan

Sizes: S ≈ ≤1 day, M ≈ 2–4 days, L ≈ 1–2 weeks incl. tests. Every item ships with the AGENTS.md verification loop.

### Wave 0 — Integrity & cleanup (≈2 weeks, all S except noted)

| ID | Item | Detail | Ref |
|---|---|---|---|
| W0-1 | Fix onboarding gating | call `RootShowcase.maybeStart` from shell init when `rootOnboardingDone != true`; detail tour gate: `!isDone \|\| replayRequested`; **silently backfill the flag for pre-fix installs** (detect via an existing prior-run signal, e.g. populated `LocalsDB`) so existing users don't get a surprise tour + inflated analytics; new analytics `onboarding_tour_started/completed/skipped` | D1 |
| W0-2 | Delete dead code | `change_feed_section.dart`, `quick_filter_chip.dart` + import | D3, D14 |
| W0-3 | One ad-slot list component | extract `_deadSlots` + `CatalogNativeAdCard`/`AdBannerSlot` sandwich into a shared `AdAwareList` used by 4 lists; reserve heights (D13) | D4, D13 |
| W0-4 | One submit form | extract to `shared/widgets/submit/submit_api_form.dart`, keep both entries | D5 |
| W0-5 | Compare cap decision | set picker cap to **4** (phone-usable), deep links/digest can still load up to 8; fix stale comment | D2 |
| W0-6 | Watchlist undo | SnackBar undo (pattern from notifications) on swipe-delete; remove duplicate trash affordance | D7 |
| W0-7 | Naming & navigation consistency | "Stack" everywhere; kill "BOOKMARKS" appbar; one change-feed home (Desk) | D15 |
| W0-8 | a11y pass 1 | ≥48dp wrappers for bare GestureDetectors; fix RTL icon directions; textScaler backstop clamp at 2.0 + fix fixed-height rows | D8, D9, D10 |
| W0-9 | Bundle fonts | ship Inter/Geist-style brand font in assets; drop runtime fetch | D11 |
| W0-10 | l10n sweep | move hardcoded strings into both ARBs; add key for "MCP" copy | D12 |
| W0-11 | Split `api_detail.dart` model (800+ lines) | per AGENTS.md known debt; pure move + tests | AGENTS.md |
| W0-12 | Contract hygiene | align `openapi.mobile.json` usage: keep legacy categories (v1 paths documented-but-missing); file backend ask (§6) | §1.4 |

### Wave 1 — Evidence & Agent Console (≈4 weeks)

| ID | Feature | Goal & UX | API | Size |
|---|---|---|---|---|
| F1 | **EvidenceSheet engine** | One bottom-sheet component: claim → factor rows (pass/warn/fail/unknown), each with method + source + `computedAt`/"observed Xh ago". Used by trust score, ship-check, health, agent-readiness (when present), compare verdict. Replaces hover-style thinking; tap-to-evidence everywhere | `GET /v1/apis/{slug}` (`trustScore.factors`, `health`), `POST /v1/ship-check` (`checks.*`) — existing | L |
| F2 | **Trust everywhere** | Lightweight trust chip + sheet on list rows (Stack, search results, collections) without full detail fetch. **Lazy: fetch on tap only — no per-row fan-out** (list payloads carry no score). New consumption of `GET /v1/trust-scores/{id}` | `/v1/trust-scores/{id}` — **new consumption**; optional backend ask: trust fields on list payloads (§6.2-7) | M |
| F3 | **Agent Console** (`/agent`) | The flagship. Sections: (1) *Connect your agent* — endpoint + per-client tabs (Claude Code `claude mcp add --transport http …`, Codex TOML, OpenCode, Cursor, generic HTTP) each with copy block, full config shown verbatim; (2) *Keys* — create (one-time reveal w/ copy + share sheet), state, `usedToday/dailyQuota`, `lastUsedAt`, revoke; (3) *Verify* — "ask your agent: *List Reqistry categories*" checklist; honest states (`no key yet`, `key revoked`, `unknown — agent hasn't called yet`). **Guest sessions allowed** (backend accepts device sessions) with explicit device-bound warning copy: keys are lost on reinstall unless the account is linked. Endpoint URL read from `Env` (fallback constant) so it can move server-side later | `GET/POST/DELETE /v1/agent-keys` — existing (extend UI to quota/usage) | L |
| F4 | **Ship Check promotion** | Row → prominent action card on API detail + "run ship-check on my stack" batch view; shareable report (text/markdown + share sheet); link from compare verdict when verdict differs. **Guest sessions allowed** (no email gate); batch runs are sequential with progress, not parallel fan-out | `POST /v1/ship-check` — existing | M |
| F5 | **Connect step in onboarding** | First-run: 1) what Reqistry is (evidence framing) 2) *optional* "Connect your agent" (leads to Agent Console, skippable) 3) pick first watch/project. Fixes D1 with intent | — | M |
| F6 | **Deep links re-enable** | App Links (verified against assetslink) for `/apis/:slug`, `/compare?ids=`, `/agent`; ship behind tests — history: deep linking was removed for crashes (CHANGELOG 4.1.0), so this needs the ceremony | — | M |
| F7 | **Share system** | One share component: API card (name + evidence line + link), compare report, ship-check report, agent config. Copy-to-clipboard variants | — | S |

### Wave 2 — Ask & Decide (≈5 weeks)

| ID | Feature | Goal & UX | API | Size |
|---|---|---|---|---|
| F8 | **Omnibox v1 (deterministic)** | One sheet replacing the FAB: *Search* (live results) · *Ask* (requirement chips: "works without a key", "free tier", "CORS", "production-safe", "has SDK", "no credit card" → maps to `/search` filters `auth/pricing/cors/https/alive` + category) · *Go to* (projects, agent, watchlists). Result screen = normal results + save/compare shortcuts | `/search` (existing params) | L |
| F9 | **Paste-a-requirement parser** | Second path in Ask: user pastes/builds a sentence ("free weather API, no key, CORS") → deterministic keyword→filter mapping with visible "we understood: …" chips they can correct before searching. No LLM needed; sets up the LLM layer later | `/search` | M |
| F10 | **Decision report (compare 2.0)** | Compare result gets: top-pick verdict already computed (`compare_verdict_test`), evidence rows per axis (from compare item fields incl. `lastVerifiedAt`), "why not X" notes, share/export, save-as-project action | `GET /v1/apis/compare` — existing | L |
| F11 | **Ask answer layer (contract-first)** | Document the client contract for `POST /v1/ask` (streamed: steps, evidence refs, answer cards). Ship UI behind a capability flag only when the backend ships; until then the Ask tab IS F8/F9. No fake chat | backend dependency (§6) | M (client side) |
| F12 | **Collections → action** | Collection detail: compare the whole shortlist, "save to project", per-API ship-check | `/v1/use-case-collections` — existing | S |

### Wave 3 — Habits & polish (≈4 weeks)

| ID | Feature | Goal & UX | API | Size |
|---|---|---|---|---|
| F13 | **Desk / Briefing** | Home = single triage queue since last visit: stack health deltas (`downCount`, avg trust), change-feed items filtered to my stack, watchlist hits, review decisions (submission/report updates). Grouped by *needs action* / *informational*; a visible "last checked" line. Explained ranking; no engagement feed | `/v1/stack`, `/v1/stack/history`, `/v1/change-feed`, watchlists, notifications — existing | L |
| F14 | **Stack tab merge** | Projects (folders) + bookmarks into one screen; per-project monitoring toggle summary; per-API health dots; quick add-to-project; stack history chart expansion (`stack_history_sheet` → inline) | `/v1/folders*`, `/v1/bookmarks*`, `/v1/projects/*`, `/v1/stack*` — existing | L |
| F15 | **Watchlists 2.0** | Kind selector (keyword/category/project), live limit counter (10), matched-change preview, undo; deep link to matched APIs | `/v1/watchlists*` — existing | M |
| F16 | **Notifications polish** | Preference parity with 6 backend prefs; per-type preview copy; deep-link analytics already routed (`routes.dart` notification kinds) — extend to new destinations (agent, ship) | `/v1/notifications/preferences` — existing | S |
| F17 | **Onboarding v2 & empty states** | Every empty state teaches one action (no projects → create; no watch → suggest from stack; no agent key → connect) | — | M |
| F18 | **Store assets & release notes** | Screenshots per §3.2, feature graphic, changelog + Play release notes template; Shorebird patch notes | — | S |

### Backlog (explicitly deferred, revisit after wave 3 data)

- Android home-screen widget: one-line stack health + top change (habit without opening).
- Share target: receive URLs into "check this API" flow.
- iOS revival (project exists; needs Info.plist rebrand + CI + store work).
- Reqistry Pro (ad removal) — only if data shows it; keep "no paywall" stance otherwise.
- `GET /metadata?url=` link preview in submit form.
- Offline briefing cache (Hive) + stale indicators.

---

## 6. API consumption map & backend asks

### 6.1 Client consumption changes (this repo only)

| Feature | Endpoint(s) | Change |
|---|---|---|
| F2 trust everywhere | `GET /v1/trust-scores/{id}` | **new** |
| F3 agent console | `GET/POST/DELETE /v1/agent-keys` | extend UI (quota, usage, lastUsedAt); no contract change |
| F8/F9 ask | `GET /search` | reuse filters; no change |
| F10 decision report | `GET /v1/apis/compare` | reuse; render `lastVerifiedAt` per axis |
| F13 briefing | `GET /v1/stack`, `/v1/stack/history`, `/v1/change-feed`, `/v1/watchlists` | reuse |
| F14 stack | `/v1/folders*`, `/v1/bookmarks*`, `/v1/projects/*` | reuse |
| optional | `GET /metadata?url=` | only for submit preview |

Deliberately **not** consumed: `POST /track` (PostHog is the analytics pipe), legacy `/recommend`, legacy `/submit`, `/v1/categories*` until contract fix.

### 6.2 Backend asks (out of this repo's scope; needed for full value)

1. `POST /v1/ask` — structured NL requirement → shortlist with evidence refs (client contract drafted with F11). Client ships UI when this exists.
2. Contract hygiene: implement or remove `/v1/categories/{id}` + `/{id}/image`; note alternatives `limit` is 2|3 only; ship-check auth requirement (anonymous users) — decide and document.
3. Agent-readiness score + factors (per product/reqistry.md §7) — client has the evidence component ready to render it.
4. Android App Links association file (`assetlinks.json`) for F6.
5. Optional: MCP server URL surfaced in an endpoint (so no hardcoding `mcp.reqistry.dev/mcp` in the app; fallback: `Env`).
6. Optional: `dailyQuota` configurability surfaced; per-key last-used details.
7. Optional: trust score + `lastVerifiedAt` on list payloads (`/search`, `/v1/stack`, collections) so list chips need no per-row fetch (F2 currently fetches on tap).

---

## 7. Engineering rework (client code)

- **New shared components**: `EvidenceSheet` (+`EvidenceRow`, `FactorList`), `AdAwareList`, `SubmitApiForm`, `RequirementChips`, `ShareCard`, `TrustChip`, `Omnibox` sheet, `CopyBlock` (verbatim config/secret with copy + "shown once" semantics).
- **Model/split work**: split `api_detail.dart` (800+) and `api_detail_view.dart` (769) per AGENTS.md; add models: `TrustScoreRef`, `AgentKeyUsage`, `ShipCheckSummary`, `BriefingItem` (aggregate of feed/stack/watch hits — client-side compose, no new contract).
- **Services**: extend `RemoteService` with `getTrustScore(id)`; keep Dio discipline (no raw Dio); silent-request convention for briefing preloads (`silentKey`).
- **Cubits**: one new `agent_console_cubit`; rework `user_activity_cubit` into `briefing_cubit` (it already fetches stack summary — reuse, don't rewrite).
- **Analytics taxonomy** (PostHog, snake_case): keep existing names (`api_search` etc.) and **add** new events — no renames, so before/after funnel comparisons survive. New: `requirement_parsed` (chips + corrections), `compare_completed` (if absent), `decision_report_shared`, `evidence_sheet_opened` (surface prop), `ship_check_run|shared`, `agent_key_created|revoked`, `agent_connect_config_copied` (client prop), `briefing_viewed` (queue size, action rate), `watchlist_created|matched_open`, `onboarding_tour_completed|skipped`, `deep_link_opened` (kind). Guardrail events: notification pref changes.
- **Performance**: bundled fonts (W0-9), keep `cached_network_image`, verify cold start after `MainInit` changes, brief splash (flutter_native_splash optional, only if needed for rebrand assets).
- **A11y baseline**: ≥48dp targets, Semantics on icon-only actions, RTL pass, textScale 2.0 render check, contrast check for new evidence colors (warn/unknown states need non-color cues).
- **Tests** (per new logic branch, no new frameworks): evidence mapping, requirement-chip parser (pure function, table-driven), agent key reveal/copy/one-time semantics, ship-check verdict display, briefing ranking, undo behavior, deep-link parsing (extend existing `parseNotificationAction`-style pure decoders).
- **CI (optional)**: GitHub Actions running the AGENTS.md four commands on PR (repo currently has none).

---

## 8. Metrics

- **North star proxy**: qualified capability decisions = `compare_completed` + `ship_check_run` + `api_saved_to_project` + `agent_key_created`, weekly actives doing ≥1.
- **Funnel**: omnibox open → search/ask → detail → evidence opened → compare → save/share.
- **Habit**: briefing return rate (W1), watchlist alert → open rate, digest opt-out rate (guardrail, keep low).
- **Agent**: keys created per week, config copied per key, "verify" checklist completion, second-day agent-key usage (`lastUsedAt` within 48h of creation).
- **Quality guardrails**: crash-free sessions, ad-caused layout complaints (Play reviews), tour skip rate (if high, the copy is wrong, not the tour).

---

## 9. Roadmap

**Execution assumptions** (correct them and the waves re-scope): one builder at ~1 FTE; the owner controls store releases (Shorebird patches handle code fixes between releases, but icon/listing/screenshot changes need a store release); an Android device/emulator, one real MCP client, and PostHog access are available for the §11 checks. If capacity is below 1 FTE or a fixed date exists, cut in this order: F6 (deep links), W0-11 (model split), W0-9 (font bundling), F12 (collections actions).

| Wave | Duration | Exit criteria |
|---|---|---|
| 0 Integrity | 2 wk | D1–D15 closed; analyze 0 issues; tests green + new tests for gate/parser/undo; build apk debug |
| 1 Evidence + Agent Console | 3–4 wk | Evidence sheet on detail/ship/compare; `/agent` live with copy-verified snippets (manual check per client docs); ship-check shareable; deep links tested on device |
| 2 Ask & Decide | 4–5 wk | Omnibox replaces FAB; chips map to filters with visible corrections; decision report v2; F11 contract doc merged |
| 3 Habits & polish | 3–4 wk | Desk queue live with analytics; Stack merged; watchlists 2.0; store assets rebranded; release notes |
| Backlog | — | Widget, share target, iOS, Pro — gated on wave 3 metrics |

Release mechanics: Shorebird OTA patches for wave 0–2 fixes between store releases; version bump per wave; store listing copy updates with wave 1 (agent story) and wave 3 (assets).

---

## 10. Risks, anti-goals, open decisions

Risks:

- **Ask without a backend LLM** — mitigated by deterministic F8/F9 first; F11 ships only with a real endpoint (no fake chat).
- **Deep-link re-enable** — this crashed before; ship with unit tests + staged rollout via Shorebird.
- **Contract drift** — mobile OpenAPI is hand-maintained and already documents a missing path; treat as documentation, verify against handlers.
- **Rebrand vs continuity** — package id decision (§3.3) affects installs; copy-only rebrand is safe.
- **Ad-funded free app vs "premium engineer tool" feel** — mitigate with reserved heights, no ads inside Decide/Agent surfaces (evaluate; ads currently on Intelligence tab `intelligence_view.dart:113-116`), and never interstitial in decision flows.
- **Scope creep into backend** — every F here works against existing endpoints except F11, which is contract-only until backend ships. Backend-dependent items (§6.2, F6, F11, W0-12) are **flag-gated with client fallbacks** (F11 ships nothing; F6 links stay internal; F3 uses an `Env` constant) — dependencies, not blockers.

Open decisions for the owner:

1. Package id rename now / at 6.0 / never? (recommend: never, keep installs)
2. Compare cap: 4 (recommend) or keep 8?
3. Ads inside Decide/Agent surfaces: remove (recommend) or keep?
4. iOS: rebrand + revive now or keep Android-only this cycle?
5. Wave 2 Ask: acceptable to ship deterministic-only until `/v1/ask` exists?

---

## 11. Verification protocol

Static-only audit caveat: all layout/RTL/textScale findings are **plausible, not confirmed** until rendered. Per wave, before claiming done:

1. `flutter analyze` → 0 issues · `flutter test` → green · `flutter gen-l10n` · `flutter build apk --debug` (AGENTS.md loop).
2. Device smoke: cold start offline (fonts), 200% text scale on 5 tab screens, RTL locale pass, ad-fill vs no-fill layout, deep-link matrix, agent-console copy → paste into a real MCP client (at least one of Claude Code/Cursor/Codex) and verify the "List Reqistry categories" check.
3. Analytics: verify each new event fires once with expected props (PostHog live view).
