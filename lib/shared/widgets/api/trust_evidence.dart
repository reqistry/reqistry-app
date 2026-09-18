import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Evidence behind a trust score: grade, summary, per-factor bars.
///
/// Shared by the compare trust sheet and the API detail trust section.
/// Factors render in backend weight order (see [TrustFactor.displayOrder]);
/// unknown future dimensions append automatically via the model parser.
class TrustEvidenceBody extends StatelessWidget {
  final int? score;
  final String? grade;
  final String? summary;
  final Map<String, TrustFactor> factors;
  final DateTime? computedAt;

  const TrustEvidenceBody({
    super.key,
    this.score,
    this.grade,
    this.summary,
    this.factors = const {},
    this.computedAt,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              label: grade != null && score != null
                  ? 'Trust score $score out of 100, grade $grade'
                  : 'Trust score',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s6,
                ),
                color: c.primary,
                child: Text(
                  grade != null && score != null
                      ? '$score · $grade'
                      : (grade ?? (score != null ? '$score' : '—')),
                  style: AppTextStyles.withTabular(
                    AppTextStyles.headlineSm.copyWith(color: c.onPrimary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                summary ?? '',
                style: AppTextStyles.bodySm.copyWith(
                  color: c.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (factors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s16),
          for (final factor in factors.values)
            _FactorRow(factor: factor),
        ],
        const SizedBox(height: AppSpacing.s12),
        Text(
          computedAt != null
              ? l10n.trustEvidenceVerifiedOn(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(computedAt!),
                )
              : l10n.trustEvidenceLiveScore,
          style: AppTextStyles.labelSmUpper.copyWith(
            color: c.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _FactorRow extends StatelessWidget {
  final TrustFactor factor;

  const _FactorRow({required this.factor});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final weak = factor.score < 50;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  factor.label,
                  style: AppTextStyles.bodySm.copyWith(color: c.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                '${factor.score}',
                style: AppTextStyles.withTabular(
                  AppTextStyles.labelSmUpper.copyWith(
                    color: weak ? c.dangerText : c.onSurface,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          ExcludeSemantics(
            child: Container(
              height: 4,
              color: c.surfaceContainerHighest,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: factor.score.clamp(0, 100) / 100,
                child: Container(
                  height: 4,
                  color: weak ? c.danger : c.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
