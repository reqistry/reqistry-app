import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/modules/views/favorites_view/favorites_view.dart';
import 'package:api_scout/app/modules/views/watchlists_view/widgets/create_keyword_watch_sheet.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets('Saved tab exposes Watchlists entry', (tester) async {
    final cubit = FavoritesCubit(dio: Dio());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: _app(const FavoritesView()),
      ),
    );

    expect(find.text('Watchlists'), findsOneWidget);
    expect(
      find.text('Track keywords, categories, and projects'),
      findsOneWidget,
    );
  });

  testWidgets('keyword watch requires at least two characters', (tester) async {
    await tester.pumpWidget(
      _app(const Scaffold(body: CreateKeywordWatchSheet())),
    );

    FilledButton button() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Create watch'),
        );

    expect(button().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    expect(button().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'ai');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });
}
