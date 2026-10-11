import 'dart:io';

import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_state.dart';
import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/blocs/language/language_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_state.dart';
import 'package:api_scout/app/modules/views/main_shell_view.dart';
import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('api-scout-test');
    Hive.init(hiveDirectory.path);
    await Hive.openBox(BoxesConstants.locals);
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('general API search stays available across every shell tab',
      (tester) async {
    final shellCubit = _FakeMainShellCubit();
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const MainShellView()),
        GoRoute(
          path: AppRoutes.search,
          builder: (_, __) => const Scaffold(body: Text('API search route')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MainShellCubit>.value(value: shellCubit),
          BlocProvider<FavoritesCubit>.value(value: _FakeFavoritesCubit()),
          BlocProvider<ProjectsCubit>.value(value: _FakeProjectsCubit()),
          BlocProvider<UserActivityCubit>.value(
            value: _FakeUserActivityCubit(),
          ),
          BlocProvider<HomeCategoriesCubit>.value(
            value: _FakeHomeCategoriesCubit(),
          ),
          BlocProvider<AuthCubit>.value(value: _FakeAuthCubit()),
          BlocProvider<NotificationCubit>.value(
            value: _FakeNotificationCubit(),
          ),
          BlocProvider<LanguageCubit>.value(value: _FakeLanguageCubit()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();

    for (var tab = 0; tab < MainShellCubit.tabCount; tab++) {
      shellCubit.selectTab(tab);
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    }

    shellCubit.selectTab(0);
    await tester.pump();
    final homeFabBottom =
        tester.getRect(find.byType(FloatingActionButton)).bottom;
    shellCubit.selectTab(1);
    await tester.pump();
    final discoverFabBottom =
        tester.getRect(find.byType(FloatingActionButton)).bottom;
    expect(discoverFabBottom, lessThan(homeFabBottom));

    final fab = find.byKey(const Key('shell_search_fab'));
    final l10n = AppLocalizations.of(tester.element(fab))!;
    expect(find.byTooltip(l10n.formSearchHint), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('API search route'), findsOneWidget);
  });
}

class _FakeMainShellCubit extends Cubit<MainShellState>
    implements MainShellCubit {
  _FakeMainShellCubit() : super(const MainShellState(selectedTabIndex: 0));

  @override
  void selectTab(int index) => emit(MainShellState(selectedTabIndex: index));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFavoritesCubit extends Cubit<FavoritesState>
    implements FavoritesCubit {
  _FakeFavoritesCubit() : super(const FavoritesState());

  @override
  Future<void> loadBookmarks({AppLocalizations? l10n}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProjectsCubit extends Cubit<ProjectsState> implements ProjectsCubit {
  _FakeProjectsCubit() : super(const ProjectsState());

  @override
  Future<void> loadProjects({required AppLocalizations l10n}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserActivityCubit extends Cubit<UserActivityState>
    implements UserActivityCubit {
  _FakeUserActivityCubit() : super(const UserActivityState());

  @override
  void refresh() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeCategoriesCubit extends Cubit<HomeCategoriesState>
    implements HomeCategoriesCubit {
  _FakeHomeCategoriesCubit() : super(const HomeCategoriesState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const AuthInitial());

  @override
  String get userName => AuthCubit.guestName;

  @override
  String get userEmail => 'guest@example.com';

  @override
  bool get isGuestUser => true;

  @override
  UserProfile? get currentUserProfile => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationCubit extends Cubit<NotificationState>
    implements NotificationCubit {
  _FakeNotificationCubit() : super(const NotificationInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLanguageCubit extends Cubit<LanguageState> implements LanguageCubit {
  _FakeLanguageCubit() : super(const LanguageState(locale: Locale('en')));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
