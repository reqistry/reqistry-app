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
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: danger ? c.dangerBg : c.surfaceVariant,
          child: Icon(
            icon,
            color: danger ? c.danger : c.primary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(
            color: danger ? c.danger : c.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
        ),
        onTap: onTap,
        trailing: const Icon(PhosphorIconsRegular.caretRight),
      ),
    );
  }
}
