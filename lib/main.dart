import 'dart:async';

import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:requests_inspector/requests_inspector.dart';

import 'app/blocs/auth/auth_cubit.dart';
import 'app/blocs/projects/projects_cubit.dart';
import 'app/blocs/home_categories/home_categories_cubit.dart';
import 'app/blocs/main_shell/main_shell_cubit.dart';
import 'app/blocs/notification/notification_cubit.dart';
import 'app/blocs/search/search_bloc.dart';
import 'app/blocs/favorites/favorites_cubit.dart';
import 'app/blocs/user_activity/user_activity_cubit.dart';
import 'app/blocs/language/language_cubit.dart';
import 'app/services/connectivity/connectivity_service.dart';
import 'app/services/notification/fcm_service.dart';
import 'config/env.dart';
import 'config/routes.dart';
import 'app/services/main_init_service.dart/main_init.dart';
import 'app/utils/snackbar_helper.dart';
import 'app/utils/theme_provider.dart';
import 'app/utils/themes.dart';
import 'app/widgets/app_overlay_host.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MainInit().init();
  ThemeProvider.instance.init();
  ConnectivityService.instance.init();
  AppSnackBarHelper.setNavigatorKey(rootNavigatorKey);
  FcmService.onNotificationTap = routeNotificationTap;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  if (kIsWeb == false) {
    final dispatcher = PlatformDispatcher.instance;
    dispatcher.onError = (error, stack) {
      debugPrint('Uncaught platform error: $error');
      return true;
    };
  }

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (_) => kDebugMode
          ? RequestsInspector(
              child: const ApiScoutApp(),
            )
          : const ApiScoutApp(),
    ),
  );
}

class ApiScoutApp extends StatelessWidget {
  const ApiScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => MainShellCubit()),
        BlocProvider(create: (_) => HomeCategoriesCubit()),
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => FavoritesCubit()),
        BlocProvider(create: (_) => ProjectsCubit()),
        BlocProvider(create: (_) => NotificationCubit()),
        BlocProvider(
          create: (context) => UserActivityCubit(
            authCubit: context.read<AuthCubit>(),
            favoritesCubit: context.read<FavoritesCubit>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, langState) {
              return ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeProvider.instance.themeNotifier,
                builder: (context, themeMode, _) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    restorationScopeId: 'api_scout',
                    title: Env.appName,
                    theme: AppThemes.lightTheme,
                    darkTheme: AppThemes.darkTheme,
                    themeMode: themeMode,
                    routerConfig: AppRouter.router,
                    locale: langState.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    builder: (context, child) {
                      child = DevicePreview.appBuilder(
                        context,
                        child ?? const SizedBox.shrink(),
                      );

                      final l10n = AppLocalizations.of(context);
                      if (l10n != null) {
                        ConnectivityService.instance.setLocalizations(l10n);
                      }

                      return AppOverlayHost(child: child);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
