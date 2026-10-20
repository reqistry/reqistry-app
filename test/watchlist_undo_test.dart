import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/modules/views/watchlists_view/watchlists_view.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/widgets/app_overlay_host.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final client = DioClient();
  late List<Interceptor> originalInterceptors;
  late List<Map<String, dynamic>> watches;
  var nextId = 100;

  setUp(() {
    watches = [
      {'id': 'w1', 'kind': 'keyword', 'value': 'ai'},
      {'id': 'w2', 'kind': 'keyword', 'value': 'weather'},
    ];
    originalInterceptors = client.dio.interceptors.toList();
    client.dio.interceptors.removeRange(1, client.dio.interceptors.length);
    client.dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) {
      final path = options.uri.path;
      if (options.method == 'GET' && path == '/v1/watchlists') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'data': watches},
        ));
      } else if (options.method == 'DELETE' &&
          path.startsWith('/v1/watchlists/')) {
        watches.removeWhere((w) => w['id'] == path.split('/').last);
        handler.resolve(Response(requestOptions: options, statusCode: 204));
      } else if (options.method == 'POST' && path == '/v1/watchlists') {
        final data = Map<String, dynamic>.from(options.data as Map);
        final item = {
          'id': 'w${nextId++}',
          'kind': data['kind'],
          'value': data['value'],
        };
        watches.add(item);
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: {'data': item},
        ));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {},
        ));
      }
    }));
  });

  tearDown(() {
    client.dio.interceptors.clear();
    client.dio.interceptors.addAll(originalInterceptors);
  });

  testWidgets('swipe-delete offers undo that restores the watch',
      (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    AppSnackBarHelper.setNavigatorKey(navigatorKey);
    final projects = _FakeProjectsCubit();
    addTearDown(projects.close);

    await tester.pumpWidget(
      BlocProvider<ProjectsCubit>.value(
        value: projects,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              AppOverlayHost(child: child ?? const SizedBox.shrink()),
          home: const WatchlistsView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ai'), findsOneWidget);
    // Swipe is the only delete affordance; no duplicate trash button.
    expect(find.byTooltip('Delete'), findsNothing);

    await tester.fling(find.text('ai'), const Offset(-500, 0), 1000);
    // Bounded pumps: pumpAndSettle would fast-forward past the snackbar's
    // 3s auto-dismiss before it can be asserted or tapped.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(watches.map((w) => w['id']), ['w2']);
    expect(find.text('ai'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('ai'), findsOneWidget);
    // Let the snackbar's own timer expire so no work is left pending.
    await tester.pump(const Duration(seconds: 4));
  });
}

class _FakeProjectsCubit extends Cubit<ProjectsState> implements ProjectsCubit {
  _FakeProjectsCubit() : super(const ProjectsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
