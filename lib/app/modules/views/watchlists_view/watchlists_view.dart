import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/data/models/feature_models.dart';
import 'package:api_scout/app/modules/views/watchlists_view/widgets/create_keyword_watch_sheet.dart';
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

  Future<bool> _remove(WatchItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await RemoteService.removeWatch(item.id);
      if (!mounted) return false;
      AppSnackBarHelper.show(
        title: l10n.snackbarRemovedTitle,
        message: l10n.notifFeedRemovedMessage,
      );
      return true;
    } catch (_) {
      if (!mounted) return false;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
      return false;
    }
  }

  Future<void> _createWatch() async {
    final keyword = await CreateKeywordWatchSheet.show(context);
    if (keyword == null || !mounted) return;
    await _refresh();
    if (!mounted) return;
    AppSnackBarHelper.show(
      title: AppLocalizations.of(context)!.watchAdded,
      message: keyword,
    );
  }

  String _kindLabel(AppLocalizations l10n, String kind) {
    return switch (kind) {
      'category' => l10n.watchKindCategory,
      'project' => l10n.watchKindProject,
      _ => l10n.watchKindKeyword,
    };
  }

  String _displayValue(BuildContext context, WatchItem item) {
    if (item.kind != 'project') return item.value;
    for (final project in context.read<ProjectsCubit>().state.projects) {
      if (project.id == item.value && project.title.isNotEmpty) {
        return project.title;
      }
    }
    return item.value;
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
        actions: [
          IconButton(
            tooltip: l10n.watchCreateAction,
            onPressed: _createWatch,
            icon: const Icon(PhosphorIconsRegular.plus),
          ),
        ],
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
                actionLabel: l10n.watchCreateAction,
                onAction: _createWatch,
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
                  confirmDismiss: (_) => _remove(item),
                  onDismissed: (_) => _refresh(),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _displayValue(context, item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _kindLabel(l10n, item.kind).toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .deleteButtonTooltip,
                          onPressed: () async {
                            if (await _remove(item)) await _refresh();
                          },
                          icon: Icon(
                            PhosphorIconsRegular.trash,
                            size: 18,
                            color: c.onSurfaceVariant,
                          ),
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
