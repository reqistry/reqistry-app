import 'package:api_scout/app/modules/views/home_view/home_view.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  testWidgets('logo opens the exact Reqistry URL in an external application',
      (tester) async {
    Uri? launchedUri;
    LaunchMode? launchedMode;

    await _pumpHome(
      tester,
      urlLauncher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchedUri = uri;
        launchedMode = mode;
        return true;
      },
    );

    await tester.tap(find.byTooltip('Open website'));
    await tester.pump();

    expect(launchedUri, Uri.parse('https://reqistry.dev'));
    expect(launchedMode, LaunchMode.externalApplication);
  });

  testWidgets('logo reports launcher exceptions through the error snackbar',
      (tester) async {
    await _pumpHome(
      tester,
      urlLauncher: (_, {mode = LaunchMode.platformDefault}) async {
        throw Exception('platform launch failed');
      },
    );

    await tester.tap(find.byTooltip('Open website'));
    await tester.pump();

    expect(AppSnackbarManager.payload.value?.title, 'Unavailable');
    expect(AppSnackbarManager.payload.value?.message, 'Could not open link');
    expect(AppSnackbarManager.payload.value?.type, AppSnackbarType.error);
    AppSnackbarManager.dismissGlobal();
  });

  testWidgets('logo reports a false launch result through the error snackbar',
      (tester) async {
    await _pumpHome(
      tester,
      urlLauncher: (_, {mode = LaunchMode.platformDefault}) async => false,
    );

    await tester.tap(find.byTooltip('Open website'));
    await tester.pump();

    expect(AppSnackbarManager.payload.value?.title, 'Unavailable');
    expect(AppSnackbarManager.payload.value?.message, 'Could not open link');
    expect(AppSnackbarManager.payload.value?.type, AppSnackbarType.error);
    AppSnackbarManager.dismissGlobal();
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required Future<bool> Function(Uri, {LaunchMode mode}) urlLauncher,
}) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  AppSnackBarHelper.setNavigatorKey(navigatorKey);
  AppSnackbarManager.dismissGlobal();
  addTearDown(AppSnackbarManager.dismissGlobal);

  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ReqistryLogoButton(urlLauncher: urlLauncher),
      ),
    ),
  );
  await tester.pump();
}
