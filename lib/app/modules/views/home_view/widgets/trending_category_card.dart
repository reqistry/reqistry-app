import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Editorial rank card for the Home trending rail.
///
/// Deliberately distinct from the Discover photo-grid cards: flat surface,
/// 1px primary border, oversized mono rank numeral, Inter name, and a mono
/// data footer. Tap handling lives in the parent rail wrapper; this widget
/// owns the full screen-reader announcement and hides inner text from the
/// accessibility tree to avoid double readout.
class TrendingCategoryCard extends StatelessWidget {
  const TrendingCategoryCard({
    super.key,
    required this.category,
    required this.rank,
    required this.total,
  });

  final Category category;
  final int rank;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final rankLabel = rank.toString().padLeft(2, '0');
    final countLabel =
        '${category.apiCount} ${l10n.miscApis}'.toUpperCase();

    return Semantics(
      button: true,
      label:
          '${l10n.stateTrending}: ${category.name}, $countLabel, $rankLabel/$total',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.primary, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rankLabel,
                    style: AppTextStyles.withTabular(
                      AppTextStyles.codeMd.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: c.onSurface,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIconsRegular.trendUp,
                    size: 18,
                    color: c.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.onSurface,
                ),
              ),
              const Spacer(),
              Container(height: 1, color: c.outlineVariant),
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      countLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.withTabular(
                        AppTextStyles.codeMd.copyWith(
                          fontSize: 12,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 14,
                    color: c.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
