import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/pro.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/share/share_plus/share_plus.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Pro ship-check evidence report for one API.
class ShipCheckSheet extends StatefulWidget {
  const ShipCheckSheet({super.key, required this.apiRef});

  final String apiRef;

  static Future<void> show(BuildContext context, String apiRef) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShipCheckSheet(apiRef: apiRef),
    );
  }

  @override
  State<ShipCheckSheet> createState() => _ShipCheckSheetState();
}

class _ShipCheckSheetState extends State<ShipCheckSheet> {
  late final Future<ShipCheckReport> _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.shipCheck(apiRef: widget.apiRef);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.primary, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.shipReportTitle,
                      style: AppTextStyles.labelSmUpper
                          .copyWith(color: c.onSurface),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .closeButtonLabel,
                    constraints: const BoxConstraints.tightFor(
                      width: 48,
                      height: 48,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(PhosphorIconsRegular.x),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FutureBuilder<ShipCheckReport>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return AppLoading(
                      message: l10n.stateLoading,
                      compact: true,
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return AppErrorState(
                      title: l10n.stateError,
                      message: l10n.stateSomethingWentWrong,
                      onRetry: () => setState(
                        () => _future = RemoteService.shipCheck(
                          apiRef: widget.apiRef,
                        ),
                      ),
                      compact: true,
                    );
                  }
                  return _ReportBody(
                    report: snapshot.data!,
                    onShare: () => _share(snapshot.data!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(ShipCheckReport report) async {
    final checks = report.checks.entries
        .map((e) => '- ${e.key}: ${e.value}')
        .join('\n');
    await ShareService.instance.shareText(
      '${report.name} — ${report.verdict.toUpperCase()} '
      '(${report.score}/100, grade ${report.grade})\n'
      '${report.summary ?? ''}\n$checks',
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.onShare});

  final ShipCheckReport report;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final verdictColor = report.ships
        ? c.successText
        : report.avoid
            ? c.dangerText
            : c.warningText;
    final verdictLabel = report.ships
        ? l10n.shipVerdictShip
        : report.avoid
            ? l10n.shipVerdictAvoid
            : l10n.shipVerdictCaution;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        0,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.outlineVariant),
          ),
          child: Row(
            children: [
              Text(
                '${report.score}',
                style: AppTextStyles.withTabular(
                  AppTextStyles.headlineMd.copyWith(color: verdictColor),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      verdictLabel,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: verdictColor,
                      ),
                    ),
                    Text(
                      'Grade ${report.grade}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.actionShare,
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                onPressed: onShare,
                icon: const Icon(PhosphorIconsRegular.shareNetwork),
              ),
            ],
          ),
        ),
        if ((report.summary ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s12),
          Text(report.summary!, style: AppTextStyles.bodyMd),
        ],
        const SizedBox(height: AppSpacing.s12),
        for (final entry in report.checks.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Row(
              children: [
                Icon(
                  entry.value == 'pass'
                      ? PhosphorIconsFill.checkCircle
                      : entry.value == 'fail'
                          ? PhosphorIconsFill.xCircle
                          : PhosphorIconsRegular.circle,
                  size: 18,
                  color: entry.value == 'pass'
                      ? c.successText
                      : entry.value == 'fail'
                          ? c.dangerText
                          : c.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: AppTextStyles.bodyMd,
                  ),
                ),
                Text(
                  entry.value.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
