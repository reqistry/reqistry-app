import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Subscription terms, 12px floor, centered, never truncated.
class PaywallLegalFooter extends StatelessWidget {
  const PaywallLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: Text(
        AppLocalizations.of(context)!.paywallTerms,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelSm.copyWith(color: c.onSurfaceVariant),
      ),
    );
  }
}
