import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/data/models/agent_client_config.dart';
import 'package:api_scout/app/modules/views/agent_console_view/agent_console_view.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/agent_keys_section.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  Future<void> pumpConsole(
    WidgetTester tester, {
    Future<AgentClientConfig>? configFuture,
    String? apiSlug,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AgentConsoleView(
          configFuture: configFuture,
          apiSlug: apiSlug,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<AgentClientConfig> resolved(Future<AgentClientConfig>? future) async =>
      await (future ?? Future<AgentClientConfig>.value(AgentClientConfig.fallback));

  testWidgets('falls back honestly and puts tasks before connect setup',
      (tester) async {
    await pumpConsole(tester, configFuture: resolved(null));

    final tasksRect =
        tester.getRect(find.text('Try a real task'));
    final connectRect = tester.getRect(find.text('Connect your agent'));
    expect(tasksRect.center.dy, lessThan(connectRect.center.dy));

    // Honest provenance: no server config available in this scenario.
    expect(
      find.byKey(const ValueKey('agent_config_fallback_notice')),
      findsOneWidget,
    );
  });

  testWidgets('shows one client at a time, switchable by chip', (tester) async {
    final config = AgentClientConfig.fromJson(
        {'mcpUrl': 'https://mcp.example.com/mcp'});
    await pumpConsole(tester, configFuture: resolved(Future.value(config)));

    // First client selected by default; only one snippet visible.
    expect(find.textContaining('claude mcp add'), findsOneWidget);
    expect(find.textContaining('.cursor/mcp.json'), findsNothing);
    // Server-provided endpoint is not flagged as fallback.
    expect(
      find.byKey(const ValueKey('agent_config_fallback_notice')),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Cursor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cursor'));
    await tester.pumpAndSettle();

    expect(find.textContaining('.cursor/mcp.json'), findsOneWidget);
    expect(find.textContaining('claude mcp add'), findsNothing);
  });

  testWidgets('slug from API detail produces an evaluate task with the slug',
      (tester) async {
    await pumpConsole(tester, configFuture: resolved(null), apiSlug: 'weather-api');

    await tester.ensureVisible(find.text('Evaluate weather-api'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evaluate weather-api'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Evaluate the weather-api API'),
      findsOneWidget,
    );
    expect(find.textContaining('get_api_trust_score'), findsWidgets);
    expect(find.textContaining('weather-api'), findsWidgets);
  });

  testWidgets('keys stay collapsed and unfetched until expanded',
      (tester) async {
    // Resolve the authed keys list locally: the pinned behavior is that the
    // fetch only starts after the section is expanded, not its payload.
    final client = DioClient();
    final originalInterceptors = client.dio.interceptors.toList();
    client.dio.interceptors.removeRange(1, client.dio.interceptors.length);
    client.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: const {'data': []},
        ));
      },
      onError: (error, handler) => handler.next(error),
    ));
    addTearDown(() {
      client.dio.interceptors
        ..clear()
        ..addAll(originalInterceptors);
    });

    await pumpConsole(tester, configFuture: resolved(null));

    expect(find.byType(AgentKeysSection), findsNothing);

    await tester.dragUntilVisible(
      find.text('Agent API keys'),
      find.byType(ListView).first,
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agent API keys'));
    await tester.pumpAndSettle();

    expect(find.byType(AgentKeysSection), findsOneWidget);
  });

  testWidgets('empty apiSlug renders no evaluate task', (tester) async {
    await pumpConsole(tester, configFuture: resolved(null), apiSlug: '');

    expect(find.textContaining('Evaluate'), findsNothing);
  });
}
