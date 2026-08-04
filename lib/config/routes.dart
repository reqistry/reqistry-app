import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/api_detail/api_detail_cubit.dart';
import 'package:api_scout/app/blocs/category_apis/category_apis_cubit.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_cubit.dart';
import 'package:api_scout/app/blocs/app_settings/app_settings_cubit.dart';
import 'package:api_scout/app/blocs/privacy/privacy_cubit.dart';
import 'package:api_scout/app/data/models/api.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/modules/views/auth/auth_view.dart';
import 'package:api_scout/app/modules/views/main_shell_view.dart';
import 'package:api_scout/app/modules/views/api_detail_view/api_detail_view.dart';
import 'package:api_scout/app/modules/views/category_apis_view/category_apis_view.dart';
import 'package:api_scout/app/modules/views/api_collection_view/api_collection_view.dart';
import 'package:api_scout/app/modules/views/project_apis_view/project_apis_view.dart';
import 'package:api_scout/app/modules/views/submit_api_view/submit_api_view.dart';
import 'package:api_scout/app/modules/views/privacy_view/privacy_view.dart';
import 'package:api_scout/app/modules/views/contact_view/contact_view.dart';
import 'package:api_scout/app/modules/views/account_settings_view/account_settings_view.dart';
import 'package:api_scout/app/modules/views/app_settings_view/app_settings_view.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';

import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
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
          final api = state.extra is Api ? state.extra as Api : null;
          final slug = state.pathParameters['slug'] ?? api?.slug ?? '';
          return BlocProvider(
            create: (_) => ApiDetailCubit(slug: slug, seed: api),
            child: ApiDetailView(slug: slug),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.legacyApiDetail,
        builder: (context, state) {
          final api = state.extra is Api ? state.extra as Api : null;
          if (api == null) {
            return const _ErrorPage(message: 'API data not found');
          }
          final slug =
              api.slug.isNotEmpty ? api.slug : slugifyApiName(api.name);
          return BlocProvider(
            create: (_) => ApiDetailCubit(slug: slug, seed: api),
            child: ApiDetailView(slug: slug),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categoryApis,
        builder: (context, state) {
          final extra = state.extra;
          return BlocProvider(
            create: (_) => CategoryApisCubit(argument: extra ?? ''),
            child: CategoryApisView(argument: extra ?? ''),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.projectApis,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Project) {
            return const _ErrorPage(message: 'Project data not found');
          }
          return ProjectApisView(project: extra);
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
    ],
  );
}

class _ErrorPage extends StatelessWidget {
  final String message;
  const _ErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      body: AppErrorState(
        title: 'Error',
        message: message,
        onRetry: () => context.go(AppRoutes.home),
        actionLabel: 'GO HOME',
      ),
    );
  }
}
