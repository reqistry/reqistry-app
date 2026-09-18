import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/modules/views/discover_view/widgets/browse_by_category.dart';
import 'package:api_scout/config/app_routes.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  Future<void> _refresh(BuildContext context) {
    return context.read<HomeCategoriesCubit>().retryFetch(l10n: AppLocalizations.of(context)!);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tabDiscover, style: AppTextStyles.headlineSm),
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.formSearchHint,
            constraints:
                const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: () => context.push(AppRoutes.search),
            icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: c.surfaceVariant),
          ),
        ),
      ),
      body: BlocBuilder<HomeCategoriesCubit, HomeCategoriesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: AppLoading(
                message: AppLocalizations.of(context)!.stateLoadingCategories,
                scrollable: true,
              ),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: AppErrorState(
                title: AppLocalizations.of(context)!.stateCouldNotLoadCategories,
                message: state.errorMessage,
                onRetry: () => context.read<HomeCategoriesCubit>().retryFetch(l10n: AppLocalizations.of(context)!),
                scrollable: true,
              ),
            );
          }

          if (state.categories.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: AppEmptyState(
                title: AppLocalizations.of(context)!.stateNothingToBrowseYet,
                message: AppLocalizations.of(context)!.discoverCatalogLoadingMessage,
                icon: PhosphorIconsRegular.squaresFour,
                scrollable: true,
              ),
            );
          }

          return BrowseByCategory(
            categories: state.categories,
            onRefresh: () => _refresh(context),
          );
        },
      ),
    );
  }
}
