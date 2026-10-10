import 'dart:async';

import 'package:api_scout/app/data/models/api_report_result.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/report_issue_sheet.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('report sheet shows progress and announces failure',
      (tester) async {
    final response = Completer<ApiReportResult?>();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ReportIssueSheet(onSubmit: (_, __) => response.future),
        ),
      ),
    );

    final submit = find.text('Submit report');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Loading...'), findsOneWidget);

    response.complete(null);
    await tester.pump();

    expect(
      find.text('The request could not be completed. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Submit report'), findsOneWidget);
  });
}
