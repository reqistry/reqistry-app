import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/modules/views/search_screen/widgets/search_header.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('short submitted search shows localized feedback',
      (tester) async {
    final bloc = SearchBloc();
    final controller = TextEditingController(text: 'ab');
    addTearDown(bloc.close);
    addTearDown(controller.dispose);
    addTearDown(AppSnackbarManager.dismissGlobal);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: SearchHeader(searchController: controller)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'ab');
    await tester.testTextInput.receiveAction(TextInputAction.search);

    expect(AppSnackbarManager.payload.value?.title, 'Keep typing');
    expect(
      AppSnackbarManager.payload.value?.message,
      'Enter at least 3 characters to search.',
    );
    expect(bloc.state.hasSearched, isFalse);
    AppSnackbarManager.dismissGlobal();
  });
}
