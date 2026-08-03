import 'package:flutter/material.dart';
import '../../../app/utils/design_system/app_spacing.dart';
import '../../../app/utils/design_system/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      child: Text(
        label,
        style: AppTextStyles.labelSmUpper,
      ),
    );
  }
}
