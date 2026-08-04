import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/api/status_dot.dart';
import 'package:api_scout/shared/widgets/api/api_badges.dart';

class LatestApiCard extends StatelessWidget {
  final ApiItem api;
  final VoidCallback? onTap;

  const LatestApiCard({
    super.key,
    required this.api,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.surfaceVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration:  BoxDecoration(
                      color: c.surfaceContainerHighest,
                    ),
                    child:  Icon(
                      PhosphorIconsRegular.bracketsCurly,
                      size: 20,
                      color: c.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          api.name,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          api.category,
                          style: AppTextStyles.labelSmUpper.copyWith(
                            color: c.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  StatusDot(isAlive: api.isAlive),
                ],
              ),
            ),
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}
