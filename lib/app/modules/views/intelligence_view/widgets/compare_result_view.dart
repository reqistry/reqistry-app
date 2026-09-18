import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/share/share_plus/share_plus.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/api/trust_evidence.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/ui/bottom_sheet_scaffold.dart';

/// Side-by-side comparison of 2–4 APIs fetched from /v1/apis/compare.
class CompareResultView extends StatefulWidget {
  final List<String> apiIds;

  const CompareResultView({super.key, required this.apiIds});

  @override
  State<CompareResultView> createState() => _CompareResultViewState();
}

class _CompareResultViewState extends State<CompareResultView> {
  late Future<List<CompareApi>> _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.compareApis(ids: widget.apiIds);
  }

  void _reload() {
    setState(() => _future = RemoteService.compareApis(ids: widget.apiIds));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.intelligenceCompareTitle,
            style: AppTextStyles.headlineSm),
        centerTitle: false,
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.actionShare,
            constraints:
                const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: () async {
              final apis = await _future;
              if (!context.mounted) return;
              _share(context, apis);
            },
            icon: const Icon(PhosphorIconsRegular.shareNetwork),
          ),
          IconButton(
            tooltip: l10n.actionShare,
            constraints:
                const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: () async {
              final apis = await _future;
              if (!context.mounted) return;
              _shareJson(apis);
            },
            icon: const Icon(PhosphorIconsRegular.fileCode),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceVariant),
        ),
      ),
      body: FutureBuilder<List<CompareApi>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppLoading(
              message: l10n.intelligenceCompareTitle,
              scrollable: true,
            );
          }
          if (snapshot.hasError || snapshot.data!.isEmpty) {
            return AppErrorState(
              title: l10n.stateSomethingWentWrong,
              message:
                  snapshot.error?.toString() ?? l10n.stateNoApis,
              onRetry: _reload,
              scrollable: true,
            );
          }
          final apis = snapshot.data!;
          final verdict = buildCompareVerdict(apis);
          final bestSpeed = uniqueBestIndex(
            [for (final a in apis) a.responseTimeMs ?? 1 << 30],
            lowerIsBetter: true,
          );
          final bestUptime = uniqueBestIndex(
            [for (final a in apis) _uptimeSortKey(a.uptime30d)],
          );
          final priceRanks = [for (final a in apis) pricingRank(a.pricingType)];
          var bestPrice = uniqueBestIndex(priceRanks, lowerIsBetter: true);
          if (bestPrice != -1 && priceRanks[bestPrice] >= 3) bestPrice = -1;
          final bestHttps = _uniqueTrueIndex([for (final a in apis) a.https]);
          final bestOpenApi =
              _uniqueTrueIndex([for (final a in apis) a.openApiAvailable]);
          final bestCors = _uniqueMatchIndex(
            apis,
            (a) => a.cors.toLowerCase().contains('support'),
          );
          final bestSdks = uniqueBestIndex(
            [for (final a in apis) a.sdkLanguages.length],
          );
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (verdict != null) ...[
                    _VerdictCard(verdict: verdict),
                    const SizedBox(height: AppSpacing.s16),
                  ],
                  Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.fromBorderSide(BorderSide(color: c.outline)),
                ),
                padding: const EdgeInsets.all(AppSpacing.s8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: AppSpacing.s20,
                    headingRowHeight: 72,
                    columns: [
                      const DataColumn(label: SizedBox(width: 96)),
                      for (final api in apis)
                        DataColumn(
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    api.name,
                                    style: AppTextStyles.labelSm.copyWith(
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (api.trustGrade != null)
                                  Text(
                                    l10n.compareTrustScoreValue(
                                        api.trustScore ?? 0, api.trustGrade!),
                                    style: AppTextStyles.labelSm
                                        .copyWith(color: c.infoText),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(Text(l10n.compareTrust,
                              style: AppTextStyles.labelSm.copyWith(
                                  color: c.onSurfaceVariant))),
                          for (final api in apis)
                            DataCell(
                              api.trustScore == null && api.trustGrade == null
                                  ? const Text('—')
                                  : TextButton(
                                      onPressed: () =>
                                          _showTrustEvidence(context, api),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.s8,
                                          vertical: AppSpacing.s4,
                                        ),
                                        minimumSize: const Size(48, 44),
                                      ),
                                      child: Text(
                                        l10n.compareTrustScoreValue(
                                            api.trustScore ?? 0,
                                            api.trustGrade ?? '—'),
                                        style: AppTextStyles.withTabular(
                                          AppTextStyles.labelSm.copyWith(
                                            color: c.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                        ],
                      ),
                      _row(c, l10n.apiDetailPricing,
                          apis.map((a) => a.pricingType).toList(),
                          best: bestPrice),
                      _row(c, l10n.apiDetailAuthentication,
                          apis.map((a) => a.authType).toList()),
                      _row(
                          c,
                          l10n.compareResponseTime,
                          apis
                              .map((a) => a.responseTimeMs == null
                                  ? '—'
                                  : '${a.responseTimeMs} ms')
                              .toList(),
                          best: bestSpeed),
                      _row(c, l10n.compareUptime30d,
                          apis.map(_uptimeLabel).toList(),
                          best: bestUptime),
                      _row(c, l10n.apiDetailCors,
                          apis.map((a) => a.cors).toList(),
                          best: bestCors),
                      _row(
                          c,
                          l10n.apiDetailHttps,
                          apis
                              .map((a) =>
                                  a.https == null ? '—' : (a.https! ? '✓' : '✕'))
                              .toList(),
                          best: bestHttps),
                      _row(c,
                          l10n.compareOpenApi, apis.map((a) => a.openApiAvailable ? '✓' : '✕').toList(),
                          best: bestOpenApi),
                      _row(
                          c,
                          l10n.compareRateLimit,
                          apis
                              .map((a) =>
                                  a.rateLimit.isEmpty ? '—' : a.rateLimit)
                              .toList()),
                      _row(
                          c,
                          l10n.compareSdks,
                          apis
                              .map((a) => a.sdkLanguages.isEmpty
                                  ? '—'
                                  : a.sdkLanguages.take(4).join(', '))
                              .toList(),
                          best: bestSdks),
                      DataRow(
                        cells: [
                          DataCell(Text(l10n.apiDetailDocumentation,
                              style: AppTextStyles.labelSm.copyWith(
                                  color: c.onSurfaceVariant))),
                          for (final api in apis)
                            DataCell(
                              api.documentationUrl == null
                                  ? const Text('—')
                                  : IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.open_in_new,
                                          size: 18),
                                      onPressed: () => launchUrl(
                                          Uri.parse(api.documentationUrl!),
                                          mode:
                                              LaunchMode.externalApplication),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTrustEvidence(BuildContext context, CompareApi api) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetScaffold(
        title: '${api.name} · ${l10n.trustEvidenceTitle}',
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: TrustEvidenceBody(
            score: api.trustScore,
            grade: api.trustGrade,
            summary: api.trustSummary,
            factors: api.trustFactors,
            computedAt: api.trustComputedAt,
          ),
        ),
      ),
    );
  }

  String _uptimeLabel(CompareApi api) {
    final uptime = api.uptime30d;
    if (uptime == null) return '—';
    return '${uptime.toStringAsFixed(uptime % 1 == 0 ? 0 : 1)}%';
  }

  void _share(BuildContext context, List<CompareApi> apis) {
    final l10n = AppLocalizations.of(context)!;
    final verdict = buildCompareVerdict(apis);
    final lines = <String>[l10n.compareShareHeader, ''];
    if (verdict != null) {
      lines.add('Top pick: ${verdict.topPick.name}');
      lines.add('');
    }
    for (final api in apis) {
      final trust = api.trustScore == null && api.trustGrade == null
          ? 'trust —'
          : 'trust ${api.trustScore ?? '—'}'
              '${api.trustGrade != null ? ' · Grade ${api.trustGrade}' : ''}';
      lines.add(
        '- ${api.name}: $trust, ${api.pricingType}, uptime ${_uptimeLabel(api)}',
      );
    }
    ShareService.instance.shareText(lines.join('\n'));
  }

  /// Evidence-pack export: full-fidelity JSON of the comparison.
  void _shareJson(List<CompareApi> apis) {
    const encoder = JsonEncoder.withIndent('  ');
    ShareService.instance.shareText(
      encoder.convert({
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'count': apis.length,
        'apis': [for (final api in apis) api.toJson()],
      }),
    );
  }

  DataRow _row(
    AppColorScheme c,
    String label,
    List<String> values, {
    int best = -1,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return DataRow(
      cells: [
        DataCell(Text(label,
            style:
                AppTextStyles.labelSm.copyWith(color: c.onSurfaceVariant))),
        for (var i = 0; i < values.length; i++)
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(values[i],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: AppTextStyles.labelSm),
                  if (i == best) ...[
                    const SizedBox(height: AppSpacing.s4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s6,
                        vertical: AppSpacing.s2,
                      ),
                      color: c.primary,
                      child: Text(
                        l10n.compareBest,
                        style: AppTextStyles.labelSmUpper.copyWith(
                          color: c.onPrimary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Sort key for uptime: hundredths of a percent, -1 when unknown.
int _uptimeSortKey(num? uptime) =>
    uptime == null ? -1 : (uptime * 100).round();

/// Index of the single `true` in [values] when the rest are explicitly
/// `false`. Nulls and unanimous rows earn no BEST badge.
int _uniqueTrueIndex(List<bool?> values) {
  var found = -1;
  for (var i = 0; i < values.length; i++) {
    final v = values[i];
    if (v == null) return -1;
    if (v) {
      if (found != -1) return -1;
      found = i;
    }
  }
  if (found == -1) return -1;
  return values.any((v) => v == false) ? found : -1;
}

/// Index of the single row matching [test], or -1 on zero/multiple hits.
int _uniqueMatchIndex(List<CompareApi> apis, bool Function(CompareApi) test) {
  var found = -1;
  for (var i = 0; i < apis.length; i++) {
    if (test(apis[i])) {
      if (found != -1) return -1;
      found = i;
    }
  }
  return found;
}

/// Verdict header above the table: top pick plus the evidence bullets
/// behind it. Rule-based and fully on-device (see [buildCompareVerdict]).
class _VerdictCard extends StatelessWidget {
  final CompareVerdict verdict;

  const _VerdictCard({required this.verdict});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final top = verdict.topPick;
    final fastest = verdict.fastest;
    final uptime = verdict.bestUptime;
    final bullets = <String>[
      l10n.compareTrustScoreValue(top.trustScore ?? 0, top.trustGrade ?? '—'),
      if (fastest != null && fastest.id == top.id)
        l10n.compareVerdictAlsoFastest
      else if (fastest != null)
        l10n.compareVerdictFastest(
          fastest.name,
          fastest.responseTimeMs ?? 0,
        ),
      if (uptime != null && uptime.id != top.id && uptime.id != fastest?.id)
        l10n.compareVerdictUptime(uptime.name, _uptimeText(uptime)),
    ];
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.primary, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: AppSpacing.s4,
                ),
                color: c.primary,
                child: Text(
                  l10n.compareTopPick,
                  style: AppTextStyles.labelSmUpper.copyWith(
                    color: c.onPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  top.name,
                  style: AppTextStyles.headlineSm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      PhosphorIconsRegular.check,
                      size: 16,
                      color: c.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      bullet,
                      style: AppTextStyles.bodySm.copyWith(
                        color: c.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _uptimeText(CompareApi api) {
    final u = api.uptime30d;
    if (u == null) return '—';
    return '${u.toStringAsFixed(u % 1 == 0 ? 0 : 1)}%';
  }
}
