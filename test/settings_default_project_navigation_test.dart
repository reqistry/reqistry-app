import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/blocs/language/language_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_state.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/modules/views/settings_view/settings_view.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Project APIs opens the first loaded project', (tester) async {
    final project = Project(
      id: 'first project',
      title: 'First',
      iconCodePoint: 0,
      createdAt: DateTime(2026),
    );
    await _pumpSettings(tester, projects: [project]);

    await tester.tap(find.byKey(const Key('settings_project_apis_stat')));
    await tester.pumpAndSettle();

    expect(find.text('project route: first project'), findsOneWidget);
  });

  testWidgets('Project APIs falls back to Projects when none are loaded',
      (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.byKey(const Key('settings_project_apis_stat')));
    await tester.pumpAndSettle();

    expect(find.text('all projects route'), findsOneWidget);
  });
}

Future<GoRouter> _pumpSettings(
  WidgetTester tester, {
  List<Project> projects = const [],
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SettingsView()),
      GoRoute(
        path: AppRoutes.allProjects,
        builder: (_, __) => const Text('all projects route'),
      ),
      GoRoute(
        path: AppRoutes.projectApis,
        builder: (_, state) => Text(
          'project route: ${state.pathParameters['id']}',
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _FakeAuthCubit()),
        BlocProvider<UserActivityCubit>.value(
          value: _FakeUserActivityCubit(),
        ),
        BlocProvider<ProjectsCubit>.value(
          value: _FakeProjectsCubit(projects),
        ),
        BlocProvider<LanguageCubit>.value(value: _FakeLanguageCubit()),
        BlocProvider<MainShellCubit>.value(value: _FakeMainShellCubit()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  return router;
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

class _FakeUserActivityCubit extends Cubit<UserActivityState>
    implements UserActivityCubit {
  _FakeUserActivityCubit() : super(const UserActivityState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProjectsCubit extends Cubit<ProjectsState> implements ProjectsCubit {
  _FakeProjectsCubit(List<Project> projects)
      : super(ProjectsState(projects: projects));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLanguageCubit extends Cubit<LanguageState> implements LanguageCubit {
  _FakeLanguageCubit() : super(const LanguageState(locale: Locale('en')));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMainShellCubit extends Cubit<MainShellState>
    implements MainShellCubit {
  _FakeMainShellCubit() : super(const MainShellState(selectedTabIndex: 4));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
