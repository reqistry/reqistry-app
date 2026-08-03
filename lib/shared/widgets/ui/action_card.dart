import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../app/utils/design_system/app_colors.dart';
import '../../../app/utils/design_system/app_spacing.dart';
import '../../../app/utils/design_system/app_text_styles.dart';

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.outline),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              danger ? AppColors.dangerBg : AppColors.surfaceVariant,
          child: Icon(
            icon,
            color: danger ? AppColors.danger : AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(
            color: danger ? AppColors.danger : AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
        trailing: const Icon(PhosphorIconsRegular.caretRight),
      ),
    );
  }
}
