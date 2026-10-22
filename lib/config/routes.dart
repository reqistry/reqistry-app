import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/blocs/api_detail/api_detail_cubit.dart';
import 'package:api_scout/app/blocs/category_apis/category_apis_cubit.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_cubit.dart';
import 'package:api_scout/app/blocs/app_settings/app_settings_cubit.dart';
import 'package:api_scout/app/blocs/privacy/privacy_cubit.dart';
import 'package:api_scout/app/data/models/category_apis.dart' show ApiItem;
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/services/analytics/posthog_service.dart';
import 'package:api_scout/app/modules/views/auth/auth_view.dart';
import 'package:api_scout/app/modules/views/main_shell_view.dart';
import 'package:api_scout/app/modules/views/api_detail_view/api_detail_view.dart';
import 'package:api_scout/app/modules/views/category_apis_view/category_apis_view.dart';
import 'package:api_scout/app/modules/views/api_collection_view/api_collection_view.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/all_projects_view.dart';
import 'package:api_scout/app/modules/views/project_apis_view/project_apis_view.dart';
import 'package:api_scout/app/modules/views/submit_api_view/submit_api_view.dart';
import 'package:api_scout/app/modules/views/agent_console_view/agent_console_view.dart';
import 'package:api_scout/app/modules/views/submissions_view/submissions_view.dart';
import 'package:api_scout/app/modules/views/watchlists_view/watchlists_view.dart';
import 'package:api_scout/app/modules/views/privacy_view/privacy_view.dart';
import 'package:api_scout/app/modules/views/contact_view/contact_view.dart';
import 'package:api_scout/app/modules/views/account_settings_view/account_settings_view.dart';
import 'package:api_scout/app/modules/views/app_settings_view/app_settings_view.dart';
import 'package:api_scout/app/modules/views/notifications_view/notifications_view.dart';
import 'package:api_scout/app/modules/views/intelligence_view/widgets/compare_result_view.dart';
import 'package:api_scout/app/modules/views/change_feed_view/change_feed_view.dart';
import 'package:api_scout/app/modules/views/search_screen/search_screen.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/l10n/app_localizations.dart';

import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Destination decoded from a push data payload.
///
/// Pure decision logic lives in [parseNotificationAction] (unit-tested);
/// [routeNotificationTap] executes navigation plus an optional alert.
/// Payload shapes come from the backend worker (`apps/worker/src/notifications.ts`):
/// every value arrives as a string, unknown keys must fall through to [feed].
enum NotificationKind {
  apiDetail,
  compare,
  recommended,
  submitApi,
  exploreTab,
  homeTab,
  feed,
}

class NotificationAction {
  final NotificationKind kind;

  /// API slug for [NotificationKind.apiDetail].
  final String slug;

  /// API ids for [NotificationKind.compare].
  final List<String> apiIds;

  /// Show the notification title/body as an in-app alert after navigating.
  final bool alert;

  /// Error styling for the alert (trust drops). Info otherwise.
  final bool urgent;

  const NotificationAction({
    required this.kind,
    this.slug = '',
    this.apiIds = const [],
    this.alert = false,
    this.urgent = false,
  });
}

/// Pure decoder: FCM data map -> navigation action. Never throws.
@visibleForTesting
NotificationAction parseNotificationAction(Map<String, dynamic> data) {
  String text(Object? value) => value?.toString().trim() ?? '';
  const feed = NotificationAction(kind: NotificationKind.feed);

  switch (text(data['type'])) {
    case 'api_health':
    case 'new_api':
    case 'price_change':
    case 'trust_alert':
      final slug = text(data['apiSlug']);
      if (slug.isEmpty) return feed;
      final type = text(data['type']);
      return NotificationAction(
        kind: NotificationKind.apiDetail,
        slug: slug,
        alert: type == 'price_change' || type == 'trust_alert',
        urgent: type == 'trust_alert',
      );
    case 'weekly_digest':
      final ids = _parseIdList(data['apiIds']);
      if (ids.length >= 2) {
        return NotificationAction(
          kind: NotificationKind.compare,
          apiIds: ids,
          alert: true,
        );
      }
      return const NotificationAction(
        kind: NotificationKind.recommended,
        alert: true,
      );
    case 'community_reminder':
      switch (text(data['action'])) {
        case 'submit_api':
          return const NotificationAction(kind: NotificationKind.submitApi);
        case 'browse_apis':
          return const NotificationAction(kind: NotificationKind.exploreTab);
        default:
          // report_api and unknown actions carry no target context.
          return const NotificationAction(kind: NotificationKind.homeTab);
      }
    case 'report_update':
    case 'submission_update':
      final slug = text(data['apiSlug']);
      if (slug.isNotEmpty) {
        return NotificationAction(
          kind: NotificationKind.apiDetail,
          slug: slug,
          alert: true,
        );
      }
      return const NotificationAction(
        kind: NotificationKind.feed,
        alert: true,
      );
    default:
      return feed;
  }
}

/// Parses the backend's JSON-encoded id array, tolerating a bare
/// comma-separated string and non-string entries.
@visibleForTesting
List<String> parseNotificationIds(Object? raw) => _parseIdList(raw);

List<String> _parseIdList(Object? raw) {
  if (raw is List) {
    return [
      for (final e in raw)
        if (e.toString().trim().isNotEmpty) e.toString().trim(),
    ];
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return _parseIdList(decoded);
    } catch (_) {}
    return [
      for (final part in raw.split(','))
        if (part.trim().isNotEmpty) part.trim(),
    ];
  }
  return const [];
}

/// Route a notification data payload to the right screen.
///
/// [title]/[body] surface as an in-app alert for alertable types
/// (price, trust, digest, lifecycle updates). System-tray taps, local
/// taps and feed taps all funnel here.
void routeNotificationTap(
  Map<String, dynamic> data, {
  String? title,
  String? body,
}) {
  final action = parseNotificationAction(data);
  var routingResult = 'routed';
  switch (action.kind) {
    case NotificationKind.apiDetail:
      AppRouter.router.push(
        AppRoutes.apiDetailPath(action.slug, source: 'notification'),
      );
    case NotificationKind.compare:
      AppRouter.router.push(AppRoutes.comparePath(action.apiIds));
    case NotificationKind.recommended:
      AppRouter.router.push(AppRoutes.recommendedApis);
    case NotificationKind.submitApi:
      AppRouter.router.push(AppRoutes.submitApi);
    case NotificationKind.exploreTab:
      if (!_selectShellTab(AppRoutes.tabIndexSearch)) {
        routingResult = 'fallback_home_no_navigator';
      }
    case NotificationKind.homeTab:
      AppRouter.router.go(AppRoutes.home);
    case NotificationKind.feed:
      AppRouter.router.push(AppRoutes.notifications);
  }
  unawaited(PostHogService.instance.capture(
    'notification_open_routed',
    notificationRoutingProperties(data, action, routingResult),
  ));
  if (action.alert &&
      title?.trim().isNotEmpty == true &&
      body?.trim().isNotEmpty == true) {
    AppSnackbarManager.showGlobal(
      title: title!.trim(),
      message: body!.trim(),
      type: action.urgent ? AppSnackbarType.error : AppSnackbarType.info,
    );
  }
}

@visibleForTesting
Map<String, Object> notificationRoutingProperties(
  Map<String, dynamic> data,
  NotificationAction action,
  String routingResult,
) {
  const knownTypes = {
    'api_health',
    'new_api',
    'price_change',
    'trust_alert',
    'weekly_digest',
    'community_reminder',
    'report_update',
    'submission_update',
  };
  final rawType = data['type']?.toString().trim() ?? '';
  final type = knownTypes.contains(rawType) ? rawType : 'unknown';
  final hasSlug = data['apiSlug']?.toString().trim().isNotEmpty == true;
  final hasIds = _parseIdList(data['apiIds']).isNotEmpty;
  final targetPresent = hasSlug ||
      hasIds ||
      action.kind == NotificationKind.submitApi ||
      action.kind == NotificationKind.exploreTab ||
      action.kind == NotificationKind.homeTab;

  String fallbackReason = 'none';
  if (rawType.isEmpty) {
    fallbackReason = 'missing_type';
  } else if (type == 'unknown') {
    fallbackReason = 'unknown_type';
  } else if ({'api_health', 'new_api', 'price_change', 'trust_alert'}
          .contains(type) &&
      !hasSlug) {
    fallbackReason = 'missing_api_slug';
  } else if (type == 'weekly_digest' &&
      _parseIdList(data['apiIds']).length < 2) {
    fallbackReason = 'insufficient_compare_ids';
  } else if ({'report_update', 'submission_update'}.contains(type) &&
      !hasSlug) {
    fallbackReason = 'missing_api_slug';
  } else if (type == 'community_reminder' &&
      !{'submit_api', 'browse_apis', 'report_api'}
          .contains(data['action']?.toString().trim())) {
    fallbackReason = 'unknown_action';
  }

  return {
    'notification_type': type,
    'destination_kind': action.kind.name,
    'target_present': targetPresent,
    'fallback_reason': fallbackReason,
    'routing_result': routingResult,
  };
}

bool _selectShellTab(int index) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    AppRouter.router.go(AppRoutes.home);
    return false;
  }
  // Notifications can arrive on top of pushed routes (detail, feed).
  // Land on the shell first so the tab change is visible.
  if (AppRouter.router.state.matchedLocation != AppRoutes.home) {
    AppRouter.router.go(AppRoutes.home);
  }
  context.read<MainShellCubit>().selectTab(index);
  return true;
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [PosthogObserver()],
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authCubit = context.read<AuthCubit>();
      final hasActiveSession = authCubit.hasActiveSession;
      final isAuthRoute = state.matchedLocation == AppRoutes.auth;

      if (!hasActiveSession && !isAuthRoute) {
        final requestedPath = state.uri.hasQuery
            ? '${state.uri.path}?${state.uri.query}'
            : state.uri.path;
        final returnTo = Uri.encodeQueryComponent(requestedPath);
        return '${AppRoutes.auth}?returnTo=$returnTo';
      }

      if (hasActiveSession && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    onException: (context, state, router) {
      router.go(AppRoutes.home);
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => AuthView(
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainShellView(),
      ),
      GoRoute(
        path: AppRoutes.apiDetail,
        builder: (context, state) {
          final api = state.extra is ApiItem ? state.extra as ApiItem : null;
          final slug = state.pathParameters['slug'] ?? '';
          return BlocProvider(
            create: (_) => ApiDetailCubit(slug: slug, seed: api),
            child: ApiDetailView(
              slug: slug,
              sourceScreen: state.uri.queryParameters['source'] ?? 'unknown',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categoryApis,
        builder: (context, state) {
          final extra = state.extra;
          final l10n = AppLocalizations.of(context);
          return BlocProvider(
            create: (_) => CategoryApisCubit(argument: extra ?? '', l10n: l10n),
            child: CategoryApisView(argument: extra ?? ''),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.allProjects,
        builder: (context, state) => const AllProjectsView(),
      ),
      GoRoute(
        path: AppRoutes.projectApis,
        builder: (context, state) {
          final extra = state.extra;
          return ProjectApisView(
            projectId: state.pathParameters['id'] ?? '',
            project: extra is Project ? extra : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.latestApis,
        builder: (context, state) => const ApiCollectionView(
          kind: ApiCollectionKind.latest,
        ),
      ),
      GoRoute(
        path: AppRoutes.recommendedApis,
        builder: (context, state) => const ApiCollectionView(
          kind: ApiCollectionKind.recommended,
        ),
      ),
      GoRoute(
        path: AppRoutes.submitApi,
        builder: (context, state) => BlocProvider(
          create: (_) => SubmitApiCubit(),
          child: const SubmitApiView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.agentConsole,
        builder: (context, state) => AgentConsoleView(
          apiSlug: state.uri.queryParameters['api'],
        ),
      ),
      GoRoute(
        path: AppRoutes.submissions,
        builder: (context, state) => const SubmissionsView(),
      ),
      GoRoute(
        path: AppRoutes.watchlists,
        builder: (context, state) => const WatchlistsView(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => BlocProvider(
          create: (_) => PrivacyCubit()..loadPrivacyContent(),
          child: const PrivacyView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.contact,
        builder: (context, state) => const ContactView(),
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (context, state) => const AccountSettingsView(),
      ),
      GoRoute(
        path: AppRoutes.appSettings,
        builder: (context, state) => BlocProvider(
          create: (_) => AppSettingsCubit(),
          child: const AppSettingsView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: AppRoutes.compare,
        builder: (context, state) {
          final extra = state.extra;
          final apiIds =
              extra is List<String> ? extra : AppRoutes.compareIds(state.uri);
          if (apiIds.length < 2) {
            return const _ErrorPage(messageKey: 'errorApiDataNotFound');
          }
          return CompareResultView(apiIds: apiIds);
        },
      ),
      GoRoute(
        path: AppRoutes.changeFeed,
        builder: (context, state) => const ChangeFeedView(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
}

class _ErrorPage extends StatelessWidget {
  final String messageKey;
  const _ErrorPage({required this.messageKey});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final message = messageKey == 'errorApiDataNotFound'
        ? l10n.errorApiDataNotFound
        : l10n.errorProjectDataNotFound;
    return Scaffold(
      backgroundColor: c.background,
      body: AppErrorState(
        title: l10n.stateError,
        message: message,
        onRetry: () => context.go(AppRoutes.home),
        actionLabel: l10n.actionGoHome,
      ),
    );
  }
}
