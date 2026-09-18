import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/feature_models.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Stack history: daily down-count / trust snapshots written by the
/// stack-digest worker. Plain mono rows, newest first.
class StackHistorySheet extends StatefulWidget {
  const StackHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StackHistorySheet(),
    );
  }

  @override
  State<StackHistorySheet> createState() => _StackHistorySheetState();
}

class _StackHistorySheetState extends State<StackHistorySheet> {
  late Future<List<StackHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.getStackHistory();
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
          maxHeight: MediaQuery.of(context).size.height * 0.7,
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
                      l10n.stackHistoryTitle,
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
              child: FutureBuilder<List<StackHistoryItem>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return AppLoading(
                      message: l10n.stateLoading,
                      compact: true,
                    );
                  }
                  if (snapshot.hasError) {
                    return AppErrorState(
                      title: l10n.stateError,
                      message: l10n.stateSomethingWentWrong,
                      onRetry: () => setState(
                        () => _future = RemoteService.getStackHistory(),
                      ),
                      compact: true,
                    );
                  }
                  final items = snapshot.data ?? const <StackHistoryItem>[];
                  if (items.isEmpty) {
                    return AppEmptyState(
                      title: l10n.stackHistoryEmpty,
                      message: l10n.stateCheckBackLater,
                      icon: PhosphorIconsRegular.chartLine,
                      compact: true,
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      0,
                      AppSpacing.s16,
                      AppSpacing.s16,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: c.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final date = item.createdAt
                              ?.toLocal()
                              .toString()
                              .split(' ')
                              .first ??
                          '—';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                date,
                                style: AppTextStyles.withTabular(
                                  AppTextStyles.codeMd.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '${l10n.stackHistoryDown} ${item.downCount}',
                              style: AppTextStyles.withTabular(
                                AppTextStyles.codeMd.copyWith(
                                  fontSize: 12,
                                  color: item.downCount > 0
                                      ? c.dangerText
                                      : c.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Text(
                              '${l10n.stackHistoryTrust} ${item.avgTrust ?? '—'}',
                              style: AppTextStyles.withTabular(
                                AppTextStyles.codeMd.copyWith(
                                  fontSize: 12,
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
