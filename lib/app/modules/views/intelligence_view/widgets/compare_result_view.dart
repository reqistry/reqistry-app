import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

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
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Container(
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
                      _row(c, l10n.apiDetailPricing,
                          apis.map((a) => a.pricingType).toList()),
                      _row(c, l10n.apiDetailAuthentication,
                          apis.map((a) => a.authType).toList()),
                      _row(
                          c,
                          l10n.compareResponseTime,
                          apis
                              .map((a) => a.responseTimeMs == null
                                  ? '—'
                                  : '${a.responseTimeMs} ms')
                              .toList()),
                      _row(c, l10n.compareUptime30d,
                          apis.map(_uptimeLabel).toList()),
                      _row(c, l10n.apiDetailCors,
                          apis.map((a) => a.cors).toList()),
                      _row(
                          c,
                          l10n.apiDetailHttps,
                          apis
                              .map((a) =>
                                  a.https == null ? '—' : (a.https! ? '✓' : '✕'))
                              .toList()),
                      _row(c,
                          'OpenAPI', apis.map((a) => a.openApiAvailable ? '✓' : '✕').toList()),
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
                              .toList()),
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
            ),
          );
        },
      ),
    );
  }

  String _uptimeLabel(CompareApi api) {
    final uptime = api.uptime30d;
    if (uptime == null) return '—';
    return '${uptime.toStringAsFixed(uptime % 1 == 0 ? 0 : 1)}%';
  }

  DataRow _row(AppColorScheme c, String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label,
            style:
                AppTextStyles.labelSm.copyWith(color: c.onSurfaceVariant))),
        for (final value in values)
          DataCell(
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppTextStyles.labelSm),
            ),
          ),
      ],
    );
  }
}
