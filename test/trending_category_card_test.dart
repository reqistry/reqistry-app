import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/trending_category_card.dart';
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
            width: 184,
            height: 156,
            child: TrendingCategoryCard(
              category: category,
              rank: 1,
              total: 4,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('trending card shows rank, name, and count',
      (tester) async {
    await pumpCard(
      tester,
      Category(id: 'ai', name: 'Machine Learning', apiCount: 42),
    );

    expect(find.text('01'), findsOneWidget);
    expect(find.text('Machine Learning'), findsOneWidget);
    expect(find.text('42 APIS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trending card announces rank position once', (tester) async {
    await pumpCard(
      tester,
      Category(id: 'ai', name: 'Machine Learning', apiCount: 42),
    );

    final semantics = tester.getSemantics(find.byType(TrendingCategoryCard));
    expect(semantics.label, contains('Machine Learning'));
    expect(semantics.label, contains('01/4'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('trending card survives narrow widths', (tester) async {
    tester.view.physicalSize = const Size(640, 1200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpCard(
      tester,
      Category(
        id: 'ai',
        name: 'A Very Long Category Name That Must Ellipsize Gracefully',
        apiCount: 0,
      ),
    );
    await tester.pump();

    expect(find.text('0 APIS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
