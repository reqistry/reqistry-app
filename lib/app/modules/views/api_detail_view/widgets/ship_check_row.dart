import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/modules/views/api_detail_view/widgets/ship_check_sheet.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Inline ship-check entry. Opens the production-safety report for this
/// API. Never blocks surrounding features.
class ShipCheckRow extends StatelessWidget {
  const ShipCheckRow({super.key, required this.apiId, required this.slug});

  final String apiId;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
      ),
      child: Semantics(
        button: true,
        label: l10n.shipCheckRowTitle,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ShipCheckSheet.show(
                context,
                apiId.trim().isNotEmpty ? apiId.trim() : slug,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.all(color: c.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.shieldCheck,
                    size: 20,
                    color: c.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.shipCheckRowTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          l10n.shipCheckRowBody,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 18,
                    color: c.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
