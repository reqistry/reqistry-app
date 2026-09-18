import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class ApiChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const ApiChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(color: bg),
      child: Text(
        label,
        style: AppTextStyles.labelSmUpper.copyWith(color: fg, fontSize: 11),
      ),
    );
  }
}
