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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          const Icon(
            PhosphorIconsRegular.arrowsClockwise,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.s6),
          Text(
            'SYNCING',
            style: AppTextStyles.labelSmUpper.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
