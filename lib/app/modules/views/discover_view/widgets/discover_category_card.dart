import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';
import 'package:api_scout/app/data/models/category.dart';

class DiscoverCategoryCard extends StatelessWidget {
  final Category category;

  const DiscoverCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final imageUrl = category.imageUrl;

    final l10n = AppLocalizations.of(context)!;
    final trending = category.hasTrendyBorder;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: trending ? c.primary : c.surfaceVariant,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppCachedImage(
              imageUrl: imageUrl,
              isCategory: true,
              fallback: CategoryImagePlaceholder(
                title: category.name,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s6,
              ),
              color: Colors.black.withValues(alpha: 0.55),
              child: Row(
                children: [
                  if (trending) ...[
                    const Icon(
                      PhosphorIconsRegular.trendUp,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Expanded(
                      child: Text(
                        l10n.stateTrending,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmUpper.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  Text(
                    '${category.apiCount} ${l10n.miscApis}'.toUpperCase(),
                    maxLines: 1,
                    style: AppTextStyles.withTabular(
                      AppTextStyles.codeMd.copyWith(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trending) ...[
                    Container(
                      width: 3,
                      height: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                  ],
                  Expanded(
                    child: Text(
                      category.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
