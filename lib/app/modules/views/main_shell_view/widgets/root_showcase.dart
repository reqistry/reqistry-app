import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// First-launch guided tour of the root shell.
///
/// Three steps max: submit CTA -> stats -> nav bar. Short on purpose;
/// feature tours live on their own screens (see [ApiDetailShowcase]).
/// Completion or skip/dismiss stores [_doneKey] so it never shows again.
class RootShowcase {
  RootShowcase._();

  static const _doneKey = 'rootOnboardingDone';

  static final GlobalKey navBarKey = GlobalKey();
  static final GlobalKey submitApiKey = GlobalKey();
  static final GlobalKey statsRowKey = GlobalKey();

  static bool _registered = false;
  static bool _running = false;

  /// True while the root tour is active; other tours wait for it.
  static bool get isRunning => _running;

  static bool get isDone => LocalsDB.instance.getWithKey(_doneKey) == true;

  static Future<void> markDone() =>
      LocalsDB.instance.putWithKey(_doneKey, true);

  /// Starts the tour on first launch only.
  static void maybeStart(BuildContext context) {
    if (isDone || _running) return;
    start(context);
  }

  /// Runs the full tour. Also used by the Settings "replay intro" action.
  static void start(BuildContext context) {
    if (_running) return;
    _running = true;
    ensureRegistered(context);

    ShowcaseView showcaseView;
    try {
      showcaseView = ShowcaseView.get();
    } catch (_) {
      _running = false;
      return;
    }
    final shell = context.read<MainShellCubit>();

    var finished = false;

    Future<void> complete() async {
      await markDone();
      shell.selectTab(AppRoutes.tabIndexHome);
    }

    late final VoidCallback onFinishHandler;
    late final void Function(GlobalKey?) onDismissHandler;

    void settle() {
      if (finished) return;
      finished = true;
      showcaseView.removeOnFinishCallback(onFinishHandler);
      showcaseView.removeOnDismissCallback(onDismissHandler);
      _running = false;
      complete();
    }

    onFinishHandler = settle;
    onDismissHandler = (_) => settle();

    showcaseView.addOnFinishCallback(onFinishHandler);
    showcaseView.addOnDismissCallback(onDismissHandler);

    shell.selectTab(AppRoutes.tabIndexHome);
    try {
      showcaseView.startShowCase(
        [
          submitApiKey,
          statsRowKey,
          navBarKey,
        ],
        delay: const Duration(milliseconds: 300),
      );
    } catch (_) {
      settle();
    }
  }

  /// Registers the shared showcase scope if not yet registered. Safe to call
  /// from any tour; styling and global actions apply app-wide.
  static void ensureRegistered(BuildContext context) {
    if (_registered) return;
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;

    ShowcaseView.register(
      skipIfTargetNotPresent: true,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: AppSpacing.s12,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          backgroundColor: c.onSurfaceVariant,
          textStyle: AppTextStyles.labelSm.copyWith(color: c.surface),
          borderRadius: BorderRadius.zero,
          name: l10n.actionPrevious,
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          backgroundColor: c.primary,
          textStyle: AppTextStyles.labelSm.copyWith(color: c.onPrimary),
          borderRadius: BorderRadius.zero,
          name: l10n.actionNext,
        ),
      ],
      globalFloatingActionWidget: (_) => FloatingActionWidget(
        left: AppSpacing.s16,
        bottom: AppSpacing.s24,
        child: ElevatedButton(
          onPressed: () async {
            await markDone();
            ShowcaseView.get().dismiss();
          },
          child: Text(l10n.actionSkip),
        ),
      ),
    );
    _registered = true;
  }

  /// Wraps a tour target with design-system tooltip styling.
  ///
  /// Registers the showcase scope on every build, before the wrapped
  /// [Showcase] initializes. This ordering is the whole crash fix:
  /// [Showcase] throws "No ShowcaseView is registered" when its scope
  /// has no registration, and tours used to register a frame too late.
  static Widget scope({
    required BuildContext context,
    required GlobalKey showcaseKey,
    required String title,
    required String description,
    required Widget child,
  }) {
    ensureRegistered(context);
    final c = AppColors.of(Theme.of(context).brightness);
    return Showcase(
      key: showcaseKey,
      title: title,
      description: description,
      titleTextStyle: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
      descTextStyle:
          AppTextStyles.bodyMd.copyWith(fontSize: 13, color: c.onSurface),
      tooltipBackgroundColor: c.surface,
      tooltipBorderRadius: BorderRadius.zero,
      targetPadding: const EdgeInsets.all(AppSpacing.s4),
      child: child,
    );
  }

  static void dispose() {
    if (!_registered) return;
    ShowcaseView.get().unregister();
    _registered = false;
  }
}
