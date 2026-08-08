import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class SheetLabel extends StatelessWidget {
  const SheetLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
      child: Text(
        text,
        style: AppTextStyles.labelSm.copyWith(
          color: c.onSurfaceVariant,
        ),
      ),
    );
  }
}
