import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/api/trust_evidence.dart';

/// Trust evidence block on the API detail page.
///
/// Renders nothing when the payload carries no trust breakdown (seed
/// objects built from list rows). Same body as the compare trust sheet.
class ApiTrustSection extends StatelessWidget {
  final ApiTrustScore? trustScore;

  const ApiTrustSection({super.key, this.trustScore});

  @override
  Widget build(BuildContext context) {
    final trust = trustScore;
    if (trust == null || (trust.score == null && trust.grade == null)) {
      return const SizedBox.shrink();
    }
    return DetailSection(
      title: AppLocalizations.of(context)!.trustEvidenceTitle,
      child: TrustEvidenceBody(
        score: trust.score,
        grade: trust.grade,
        summary: trust.summary,
        factors: trust.factors,
        computedAt: trust.computedAt,
      ),
    );
  }
}
