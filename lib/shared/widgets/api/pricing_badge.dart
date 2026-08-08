import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/shared/widgets/api/api_chip.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class PricingBadge extends StatelessWidget {
  final String pricing;
  const PricingBadge({super.key, required this.pricing});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final normalized = pricing.toLowerCase();
    final label = normalized.isEmpty ? AppLocalizations.of(context)!.miscUnknownPricing : pricing.toUpperCase();

    Color bg;
    Color fg;

    if (normalized == 'free') {
      bg = c.successBg;
      fg = c.successText;
    } else if (normalized == 'paid') {
      bg = c.warningBg;
      fg = c.warningText;
    } else if (normalized == 'freemium' || normalized == 'free tier') {
      bg = c.infoBg;
      fg = c.infoText;
    } else {
      bg = c.surfaceContainerHigh;
      fg = c.onSurface;
    }

    return ApiChip(label: label, bg: bg, fg: fg);
  }
}
