import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class TabChoice extends StatelessWidget {
  const TabChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          border: Border.all(
            color: selected ? c.primary : c.outline,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmUpper.copyWith(
            color: selected ? c.onPrimary : c.onSurface,
          ),
        ),
      ),
    );
  }
}
