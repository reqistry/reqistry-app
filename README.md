# Reqistry

> **API intelligence for builders and agents.**
>
> Find the right API. Give your agents the right tools.

Reqistry is an API intelligence platform that helps developers and AI agents discover, evaluate, trust, and connect to the right capabilities. This repository contains the **Reqistry mobile app** — the companion product for discovery and evaluation on the go: a browsable catalog of **1,400+ free public APIs** organized into **50+ categories**, with search, health checks, and projects.

[Get it on Google Play](https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis)

---

## Features

- **Catalog browsing** — 1,400+ public APIs across 50+ categories, with trending, recommended, and recently-added sections.
- **Powerful search** — keyword search with advanced filters (auth type, HTTPS, CORS, pricing, category).
- **API profiles** — full description, quick facts (auth, pricing, HTTPS/CORS/type), platform-observed health checks, verification fields, warnings, and documentation links.
- **Similar APIs** — related capabilities with thumbnails and one-tap bookmarking.
- **Bookmarks & Projects** — save capabilities for later and organize them into named projects.
- **Sharing** — share an API's name, URL, and homepage with a clean "shared by Reqistry" signature.
- **Offline-first** — connectivity-aware with automatic retry of the last failed request; the privacy policy is cached locally.
- **Push notifications** — optional FCM-based notifications for relevant updates.
- **Privacy-respecting** — anonymous sign-in by default; link an email only if you want cross-device continuity.

## Tech Stack

| Area | Choice |
| --- | --- |
| Framework | Flutter (Dart) |
| State management | `flutter_bloc` |
| Navigation | `go_router` |
| Networking | `dio` (auth, connectivity, and error-toast interceptors) |
| Local storage | `hive` / `hive_flutter` |
| Configuration | `envied` (typed, generated from `.env.*`) |
| Notifications | `firebase_messaging`, `flutter_local_notifications` |
| UI | `google_fonts`, `phosphoricons_flutter`, `flutter_markdown_plus`, `cached_network_image` |
| Extras | `share_plus`, `url_launcher`, `in_app_review`, `package_info_plus`, `connectivity_plus` |
| Debug tooling | `device_preview_plus`, `requests_inspector` |

> The app is a pure client. The catalog and intelligence backend live outside this repository; the platform also includes web, machine API, and MCP surfaces as part of the broader Reqistry product.

## Getting Started

### Prerequisites

- Flutter SDK `>= 3.0.0`

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/API-Scout-App/api-scout-app.git
   cd api-scout-app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Create your environment file from the template:

   ```bash
   cp .env.example .env.dev
   ```

   Fill in the values (`API_BASE_URL`, `PRIVACY_MD_URL`, store URLs, etc.).

4. Generate the typed environment and Hive adapters:

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   > To generate from a different env file (e.g. production):
   >
   > ```bash
   > dart run build_runner build --delete-conflicting-outputs --define "envied_generator|envied=path=.env.prod"
   > ```
   >
   > If the generated `env.g.dart` ever looks stale, remove the build cache first:
   > `rm -rf .dart_tool/build`

5. Run the app:

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── app/
│   ├── blocs/          # BLoC cubits (auth, api_detail, search, favorites, projects, ...)
│   ├── data/models/    # API models (ApiDetail, ApiAlternative, Project, ...)
│   ├── modules/views/  # Screens and screen-specific widgets
│   ├── services/       # Dio client, connectivity, Hive, share, notifications, analytics
│   ├── utils/          # Design system, snackbar helpers
│   └── widgets/        # Shared app widgets (snackbar, overlay, dialogs)
├── config/             # go_router routes, env (envied), app constants
├── shared/widgets/     # Cross-cutting widgets (error/empty states, cached images)
└── main.dart
```

## Quality Checks

```bash
flutter analyze   # static analysis
flutter test      # unit & widget tests
```

## Contributing

Contributions of any kind are welcome — bug reports, feature ideas, design improvements, or code. Open an issue or a pull request.
