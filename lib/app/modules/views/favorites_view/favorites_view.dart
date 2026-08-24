import 'package:flutter/material.dart';
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
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  Future<void> _refresh(BuildContext context) {
    return context.read<FavoritesCubit>().loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tabBookmarks, style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
              height: 1, child: ColoredBox(color: c.surfaceVariant)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return AppLoading(
                message: AppLocalizations.of(context)!.stateLoadingBookmarks,
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