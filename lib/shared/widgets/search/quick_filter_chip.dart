import 'package:flutter/material.dart';
import '../../../app/utils/design_system/app_colors.dart';
import '../../../app/utils/design_system/app_spacing.dart';
import '../../../app/utils/design_system/app_text_styles.dart';

class QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  const QuickFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.chipGap),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.surfaceVariant,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.onPrimary : AppColors.onSurface,
              ),
              const SizedBox(width: AppSpacing.s4),
              Text(
                label,
                style: AppTextStyles.labelSmUpper.copyWith(
                  fontSize: 10,
                  color: selected ? AppColors.onPrimary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DesignChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const DesignChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmUpper.copyWith(
            fontSize: 11,
            color: selected ? AppColors.onPrimary : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const FilterSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.s8),
            Text(
              title,
              style: AppTextStyles.labelSmUpper
                  .copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        child,
      ],
    );
  }
}
