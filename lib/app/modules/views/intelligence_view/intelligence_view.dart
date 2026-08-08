import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

import 'widgets/feature_model.dart';
import 'widgets/highlight_model.dart';
import 'widgets/feature_badge.dart';
import 'widgets/highlight_row.dart';

class IntelligenceView extends StatelessWidget {
  const IntelligenceView({super.key});

  static const List<Feature> _features = [
    Feature(
      icon: PhosphorIconsRegular.scales,
      label: 'Compare APIs side by side',
    ),
    Feature(
      icon: PhosphorIconsRegular.robot,
      label: 'Agent readiness scoring',
    ),
    Feature(
      icon: PhosphorIconsRegular.sealCheck,
      label: 'Evidence-backed recommendations',
    ),
    Feature(
      icon: PhosphorIconsRegular.puzzlePiece,
      label: 'MCP tool discovery',
    ),
  ];

  static const List<Highlight> _highlights = [
    Highlight('Side-by-side API comparison'),
    Highlight('Contextual trust and agent scores'),
    Highlight('Evidence-backed recommendations'),
    Highlight('MCP server and tool discovery'),
    Highlight('Natural-language requirement matching'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('INTELLIGENCE', style: AppTextStyles.headlineSm),
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
                        'COMING SOON',
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
                  'REQISTRY INTELLIGENCE',
                  style: AppTextStyles.labelSmUpper,
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  'AI-powered API decisions, coming soon.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                Column(
                  children: [
                    for (var i = 0; i < _features.length; i += 2) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.s8),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: FeatureBadge(feature: _features[i]),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: i + 1 < _features.length
                                  ? FeatureBadge(feature: _features[i + 1])
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
                  'UPCOMING',
                  style: AppTextStyles.labelSmUpper.copyWith(fontSize: 10),
                ),
                const SizedBox(height: AppSpacing.s10),
                for (final h in _highlights) ...[
                  HighlightRow(label: h.label),
                  if (h != _highlights.last)
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
