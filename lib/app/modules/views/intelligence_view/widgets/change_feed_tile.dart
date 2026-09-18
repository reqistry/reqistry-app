import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/api/api_chip.dart';

/// Registry change tile: event-type badge, API name, 2-line change summary
/// and detail values. Matches the flat bordered card language.
class ChangeFeedTile extends StatelessWidget {
  final ChangeFeedEvent event;
  final VoidCallback? onTap;

  const ChangeFeedTile({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final time = DateFormat.MMMd().add_Hm().format(event.createdAt.toLocal());
    final label = _typeLabel(l10n, event.eventType);
    final palette = _typeColors(c, event.eventType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.surfaceVariant, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                color: c.surfaceContainerHighest,
                child: Icon(_eventIcon(event.eventType),
                    size: 20, color: palette.fg),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ApiChip(label: label, bg: palette.bg, fg: palette.fg),
                        const Spacer(),
                        Text(
                          time,
                          style: AppTextStyles.labelSmUpper.copyWith(
                            color: c.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      (event.apiName?.isNotEmpty ?? false)
                          ? event.apiName!
                          : l10n.intelligenceChangeFeed,
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      event.title,
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        color: c.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.detailsSummary.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        event.detailsSummary,
                        style: AppTextStyles.codeMd.copyWith(
                          fontSize: 11,
                          color: c.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, String eventType) {
    switch (eventType) {
      case 'trust_score_changed':
        return l10n.changeTypeTrustScore;
      case 'price_changed':
      case 'pricing_changed':
        return l10n.changeTypePricing;
      case 'health_changed':
        return l10n.changeTypeHealth;
      default:
        return l10n.changeTypeUpdate;
    }
  }

  ({Color bg, Color fg}) _typeColors(AppColorScheme c, String eventType) {
    switch (eventType) {
      case 'trust_score_changed':
        return (bg: c.infoBg, fg: c.infoText);
      case 'price_changed':
      case 'pricing_changed':
        return (bg: c.warningBg, fg: c.warningText);
      case 'health_changed':
        return (bg: c.successBg, fg: c.successText);
      default:
        return (bg: c.surfaceContainerHighest, fg: c.onSurface);
    }
  }

  IconData _eventIcon(String eventType) {
    switch (eventType) {
      case 'trust_score_changed':
        return PhosphorIconsRegular.sealCheck;
      case 'price_changed':
      case 'pricing_changed':
        return PhosphorIconsRegular.currencyDollar;
      case 'health_changed':
        return PhosphorIconsRegular.pulse;
      default:
        return PhosphorIconsRegular.sparkle;
    }
  }
}
