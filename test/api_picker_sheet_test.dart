import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/modules/views/intelligence_view/widgets/api_picker_sheet.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('restores selected API details and enables comparison',
      (tester) async {
    final cubit = FavoritesCubit(dio: Dio());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ApiPickerSheet(
              initiallySelected: [
                CompareCandidate(
                  id: 'stripe',
                  name: 'Stripe API',
                  category: 'Payments',
                ),
                CompareCandidate(
                  id: 'github',
                  name: 'GitHub API',
                  category: 'Development',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Stripe API'), findsOneWidget);
    expect(find.text('GitHub API'), findsOneWidget);
    expect(find.text('2 of 8 selected'), findsOneWidget);

    final compareButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Compare 2'),
    );
    expect(compareButton.onPressed, isNotNull);
  });
}
