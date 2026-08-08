import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class SettingsEntryTile extends StatelessWidget {
  const SettingsEntryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.surfaceVariant)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.primary),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 18,
              color: c.outline,
            ),
          ],
        ),
      ),
    );
  }
}
