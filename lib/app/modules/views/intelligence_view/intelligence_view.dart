import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/l10n/app_localizations.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

import 'widgets/feature_model.dart';
import 'widgets/highlight_model.dart';
import 'widgets/feature_badge.dart';
import 'widgets/highlight_row.dart';

class IntelligenceView extends StatelessWidget {
  const IntelligenceView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final features = [
      Feature(icon: PhosphorIconsRegular.scales, label: l10n.intelligenceCompareApis),
      Feature(icon: PhosphorIconsRegular.robot, label: l10n.intelligenceAgentReadiness),
      Feature(icon: PhosphorIconsRegular.sealCheck, label: l10n.intelligenceEvidenceBacked),
      Feature(icon: PhosphorIconsRegular.puzzlePiece, label: l10n.intelligenceMcpToolDiscovery),
    ];
    final highlights = [
      Highlight(l10n.intelligenceSideBySideComparison),
      Highlight(l10n.intelligenceContextualScores),
      Highlight(l10n.intelligenceEvidenceBackedRecommendations),
      Highlight(l10n.intelligenceMcpServerToolDiscovery),
      Highlight(l10n.intelligenceNaturalLanguageMatching),
    ];
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.tabIntelligence, style: AppTextStyles.headlineSm),
        centerTitle: false,
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: c.surfaceVariant),
          ),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s16,
          AppSpacing.s24,
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.fromBorderSide(BorderSide(color: c.outline)),
            ),
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.brain,
                      color: c.info,
                      size: 40,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: AppSpacing.s4,
                      ),
                      color: c.infoBg,
                      child: Text(
                        l10n.stateComingSoon,
                        style: AppTextStyles.labelSmUpper.copyWith(
                          fontSize: 10,
                          color: c.infoText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  l10n.sectionRegistryIntelligence,
                  style: AppTextStyles.labelSmUpper,
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  l10n.intelligenceAiPoweredDecisions,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                Column(
                  children: [
                    for (var i = 0; i < features.length; i += 2) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.s8),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: FeatureBadge(feature: features[i]),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: i + 1 < features.length
                                  ? FeatureBadge(feature: features[i + 1])
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: c.surfaceVariant,
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  l10n.sectionUpcoming,
                  style: AppTextStyles.labelSmUpper.copyWith(fontSize: 10),
                ),
                const SizedBox(height: AppSpacing.s10),
                for (final h in highlights) ...[
                  HighlightRow(label: h.label),
                  if (h != highlights.last)
                    const SizedBox(height: AppSpacing.s10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
