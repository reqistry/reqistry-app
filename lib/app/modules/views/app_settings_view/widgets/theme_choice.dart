import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class ThemeChoice extends StatelessWidget {
  const ThemeChoice({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          border: Border.all(
            color: selected ? c.primary : c.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? c.onPrimary : c.onSurface,
            ),
            const SizedBox(width: AppSpacing.s4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSmUpper.copyWith(
                color: selected ? c.onPrimary : c.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
