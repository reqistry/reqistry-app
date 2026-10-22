import 'package:api_scout/app/data/models/agent_client_config.dart';
import 'package:api_scout/app/modules/views/agent_console_view/agent_console_view.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
