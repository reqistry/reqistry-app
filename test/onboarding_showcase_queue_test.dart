import 'dart:io';

import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/modules/views/auth/widgets/onboarding_scaffold.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_showcase.dart';
import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('reqistry-tour-test');
    Hive.init(hiveDirectory.path);
    await Hive.openBox(BoxesConstants.locals);
  });

  setUp(() => LocalsDB.instance.clear());

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets('starting as a guest queues the first shell tour',
      (tester) async {
    final auth = _FakeAuthCubit();
    addTearDown(auth.close);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScaffold(),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final dynamic onPressed = button.onPressed;
    await tester.runAsync(() async => onPressed());

    expect(
      LocalsDB.instance.getWithKey('rootOnboardingPending'),
      isTrue,
    );
    expect(auth.continueCalls, 1);
  });

  group('ApiDetailShowcase gate', () {
    bool shouldStart({bool? detailDone, bool rootDone = true}) =>
        ApiDetailShowcase.shouldStart(
          detailDone: detailDone ?? false,
          rootDone: rootDone,
          running: false,
          rootRunning: false,
        );

    test('starts on a first detail visit after the root tour', () {
      expect(shouldStart(), isTrue);
    });

    test('starts when Settings reset the tour for replay', () {
      expect(shouldStart(detailDone: false), isTrue);
    });

    test('does not start twice or before the root tour', () {
      expect(shouldStart(detailDone: true), isFalse);
      expect(shouldStart(rootDone: false), isFalse);
    });

    test('waits while either tour is running', () {
      expect(
        ApiDetailShowcase.shouldStart(
          detailDone: false,
          rootDone: true,
          running: true,
          rootRunning: false,
        ),
        isFalse,
      );
      expect(
        ApiDetailShowcase.shouldStart(
          detailDone: false,
          rootDone: true,
          running: false,
          rootRunning: true,
        ),
        isFalse,
      );
    });
  });
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const Unauthenticated());

  int continueCalls = 0;

  @override
  Future<void> continueAsGuest({required AppLocalizations l10n}) async {
    continueCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
