import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class ApiHealthSection extends StatelessWidget {
  const ApiHealthSection({
    super.key,
    required this.health,
    required this.isRefreshing,
    required this.onRefresh,
    this.error,
  });

  final ApiHealthSummary health;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final presentation = _healthPresentation(health.status);
    final facts = <String>[
      if (health.checkedAt != null)
        'Checked ${relativeTime(health.checkedAt!)}',
      if (health.responseTimeMs != null) '${health.responseTimeMs} ms',
      if (health.statusCode != null) 'HTTP ${health.statusCode}',
      if (health.uptime30d != null)
        '30d uptime ${health.uptime30d!.toStringAsFixed(2)}%',
      if (health.observationCount > 0)
        '${health.observationCount} observations',
    ];
    final detailText = facts.isEmpty
        ? 'No recent health result is available'
        : facts.join(' · ');

    return Semantics(
      container: true,
      label: 'Platform-observed health. ${presentation.label}. $detailText',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            left: BorderSide(color: presentation.color, width: 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingH,
          vertical: AppSpacing.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PLATFORM-OBSERVED HEALTH',
              style: AppTextStyles.labelSm.copyWith(
                color: c.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                Icon(presentation.icon, color: presentation.color, size: 20),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Text(
                    presentation.label,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: presentation.color,
                    ),
                  ),
                ),
                if (isRefreshing)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.s14),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      foregroundColor: c.onSurface,
                    ),
                  ),
              ],
            ),
            Text(detailText, style: AppTextStyles.codeMd),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(error!,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: c.dangerText)),
            ],
          ],
        ),
      ),
    );
  }
}

class _HealthPresentation {
  final String label;
  final IconData icon;
  final Color color;

  const _HealthPresentation(this.label, this.icon, this.color);
}

_HealthPresentation _healthPresentation(ApiHealthStatus status) =>
    switch (status) {
      ApiHealthStatus.operational => const _HealthPresentation(
          'Operational',
          PhosphorIconsFill.checkCircle,
          AppColors.successText,
        ),
      ApiHealthStatus.authenticationRequired => const _HealthPresentation(
          'Reachable - authentication required',
          PhosphorIconsFill.shieldWarning,
          AppColors.warningText,
        ),
      ApiHealthStatus.rateLimited => const _HealthPresentation(
          'Reachable - rate limited',
          PhosphorIconsFill.warning,
          AppColors.warningText,
        ),
      ApiHealthStatus.degraded => const _HealthPresentation(
          'Slow response',
          PhosphorIconsFill.gauge,
          AppColors.warningText,
        ),
      ApiHealthStatus.unavailable => const _HealthPresentation(
          'Currently unavailable',
          PhosphorIconsFill.xSquare,
          AppColors.dangerText,
        ),
      ApiHealthStatus.unknown => const _HealthPresentation(
          'Status not verified',
          PhosphorIconsRegular.circle,
          AppColors.onSurfaceVariant,
        ),
    };

String relativeTime(DateTime value) {
  final difference = DateTime.now().difference(value).abs();
  if (difference.inMinutes < 1) return 'just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} hr ago';
  return '${difference.inDays} days ago';
}
