import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Email gate: guests must link an email before purchasing so Pro stays
/// attributed to them on every device.
class PaywallGateBanner extends StatelessWidget {
  const PaywallGateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.envelopeSimple,
                size: 20,
                color: c.onSurface,
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  l10n.paywallAccountRequiredTitle,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.paywallAccountRequiredBody,
            style:
                AppTextStyles.bodySm.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(AppRoutes.accountSettings),
              child: Text(l10n.paywallAccountRequiredAction),
            ),
          ),
        ],
      ),
    );
  }
}
