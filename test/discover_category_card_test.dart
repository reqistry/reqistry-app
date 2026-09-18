import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/modules/views/discover_view/widgets/discover_category_card.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, Category category) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: DiscoverCategoryCard(category: category),
          ),
        ),
      ),
    );
  }

  testWidgets('trending card shows banner strip with count', (tester) async {
    await pumpCard(
      tester,
      Category(
        id: 'ai',
        name: 'Machine Learning',
        apiCount: 42,
        hasTrendyBorder: true,
      ),
    );

    expect(find.text('TRENDING'), findsOneWidget);
    expect(find.text('42 APIS'), findsOneWidget);
    expect(find.text('Machine Learning'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plain card shows count but no trending strip',
      (tester) async {
    await pumpCard(
      tester,
      Category(id: 'ai', name: 'Machine Learning', apiCount: 42),
    );

    expect(find.text('TRENDING'), findsNothing);
    expect(find.text('42 APIS'), findsOneWidget);
    expect(find.text('Machine Learning'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
