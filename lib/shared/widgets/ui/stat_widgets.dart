import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s8),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmUpper.copyWith(
                color: c.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLg.copyWith(
                color: c.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final Color? valueColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final body = Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.surfaceVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmUpper.copyWith(
              color: c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: AppTextStyles.headlineLg.copyWith(
              color: valueColor ?? c.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: AppSpacing.s2),
            Text(
              sublabel!,
              style: AppTextStyles.labelSmUpper.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
    final tap = onTap;
    if (tap == null) return body;
    return Semantics(
      button: true,
      label: '$label, $value',
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: tap, child: body),
      ),
    );
  }
}
