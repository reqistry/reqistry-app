import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/api/api_badges.dart';

class ApiBadgeRow extends StatelessWidget {
  final ApiItem api;

  const ApiBadgeRow({
    super.key,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s12,
        right: AppSpacing.s12,
        bottom: AppSpacing.s12,
      ),
      child: Row(
        children: [
          PricingBadge(pricing: api.pricing),
          const SizedBox(width: AppSpacing.s6),
          TypeBadge(type: api.apiType),
          const SizedBox(width: AppSpacing.s6),
          HttpsBadge(isHttps: api.supportsHttps),
          const Spacer(),
          Text(
            api.responseTimeFormatted,
            style: AppTextStyles.labelSmUpper.copyWith(
              color: c.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
