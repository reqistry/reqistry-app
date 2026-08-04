import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class IntelligenceView extends StatelessWidget {
  const IntelligenceView({super.key});

  static const List<_Feature> _features = [
    _Feature(
      icon: PhosphorIconsRegular.scales,
      label: 'Compare APIs side by side',
    ),
    _Feature(
      icon: PhosphorIconsRegular.robot,
      label: 'Agent readiness scoring',
    ),
    _Feature(
      icon: PhosphorIconsRegular.sealCheck,
      label: 'Evidence-backed recommendations',
    ),
    _Feature(
      icon: PhosphorIconsRegular.puzzlePiece,
      label: 'MCP tool discovery',
    ),
  ];

  static const List<_Highlight> _highlights = [
    _Highlight('Side-by-side API comparison'),
    _Highlight('Contextual trust and agent scores'),
    _Highlight('Evidence-backed recommendations'),
    _Highlight('MCP server and tool discovery'),
    _Highlight('Natural-language requirement matching'),
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
                              child: _FeatureBadge(feature: _features[i]),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: i + 1 < _features.length
                                  ? _FeatureBadge(feature: _features[i + 1])
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
                  _HighlightRow(label: h.label),
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

class _Feature {
  const _Feature({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _Highlight {
  const _Highlight(this.label);

  final String label;
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        border: Border.fromBorderSide(
          BorderSide(color: c.surfaceVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(feature.icon, size: 18, color: c.primary),
          const SizedBox(height: AppSpacing.s8),
          Text(
            feature.label,
            style: AppTextStyles.labelSm.copyWith(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          PhosphorIconsRegular.caretRight,
          size: 14,
          color: c.outline,
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: c.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
