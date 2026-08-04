import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class AppBusyOverlay {
  AppBusyOverlay._();

  static final ValueNotifier<bool> visible = ValueNotifier(false);
  static Timer? _showTimer;
  static int _activeCount = 0;

  static void show() {
    _activeCount++;
    if (visible.value || _showTimer != null) return;
    _showTimer = Timer(const Duration(milliseconds: 150), () {
      _showTimer = null;
      if (_activeCount > 0) visible.value = true;
    });
  }

  static void hide() {
    if (_activeCount > 0) _activeCount--;
    if (_activeCount > 0) return;
    _showTimer?.cancel();
    _showTimer = null;
    visible.value = false;
  }
}

class AppBusyIndicator extends StatelessWidget {
  const AppBusyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: c.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Icon(
            PhosphorIconsRegular.arrowsClockwise,
            size: 14,
            color: c.primary,
          ),
          const SizedBox(width: AppSpacing.s6),
          Text(
            'SYNCING',
            style: AppTextStyles.labelSmUpper.copyWith(
              color: c.primary,
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
