import 'dart:async';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:api_scout/app/modules/views/main_shell_view/widgets/root_showcase.dart';
import 'package:api_scout/app/services/analytics/posthog_service.dart';
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
  static Future<void> resetForReplay() {
    return LocalsDB.instance.putWithKey(_doneKey, false);
  }

  /// A missing completion key (null) counts as not done; Settings replay
  /// resets it to false.
  @visibleForTesting
  static bool shouldStart({
    required bool detailDone,
    required bool rootDone,
    required bool running,
    required bool rootRunning,
  }) =>
      !detailDone && rootDone && !running && !rootRunning;

  /// Starts once after the root tour, or after Settings resets this tour.
  static void maybeStart(BuildContext context) {
    if (!shouldStart(
      detailDone: isDone,
      rootDone: RootShowcase.isDone,
      running: _running,
      rootRunning: RootShowcase.isRunning,
    )) {
      return;
    }
    _running = true;
    RootShowcase.ensureRegistered(context);
    unawaited(
      PostHogService.instance
          .capture('onboarding_tour_started', {'tour': 'api_detail'}),
    );

    ShowcaseView showcaseView;
    try {
      showcaseView = ShowcaseView.get();
    } catch (_) {
      _running = false;
      return;
    }

    late final VoidCallback onFinishHandler;
    late final void Function(GlobalKey?) onDismissHandler;
    var finished = false;

    void finish({required bool completed}) {
      if (finished) return;
      finished = true;
      _running = false;
      unawaited(
        PostHogService.instance.capture(
          completed ? 'onboarding_tour_completed' : 'onboarding_tour_skipped',
          {'tour': 'api_detail'},
        ),
      );
      unawaited(markDone());
      scheduleMicrotask(() {
        showcaseView.removeOnFinishCallback(onFinishHandler);
        showcaseView.removeOnDismissCallback(onDismissHandler);
      });
    }

    onFinishHandler = () => finish(completed: true);
    onDismissHandler = (_) => finish(completed: false);

    showcaseView.addOnFinishCallback(onFinishHandler);
    showcaseView.addOnDismissCallback(onDismissHandler);

    try {
      showcaseView.startShowCase(
        [identityHeaderKey, addToProjectKey],
        delay: _startDelay,
      );
    } catch (_) {
      finish(completed: false);
    }
  }
}
