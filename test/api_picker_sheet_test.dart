import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/data/models/apis_search_response.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
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
    expect(find.text('2 of 4 selected'), findsOneWidget);

    final compareButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Compare 2'),
    );
    expect(compareButton.onPressed, isNotNull);
  });

  testWidgets('picker search records one logical search', (tester) async {
    final cubit = FavoritesCubit(dio: Dio());
    addTearDown(cubit.close);
    final tracked = <(String, int)>[];

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ApiPickerSheet(
              initiallySelected: const [],
              search: (_) async => SearchResponse(
                count: 1,
                pagination: SearchPagination(
                  page: 1,
                  limit: 20,
                  total: 1,
                  totalPages: 1,
                ),
                data: [
                  ApiItem(
                    id: 'weather',
                    name: 'Weather API',
                    description: '',
                    auth: 'None',
                    https: 'true',
                    cors: 'yes',
                    link: 'https://weather.example',
                    category: 'Weather',
                    apiType: 'REST',
                    pricing: 'Free',
                    rateLimit: 'Unknown',
                    documentation: '',
                    isAlive: true,
                    responseTime: 100,
                    lastChecked: '',
                  ),
                ],
              ),
              trackSearch: (query, count) => tracked.add((query, count)),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'weather');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Weather API'), findsOneWidget);
    expect(tracked, [('weather', 1)]);
  });

  testWidgets('selection stops at the comparison cap', (tester) async {
    final cubit = FavoritesCubit(dio: Dio());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ApiPickerSheet(
              initiallySelected: const [],
              search: (_) async => SearchResponse(
                count: 5,
                pagination: SearchPagination(
                  page: 1,
                  limit: 20,
                  total: 5,
                  totalPages: 1,
                ),
                data: [
                  for (var i = 1; i <= 5; i++)
                    ApiItem(
                      id: 'api$i',
                      name: 'API $i',
                      description: '',
                      auth: 'None',
                      https: 'true',
                      cors: 'yes',
                      link: 'https://api$i.example',
                      category: 'Testing',
                      apiType: 'REST',
                      pricing: 'Free',
                      rateLimit: 'Unknown',
                      documentation: '',
                      isAlive: true,
                      responseTime: 100,
                      lastChecked: '',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'api');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    for (var i = 1; i <= 4; i++) {
      await tester.tap(find.text('API $i'));
      await tester.pump();
    }
    expect(find.text('4 of 4 selected'), findsOneWidget);

    await tester.tap(find.text('API 5'));
    await tester.pump();
    expect(find.text('4 of 4 selected'), findsOneWidget);
  });
}
