import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/api/api_badges.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class ApiIdentityHeader extends StatelessWidget {
  const ApiIdentityHeader({super.key, required this.detail});

  final ApiDetail detail;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return DetailSection(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            image: true,
            label: AppLocalizations.of(context)!.semanticsApiLogo(detail.name),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: c.surfaceVariant),
              ),
              child: ClipRect(
                child: AppCachedImage(
                  imageUrl: detail.imageUrl,
                  fallback: CategoryImagePlaceholder(title: detail.name),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: AppTextStyles.headlineMd.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(detail.shortDescription, style: AppTextStyles.bodyLg),
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    TypeBadge(type: detail.category.name),
                    PricingBadge(pricing: detail.access.pricingLabel),
                    ApiChip(
                      label: detail.access.authLabel.toUpperCase(),
                      bg: c.surfaceContainerHigh,
                      fg: c.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
