import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class LinkAccountSection extends StatelessWidget {
  final VoidCallback onLinkEmail;

  const LinkAccountSection({
    super.key,
    required this.onLinkEmail,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.sectionLinkYourAccount, style: AppTextStyles.labelSmUpper),
        const SizedBox(height: AppSpacing.chipGap),
        Text(
          AppLocalizations.of(context)!.settingsLinkAccountDescription,
          style: AppTextStyles.bodyMd.copyWith(
            color: c.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.itemGap),
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.zero,
            border: Border.fromBorderSide(BorderSide(color: c.outline)),
          ),
          child: Material(
            color: c.surface,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: c.surfaceVariant,
                child: Icon(PhosphorIconsRegular.envelope, color: c.primary),
              ),
              title: Text(AppLocalizations.of(context)!.settingsLinkWithEmail),
              subtitle: Text(AppLocalizations.of(context)!.settingsCreatePermanentAccount),
              trailing:
                  const Icon(PhosphorIconsRegular.caretRight, size: 16),
              onTap: onLinkEmail,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
      ],
    );
  }
}
