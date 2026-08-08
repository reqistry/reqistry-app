import 'package:api_scout/app/data/models/api.dart' as legacy;
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_sections.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('quick facts expose unknown values at large text size',
      (tester) async {
    final detail = ApiDetail.fromApi(
      legacy.Api(
        id: 'api-1',
        name: 'Example API',
        description: 'Example data',
        auth: '',
        https: false,
        cors: false,
        link: 'https://example.com/v1',
        categoryId: 'Development',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(child: ApiQuickFacts(detail: detail)),
          ),
        ),
      ),
    );

    expect(find.text('Authentication'), findsOneWidget);
    expect(find.text('HTTPS'), findsOneWidget);
    expect(find.text('Unknown'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
