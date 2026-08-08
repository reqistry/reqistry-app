import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/app_toggle.dart';

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.surfaceVariant,
          child: Icon(icon, color: c.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
        ),
        trailing: AppToggle(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
