import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:api_scout/app/modules/views/main_shell_view/widgets/root_showcase.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

/// One-time guided tour of the API detail page:
/// metadata header -> save-to-project. Runs once per install;
/// skipped or dismissed counts as done. Bookmark stays untargeted:
/// icon tooltip already explains it.
class ApiDetailShowcase {
  ApiDetailShowcase._();

  static const _doneKey = 'apiDetailOnboardingDone';
  static const _startDelay = Duration(milliseconds: 500);

  static final GlobalKey identityHeaderKey = GlobalKey();
  static final GlobalKey addToProjectKey = GlobalKey();

  static bool _running = false;

  static bool get isDone => LocalsDB.instance.getWithKey(_doneKey) == true;

  static Future<void> markDone() =>
      LocalsDB.instance.putWithKey(_doneKey, true);

  /// Clears completion so the Settings "replay intro" path replays
  /// this tour on the next detail visit.
  static Future<void> resetForReplay() =>
      LocalsDB.instance.putWithKey(_doneKey, false);

  /// Starts the tour on first detail visit; no-op while the root tour runs.
  static void maybeStart(BuildContext context) {
    if (isDone || _running || RootShowcase.isRunning) return;
    _running = true;
    RootShowcase.ensureRegistered(context);

    ShowcaseView showcaseView;
    try {
      showcaseView = ShowcaseView.get();
    } catch (_) {
      _running = false;
      return;
    }

    late final VoidCallback onFinishHandler;
    late final void Function(GlobalKey?) onDismissHandler;

    void finish() {
      showcaseView.removeOnFinishCallback(onFinishHandler);
      showcaseView.removeOnDismissCallback(onDismissHandler);
      _running = false;
      markDone();
    }

    onFinishHandler = finish;
    onDismissHandler = (_) => finish();

    showcaseView.addOnFinishCallback(onFinishHandler);
    showcaseView.addOnDismissCallback(onDismissHandler);

    try {
      showcaseView.startShowCase(
        [identityHeaderKey, addToProjectKey],
        delay: _startDelay,
      );
    } catch (_) {
      finish();
    }
  }
}
