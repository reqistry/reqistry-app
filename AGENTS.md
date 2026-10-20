# AGENTS.md

Guidance for AI coding agents and engineers working on **Reqistry** (`api_scout`) — Flutter app for the Reqistry API catalog. Backend lives in the sibling repo `reqistry-backend` (its own `AGENTS.md` documents the API, deploy and gate procedures); the mobile contract is `openapi.mobile.json` at this repo root, which must stay byte-identical to the backend's copy.

## Commands

```bash
flutter analyze          # must be zero issues before commit
flutter test             # all tests must pass
flutter gen-l10n         # after editing lib/l10n/*.arb
flutter build apk --debug  # full compile check
```

No CI here — run all four before finishing a task.

## Architecture

```
lib/
├── config/            # app_routes.dart (path constants), routes.dart (GoRouter), env
├── l10n/              # app_en.arb + app_es.arb → generated app_localizations*.dart
├── shared/widgets/    # cross-feature widgets (AppLoading, AppErrorState, badges)
├── app/
│   ├── blocs/<feature>_cubit.dart   # one cubit per feature, plain Cubit (no events)
│   ├── data/models/                 # hand-written fromJson/toJson models (no codegen)
│   ├── services/
│   │   ├── fetch_api/remote_service.dart  # ALL HTTP GET/POST data-source methods
│   │   ├── auth/dio_client.dart     # Dio singletons, interceptors, token refresh
│   │   └── notification/fcm_service.dart  # FCM tokens, prefs, in-app feed cache
│   └── modules/views/<feature_view>/      # screens; sub-widgets in widgets/
└── utils/design_system/   # AppColors, AppSpacing, AppTextStyles — always use these
```

**Data flow:** View → Cubit or FutureBuilder → `RemoteService` / service → DioClient → backend `/v1/*`.

## Hard rules

- **Routing:** go_router only (`context.push(AppRoutes.x)`). Never `Navigator.push(MaterialPageRoute(...))`. New screen = constant in `app_routes.dart` + GoRoute in `routes.dart`.
- **HTTP:** every request goes through `RemoteService` (or an existing service). No raw `Dio()` outside `dio_client.dart`. Follow existing method shape: try/catch `_handleDioError`, `Failure(l10n?.key ?? 'fallback', ...)`.
- **Design system:** colors via `AppColors.of(Theme.of(context).brightness)` returning `AppColorScheme`; type via `AppTextStyles`; spacing via `AppSpacing`. Visual language is flat bordered containers — no rounded Material cards/shadows.
- **Strings:** never hardcode user-facing text. Add key to both `app_en.arb` and `app_es.arb`, then run `flutter gen-l10n`.
- **State:** plain Cubit per feature. No new bloc/event libraries. One-shot page state may use FutureBuilder (see `api_collection_view.dart` for the pattern).
- **Auth:** tokens live only in `AuthTokenService` (Hive). Refresh/recovery logic is centralized in `dio_client.dart` + `auth_cubit.dart` — see `shouldResetIdentity()` doc comment for the stale-identity contract with the backend.
- **Backend contract changes:** when the backend repo changes endpoints/payloads, sync `openapi.mobile.json` and update affected models/services in the same change.
- **Agent Console:** the MCP endpoint is server-driven (`GET /v1/agent-keys/config`) with the documented default as fallback — never hardcode the host, and keep the install snippets verbatim in sync with the backend's published docs.

## Conventions

- Widget-per-file for anything non-trivial: screen files compose, behavior lives in `<screen>/widgets/`.
- Models are hand-parsed with defensive defaults (`?? 'Unknown'`) — server nulls are common. Mirror existing style.
- Errors surface through `AppErrorState` / `RequestErrorNotifierInterceptor` toasts; silent requests opt out via `silentKey` extra.
- Tests live in `test/`, no mocking framework installed — prefer pure-function extraction (e.g. static helpers marked `@visibleForTesting`) over adding mocks.

## Verification loop

1. `flutter analyze` → 0 issues (fix, don't suppress; ignores need justification comment)
2. `flutter test`
3. `flutter build apk --debug`

## Known debt (do not replicate; fix opportunistically)

- `data/models/api_detail.dart` is an 800+ line model file with parsing + serialization helpers — split when next touched.
- Root-level junk: marketing docs, logs.
- Test coverage thin relative to 14 cubits; auth recovery and model parsing are covered — keep that bar for new logic branches.
