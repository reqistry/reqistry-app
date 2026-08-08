import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

import 'feature_model.dart';

class FeatureBadge extends StatelessWidget {
  const FeatureBadge({super.key, required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        border: Border.fromBorderSide(
          BorderSide(color: c.surfaceVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(feature.icon, size: 18, color: c.primary),
          const SizedBox(height: AppSpacing.s8),
          Text(
            feature.label,
            style: AppTextStyles.labelSm.copyWith(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
