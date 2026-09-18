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
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: AppSpacing.s10,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.surfaceVariant)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: c.primary),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMd
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
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
        ),
      ),
    );
  }
}
