import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/feature_models.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Keyword/category/project watches with change alerts.
class WatchlistsView extends StatefulWidget {
  const WatchlistsView({super.key});

  @override
  State<WatchlistsView> createState() => _WatchlistsViewState();
}

class _WatchlistsViewState extends State<WatchlistsView> {
  late Future<List<WatchItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.getWatchlists();
  }

  Future<void> _refresh() async {
    setState(() => _future = RemoteService.getWatchlists());
    try {
      await _future;
    } catch (_) {}
  }

  Future<void> _remove(WatchItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await RemoteService.removeWatch(item.id);
      if (!mounted) return;
      setState(() => _future = RemoteService.getWatchlists());
      AppSnackBarHelper.show(
        title: l10n.snackbarRemovedTitle,
        message: l10n.notifFeedRemovedMessage,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.watchTitle, style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<WatchItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppLoading(
                    message: l10n.stateLoading,
                    scrollable: true,
                  );
                }
                if (snapshot.hasError) {
                  return AppErrorState(
                    title: l10n.stateError,
                    message: l10n.stateSomethingWentWrong,
                    onRetry: _refresh,
                    scrollable: true,
                  );
                }
                final items = snapshot.data ?? const <WatchItem>[];
                if (items.isEmpty) {
                  return AppEmptyState(
                    title: l10n.watchEmptyTitle,
                    message: l10n.watchEmptyMessage,
                    icon: PhosphorIconsRegular.bellRinging,
                    scrollable: true,
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _remove(item),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.s16),
                        color: Theme.of(context).colorScheme.error,
                        child: Icon(
                          PhosphorIconsRegular.trash,
                          color: c.onPrimary,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: c.surface,
                          border: Border.all(color: c.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    item.kind.toUpperCase(),
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              PhosphorIconsRegular.trash,
                              size: 18,
                              color: c.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
    );
  }
}
