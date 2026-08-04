import 'package:flutter/material.dart';
import '../../../app/utils/design_system/app_colors.dart';
import '../../../app/utils/design_system/app_spacing.dart';
import '../../../app/utils/design_system/app_text_styles.dart';

class ApiChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const ApiChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(color: bg),
      child: Text(
        label,
        style: AppTextStyles.labelSmUpper.copyWith(color: fg, fontSize: 9),
      ),
    );
  }
}

class PricingBadge extends StatelessWidget {
  final String pricing;
  const PricingBadge({super.key, required this.pricing});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final normalized = pricing.toLowerCase();
    final label = normalized.isEmpty ? 'UNKNOWN' : pricing.toUpperCase();

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

class TypeBadge extends StatelessWidget {
  final String type;
  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ApiChip(
      label: type.toUpperCase(),
      bg: c.surfaceContainerHighest,
      fg: c.onSurface,
    );
  }
}

class HttpsBadge extends StatelessWidget {
  final bool isHttps;
  const HttpsBadge({super.key, required this.isHttps});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ApiChip(
      label: isHttps ? 'HTTPS' : 'HTTP',
      bg: isHttps ? c.successBg : c.dangerBg,
      fg: isHttps ? c.successText : c.dangerText,
    );
  }
}

class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const FeatureChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.surfaceVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.s8),
          Text(
            label,
            style: AppTextStyles.labelSmUpper.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
