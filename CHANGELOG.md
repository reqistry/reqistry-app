# Changelog

All notable changes to Reqistry are documented here.

---

## [4.1.0] — 2026-08-04

### Summary

A major production push that restructured the entire codebase: migrated from GetX to BLoC, overhauled the design system, introduced a new Intelligence view, added push notifications via FCM, built a full project/bookmarks system, and polished every screen for production readiness.

**4 commits** — Aug 3–4, 2026 | **390 files changed** — 24,235 insertions / 12,102 deletions

---

### Architecture & Infrastructure

#### State Management Migration (GetX → BLoC)
- Migrated all controllers to BLoC/Cubit pattern — replaced 30+ GetX controllers and bindings with `flutter_bloc` cubits (`auth_cubit`, `api_detail_cubit`, `search_bloc`, `favorites_cubit`, `projects_cubit`, `privacy_cubit`, `notification_cubit`, etc.)
- Removed all GetX bindings, controllers, and extensions (~40+ files deleted)
- Added cubit states for every feature domain (auth, search, favorites, projects, categories, notifications, app settings, privacy, user activity)

#### Navigation Overhaul
- Migrated from GetX routing to `go_router` — new route definitions in `lib/config/routes.dart` with typed route parameters
- Removed legacy `app_pages.dart` and `app_routes.dart` (GetX-based)
- Added `auth_middleware.dart` for route-level authentication guards

#### Networking
- New `dio_client.dart` with auth token interceptor, connectivity interceptor, and error-toast interceptor
- New `auth_token_service.dart` for JWT/token lifecycle management
- Added `connectivity_service.dart` for offline-aware request retrying

#### Configuration
- Added `envied` for typed environment config — `.env` files with generated `env.g.dart`
- Created `.env.example` template for onboarding
- New `build.yaml` for code generation

#### Project Structure
- Reorganized into: `blocs/`, `data/models/`, `modules/views/`, `services/`, `utils/`, `shared/widgets/`
- New `config/` directory for routes, env, and app constants

---

### New Features

#### Intelligence View
- Brand-new `intelligence_view.dart` — dedicated screen for API intelligence/discovery
- Integrated into the main shell navigation

#### Push Notifications
- FCM-based push notifications via `fcm_service.dart` (399 lines)
- Local notifications via `local_notification_service.dart` with scheduled/triggered alerts
- New `notification_cubit.dart` for notification state management

#### Projects & Bookmarks
- Full project system — create, manage, and organize APIs into named projects
- New `project.dart` and `project_detail.dart` data models
- `projects_cubit.dart` for project CRUD operations
- `create_project_bottom_sheet.dart`, `project_card.dart`, `all_projects_view.dart`, `project_apis_view.dart`
- Bookmarks model (`bookmark_item.dart`) for saving APIs

#### Home View Redesign
- Completely rebuilt home screen with sections:
  - Latest APIs section with horizontal scrolling cards
  - User activity section
  - Continue work section
  - All projects view
- `home_view.dart` (438+ lines) with new widget architecture

#### Search Enhancements
- New `search_bloc.dart` with advanced filter support
- `advanced_filters_sheet.dart` — filter by auth type, HTTPS, CORS, pricing, category
- `search_header.dart` with quick filter chips
- `quick_filter_chip.dart` shared widget

#### API Detail Improvements
- Full API profile page with sections: description, quick facts, health checks, verification, warnings, docs links
- `api_detail_sections.dart` (622 lines) — rich section rendering
- `api_detail_actions.dart` — share, bookmark, open docs
- `api_detail_analytics.dart` for tracking views
- `api_detail_repository.dart` and `api_detail_source.dart` for data layer

#### API Collection View
- New `api_collection_view.dart` for browsing grouped APIs

---

### UI & Design System

#### Complete Design System
- New `app_colors.dart` (245 lines) — full color palette with light/dark theme support
- New `app_text_styles.dart` (82 lines) — typography scale
- New `app_spacing.dart` (32 lines) — spacing constants
- New `app_shadows.dart` (31 lines) — elevation styles
- New `theme_provider.dart` — dynamic theme switching

#### Shared Widget Library
- `app_cached_image.dart` — network image with placeholder and error handling
- `app_empty_state.dart` — empty state illustrations
- `app_error_state.dart` — error state with retry
- `app_loading.dart` — loading spinners
- `app_busy_overlay.dart` — full-screen busy indicator
- `app_dialog.dart` — styled alert dialogs
- `app_snackbar.dart` (405 lines) — rich notification toasts
- `api_badges.dart` — status/auth/HTTPS badges
- `status_dot.dart` — health status indicator
- `action_card.dart`, `info_row.dart`, `section_header.dart`
- `edit_name_sheet.dart` — profile name editing
- `action_card.dart` — reusable action cards

#### Screen Redesigns
- **Account Settings** — completely rebuilt with profile editing, theme toggle
- **App Settings** — redesigned with new sections and toggles
- **Auth View** — new onboarding flow with email/Google/guest sign-in
- **Favorites View** — enhanced with project organization
- **Category APIs** — improved layout and loading states
- **Contact View** — refreshed UI
- **Privacy View** — rebuilt with markdown rendering and offline fallback
- **Submit API** — redesigned submission form
- **Settings View** — complete overhaul with theme color picker

#### Visual Polish
- Animated gradient borders for category cards
- Pull-to-refresh on category and API lists
- Remote trendy categories with dynamic content
- Enhanced loading states with SpinKit animations

---

### Bug Fixes

#### Authentication
- Surfaced auth errors to users instead of silent failures
- Improved error handling in `auth_cubit.dart`

#### Privacy
- Added privacy policy fallback — cached locally for offline access
- New `privacy_cache_db.dart` for local privacy policy storage
- `privacy_cubit.dart` with graceful degradation

#### Similar APIs
- Fixed similar API thumbnails — images now load and display correctly
- Added image URL handling in `api_detail.dart`

#### Deep Linking
- Removed deep linking from AndroidManifest.xml to prevent crashes

#### General
- Fixed notification service initialization order
- Improved error states across all screens
- Fixed theme persistence and switching

---

### Code Quality & Cleanup

#### Dead Code Removal
- Deleted 40+ GetX controller/extension files
- Removed unused models: `app_color_theme.dart`, `category_box_option.dart`, `dialog_data.dart`, `fab_model.dart`, `filter_choice_option.dart`, `firestore_favorite.dart`, `grid_setting_view.dart`, `setting_option_model.dart`, `update_feature.dart`
- Removed `firestore_favorites_service.dart` and `firestore_favorites_binding.dart`
- Removed `metadata_service.dart` (200 lines)
- Removed `key_generators.dart`, `delay_helper.dart`, `dialog_helper.dart`
- Removed old color utilities (`Colors_helper.dart`, `colors.dart`)
- Removed text helpers, extension files, and nil widget
- Removed `ngrok` binary and shader cache files

#### Documentation
- Rewrote README.md — matches current product positioning as "API intelligence for builders and agents"
- Removed stale docs: `API_DETAIL_BACKEND_REQUIREMENTS.md`, `API_DOCUMENTATION.md`, `SEARCH_IMPLEMENTATION.md`
- Updated privacy policy content
- Added `openapi.mobile.json` (3,602 lines) — full API specification
- Added `matching_client_flutter/` with design system docs (COMPONENTS.json, DESIGN_SYSTEM.json, PAGES.json)

#### Testing
- Added `api_detail_cubit_test.dart` (81 lines)
- Added `api_detail_model_test.dart` (91 lines)
- Updated `widget_test.dart` for new architecture

#### Dependencies
- Added: `flutter_bloc`, `go_router`, `dio`, `envied`, `firebase_messaging`, `flutter_local_notifications`, `connectivity_plus`, `phosphoricons_flutter`, `flutter_markdown_plus`, `requests_inspector`, `device_preview_plus`
- Removed: `get` (GetX), `cloud_firestore`, old Firebase packages
- Updated `pubspec.yaml` with 70+ dependency changes

#### Android/iOS
- Migrated Android build files from Groovy to Kotlin DSL (`build.gradle.kts`)
- Updated `AndroidManifest.xml` — added notification permissions, removed deep links
- Updated Gradle properties and wrapper

---

### Marketing & Product

- Added `marketing_copy.md`, `marketing_plan.md`, `marketing_playbook.md` — go-to-market strategy docs
- Added `product/reqistry.md` — full product requirements document (1,420 lines)
- Updated store listing copy and positioning

---

## [4.0.0] — 2025-12-09

### Added
- New search tab with quick filters and faster, server-backed results
- Sign in with email, Google, or continue as guest
- Refreshed API cards, details, categories, and favorites for quicker save/view
- Settings upgrades (theme color, export favorites) plus API submit + recommendations
- Featured categories with animated gradient border and remote trendy categories
- Pull-to-refresh on category and API lists

### Changed
- Migrated Android build files from Groovy to Kotlin DSL
- Updated app icon and launcher resources
- Restructured data models for API responses

### Fixed
- Category grid rendering issues
- Search filter persistence

---

## [3.0.0] — 2022-12-13

### Added
- Initial public release
- Browse 1,400+ public APIs across 50+ categories
- Search with filters
- Favorites/bookmarks
- API detail pages
- Settings with theme options
