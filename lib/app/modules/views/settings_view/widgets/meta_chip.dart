import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class MetaChip extends StatelessWidget {
  const MetaChip({super.key, required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      color: highlight ? c.primary : c.surfaceContainerHigh,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmUpper.copyWith(
          color: highlight ? c.onPrimary : c.onSurfaceVariant,
        ),
      ),
    );
  }
}
