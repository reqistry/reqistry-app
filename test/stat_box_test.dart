import 'package:api_scout/app/modules/views/settings_view/widgets/stat_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a compact action and keeps the whole narrow card tappable',
      (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 104,
            child: StatBox(
              label: 'Project APIs',
              value: '12',
              actionLabel: 'OPEN',
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('OPEN'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(StatBox));
    await tester.pump();

    expect(taps, 1);
  });
}
