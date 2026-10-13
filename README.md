# Reqistry — APIs for You & AI

> **Find APIs you can trust. Monitor the ones you use.**
>
> The official Reqistry Android app: discover 3,500+ public APIs, compare them side by side, track health and trust changes, and feed the same trusted catalog to your AI agents.

[![Get it on Google Play](https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis&hl=en)](https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis&hl=en)
· [Website](https://reqistry.dev) · [Documentation](https://docs.reqistry.dev) · [Report an issue](https://github.com/reqistry/reqistry-app/issues)

---

## The app

![Reqistry app — find the right API, build your next idea](fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png)

| Home, stats & recommendations | API profile with live health | Explore categories & smart filters |
| --- | --- | --- |
| ![Home](fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png) | ![API profile](fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png) | ![Explore and search](fastlane/metadata/android/en-US/images/phoneScreenshots/4_en-US.png) |

## What you can do

- **Discover** — browse 3,500+ public APIs across AI, agent tools, finance, weather, music, security, productivity, games, health, education, and 70+ categories.
- **Evaluate before you build** — every API shows trust signals: live platform-observed health, trust score, auth requirements, pricing, HTTPS and CORS support.
- **Compare, don't guess** — pick 2–8 APIs and compare trust, pricing, speed, and uptime side by side, backed by live evidence.
- **Monitor what you ship** — save APIs to watchlists with daily health digests and alerts when trust scores drop; the change feed tracks health, pricing, and trust events across the catalog.
- **Organize** — group APIs into projects and keep favorites in sync.
- **Equip your agents** — create agent API keys in Settings and connect coding agents through MCP, so they query the same trusted catalog you see.
- **Free, no subscriptions** — the app is ad-supported (banner + clearly labeled native ads). Ad choices are collected before any ad loads (Google UMP) and can be revisited anytime in Settings → Privacy choices.

Reqistry is one catalog on four surfaces: [web catalog](https://reqistry.dev/categories), this Android app, [MCP for agents](https://docs.reqistry.dev/mcp/install), and a [public JSON API](https://api.reqistry.dev/v1/categories) (no auth for reads).

---

## Run locally

### Prerequisites

- Flutter SDK (`>=3.0.0 <4.0.0`)
- Android SDK (via Android Studio or command-line tools)
- A Firebase `google-services.json` for `android/app/` to enable push notifications (obtain from the project owner; the app compiles without it but FCM stays disabled)

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/reqistry/reqistry-app.git
   cd reqistry-app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Create your environment file from the template:

   ```bash
   cp .env.example .env.prod
   ```

   Fill in the values (`API_BASE_URL=https://api.reqistry.dev`, `PRIVACY_MD_URL`, store URLs, AdMob IDs, PostHog token — see `.env.example` for the full list).
   Only `.env.example` is versioned; `.env.*` files are gitignored and never committed.

   > Code generation reads **`.env.prod` by default** (`@Envied(path: '.env.prod')` in `lib/config/env.dart`).
   > To generate from a different file (e.g. `.env.dev`):
   >
   > ```bash
   > dart run build_runner build --delete-conflicting-outputs --define "envied_generator|envied=path=.env.dev"
   > ```

4. Generate the typed environment:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Generate localizations (after editing `lib/l10n/*.arb`):

   ```bash
   flutter gen-l10n
   ```

6. Run the app:

   ```bash
   flutter run
   ```

### Quality checks

```bash
flutter analyze          # must be zero issues before commit
flutter test             # all tests must pass
flutter build apk --debug  # full compile check
```

Release builds additionally need `android/key.properties` (signing config) and a production `google-services.json` — both gitignored; ask the project owner for them.

---

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `env.g.dart` has stale/empty values | You built from the wrong env file. Re-run step 4 (or the `--define` variant), and if it still looks stale, clear the cache first: `rm -rf .dart_tool/build`. |
| `API_BASE_URL` is empty at runtime | The env file used for codegen had blank values. Fill in `.env.prod` (or your `--define` target) and re-run codegen. |
| `flutter gen-l10n` errors / missing strings | Never hardcode user-facing text: add the key to both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, then re-run `flutter gen-l10n`. |
| No ads in debug, crash/failure in release | Debug builds use Google test ad IDs automatically. Release builds require real production AdMob IDs from the AdMob console. |
| Push notifications don't arrive | Check that a valid `google-services.json` is in `android/app/` and that notification permission is granted on the device. |
| `flutter analyze` reports issues | Fix them, don't suppress; any `// ignore:` needs a justification comment. |
| Build works locally but Play update misbehaves | The app uses Shorebird code push; verify the installed patch version matches the release in the Shorebird console. |

Still stuck? [Open an issue](https://github.com/reqistry/reqistry-app/issues) with your Flutter version (`flutter --version`), the failing command, and the full error output.

---

## Project structure

```
lib/
├── config/            # app_routes.dart (path constants), routes.dart (GoRouter), env
├── l10n/              # app_en.arb + app_es.arb → generated localizations
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

Conventions: `go_router` only (no raw `Navigator.push`), every request through `RemoteService`, design-system colors/type/spacing, no hardcoded user-facing strings. See `AGENTS.md` for the full contributor contract.

---

## Contributing

Bug reports, feature ideas, and design improvements are welcome — [open an issue](https://github.com/reqistry/reqistry-app/issues) or a pull request. Please run `flutter analyze` and `flutter test` before submitting.

---

## License

© 2026 Reqistry. All rights reserved.

This repository and the Reqistry app are proprietary. No license is granted to copy, modify, or distribute this code unless explicitly agreed with the project owner. Contact [work@gwhyyy.com](mailto:work@gwhyyy.com) for licensing inquiries. Privacy policy: [reqistry.dev/privacy](https://reqistry.dev/privacy).
