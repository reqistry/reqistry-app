import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/api/api_badges.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ApiIdentityHeader extends StatelessWidget {
  const ApiIdentityHeader({super.key, required this.detail});

  final ApiDetail detail;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return _Section(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            image: true,
            label: '${detail.name} logo',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: c.surfaceVariant),
              ),
              child: ClipRect(
                child: AppCachedImage(
                  imageUrl: detail.imageUrl,
                  fallback: CategoryImagePlaceholder(title: detail.name),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: AppTextStyles.headlineMd.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(detail.shortDescription, style: AppTextStyles.bodyLg),
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    TypeBadge(type: detail.category.name),
                    PricingBadge(pricing: detail.access.pricingLabel),
                    ApiChip(
                      label: detail.access.authLabel.toUpperCase(),
                      bg: c.surfaceContainerHigh,
                      fg: c.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class ApiQuickFacts extends StatelessWidget {
  const ApiQuickFacts({super.key, required this.detail});

  final ApiDetail detail;

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('Authentication', detail.access.authLabel),
      ('Pricing', detail.access.pricingLabel),
      ('HTTPS', nullableSupport(detail.capabilities.https)),
      ('CORS', corsLabel(detail.capabilities.cors)),
      ('API type', protocolLabel(detail.capabilities.protocol)),
      (
        'Response format',
        detail.capabilities.responseFormats.isEmpty
            ? 'Unknown'
            : detail.capabilities.responseFormats.join(', '),
      ),
      if (detail.access.creditCardRequired != null)
        (
          'Credit card required',
          detail.access.creditCardRequired! ? 'Yes' : 'No',
        ),
      if (detail.access.commercialUseAllowed != null)
        (
          'Commercial use',
          nullableSupport(detail.access.commercialUseAllowed),
        ),
      if (detail.capabilities.openApiAvailable != null)
        (
          'OpenAPI available',
          nullableSupport(detail.capabilities.openApiAvailable)
        ),
      if (detail.capabilities.sdkLanguages.isNotEmpty)
        ('SDKs', detail.capabilities.sdkLanguages.join(', ')),
      if (detail.access.rateLimit != null)
        ('Rate limit', detail.access.rateLimit!),
    ];
    return _Section(
      title: 'QUICK FACTS',
      child: Column(
        children: [
          for (var index = 0; index < facts.length; index++) ...[
            _FactRow(label: facts[index].$1, value: facts[index].$2),
            if (index != facts.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class ApiEndpointSection extends StatelessWidget {
  const ApiEndpointSection({
    super.key,
    required this.baseUrl,
    required this.onCopy,
  });

  final Uri baseUrl;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    const label = 'BASE URL';
    final c = AppColors.of(Theme.of(context).brightness);
    return _Section(
      title: label,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surfaceContainerLow,
          border: Border.all(color: c.surfaceVariant),
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.s12,
          top: AppSpacing.s8,
          bottom: AppSpacing.s8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: '$label ${baseUrl.toString()}',
                child: SelectableText(
                  baseUrl.toString(),
                  style: AppTextStyles.codeMd,
                ),
              ),
            ),
            IconButton(
              onPressed: onCopy,
              tooltip: 'Copy $label',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(PhosphorIconsRegular.copy),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiAboutSection extends StatelessWidget {
  const ApiAboutSection({
    super.key,
    required this.detail,
    required this.onOpen,
  });

  final ApiDetail detail;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final links = <(String, Uri?)>[
      ('Documentation', detail.links.documentationUrl),
      ('API reference', detail.links.openApiUrl),
      ('Homepage', detail.links.homepageUrl),
      ('Status page', detail.links.statusPageUrl),
      ('Terms', detail.links.termsUrl),
    ].where((item) => item.$2 != null).toList();
    final c = AppColors.of(Theme.of(context).brightness);
    return _Section(
      title: 'ABOUT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.shortDescription, style: AppTextStyles.bodyLg),
          if (detail.fullDescription != null) ...[
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Website information · metadata',
              style: AppTextStyles.labelSm.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(detail.fullDescription!, style: AppTextStyles.bodyMd),
          ],
          if (links.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            const Divider(height: 1),
            for (final link in links)
              Material(
                color: c.surface,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 48,
                  title: Text(link.$1, style: AppTextStyles.bodyMd),
                  trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                  onTap: () => onOpen(link.$2!),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class ApiRequirementsSection extends StatelessWidget {
  const ApiRequirementsSection({super.key, required this.warnings});

  final List<ApiWarning> warnings;

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    return _Section(
      title: 'REQUIREMENTS & LIMITATIONS',
      child: Column(
        children: warnings.map((warning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(PhosphorIconsRegular.warning, size: 17),
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                    child: Text(warning.message, style: AppTextStyles.bodyMd)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ApiVerificationSection extends StatelessWidget {
  const ApiVerificationSection({super.key, required this.items});

  final List<FieldVerification> items;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return _Section(
      title: 'DATA CONFIDENCE',
      child: Column(
        children: items.map((item) {
          final value = item.verifiedAt == null
              ? item.source
              : '${item.source} · ${relativeTime(item.verifiedAt!)}';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 108,
                  child: Text(item.label, style: AppTextStyles.bodyMd),
                ),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ApiAlternativesSection extends StatelessWidget {
  const ApiAlternativesSection({
    super.key,
    required this.alternatives,
    required this.isLoading,
    required this.onOpen,
    required this.onSave,
    this.error,
  });

  final List<ApiAlternative> alternatives;
  final bool isLoading;
  final ValueChanged<ApiAlternative> onOpen;
  final ValueChanged<ApiAlternative> onSave;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && alternatives.isEmpty && error == null) {
      return const SizedBox.shrink();
    }
    final c = AppColors.of(Theme.of(context).brightness);
    return _Section(
      title: 'SIMILAR APIs',
      child: Column(
        children: [
          if (isLoading && alternatives.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (error != null && alternatives.isEmpty)
            Text(error!, style: AppTextStyles.bodyMd)
          else
            for (final alternative in alternatives)
              Material(
                color: c.surface,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 72,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: c.surfaceVariant),
                    ),
                    child: ClipRect(
                      child: AppCachedImage(
                        imageUrl: alternative.imageUrl,
                        fallback: CategoryImagePlaceholder(
                          name: alternative.name,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    alternative.name,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${alternative.pricing} · ${alternative.authentication}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => onSave(alternative),
                    tooltip: 'Save ${alternative.name}',
                    constraints:
                        const BoxConstraints.tightFor(width: 48, height: 48),
                    icon: const Icon(PhosphorIconsRegular.bookmarkSimple),
                  ),
                  onTap: () => onOpen(alternative),
                ),
              ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      color: c.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingH,
        vertical: AppSpacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.labelSmUpper),
            const SizedBox(height: AppSpacing.s12),
          ],
          child,
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
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

String nullableSupport(bool? value) => switch (value) {
      true => 'Supported',
      false => 'Not supported',
      null => 'Unknown',
    };

String corsLabel(CorsSupport value) => switch (value) {
      CorsSupport.supported => 'Supported',
      CorsSupport.unsupported => 'Not supported',
      CorsSupport.unknown => 'Unknown',
    };

String protocolLabel(ApiProtocol value) => switch (value) {
      ApiProtocol.rest => 'REST',
      ApiProtocol.graphql => 'GraphQL',
      ApiProtocol.soap => 'SOAP',
      ApiProtocol.websocket => 'WebSocket',
      ApiProtocol.unknown => 'Unknown',
    };
