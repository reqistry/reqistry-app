import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_state.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  Future<void> _refresh(BuildContext context) {
    return context.read<FavoritesCubit>().loadBookmarks(
          l10n: AppLocalizations.of(context)!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tabBookmarks,
            style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child:
              SizedBox(height: 1, child: ColoredBox(color: c.surfaceVariant)),
        ),
      ),
      body: Column(
        children: [
          const _WatchlistsEntry(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context)!;
                  if (state.isLoading && state.bookmarks.isEmpty) {
                    return AppLoading(
                      message: l10n.stateLoadingBookmarks,
                      scrollable: true,
                    );
                  }
                  if (state.bookmarks.isEmpty &&
                      state.errorMessage.isNotEmpty) {
                    return AppErrorState(
                      title: l10n.stateCouldNotLoadApis,
                      message: state.errorMessage,
                      onRetry: () => _refresh(context),
                      scrollable: true,
                    );
                  }
                  if (state.bookmarks.isEmpty) {
                    return const _EmptyFavorites();
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    itemCount: state.bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = state.bookmarks[index];
                      return ApiCard(
                        api: bookmark.api.toApiItem(),
                        category: bookmark.api.categoryName.isEmpty
                            ? AppLocalizations.of(context)!.tabBookmarks
                            : bookmark.api.categoryName,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistsEntry extends StatelessWidget {
  const _WatchlistsEntry();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.watchlists),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  color: c.surfaceContainerHighest,
                  child: Icon(
                    PhosphorIconsRegular.bellRinging,
                    size: 21,
                    color: c.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.watchTitle,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        l10n.watchEntrySubtitle,
                        style: AppTextStyles.bodySm.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 18,
                  color: c.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: AppLocalizations.of(context)!.stateNoBookmarksYet,
      message: AppLocalizations.of(context)!.stateBookmarksEmptyMessage,
      icon: PhosphorIconsRegular.bookmarkSimple,
      scrollable: true,
    );
  }
}
