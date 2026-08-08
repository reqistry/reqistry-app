import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/app/modules/views/search_apis_screen/widgets/browse_by_category.dart';

class SearchApisScreen extends StatelessWidget {
  const SearchApisScreen({super.key});

  Future<void> _refresh(BuildContext context) {
    return context.read<HomeCategoriesCubit>().retryFetch();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('DISCOVER', style: AppTextStyles.headlineSm),
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        scrolledUnderElevation: 0,
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
              child: const AppLoading(
                message: 'Loading categories',
                scrollable: true,
              ),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: AppErrorState(
                title: 'Could not load categories',
                message: state.errorMessage,
                onRetry: () => context.read<HomeCategoriesCubit>().retryFetch(),
                scrollable: true,
              ),
            );
          }

          if (state.categories.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: const AppEmptyState(
                title: 'Nothing to browse yet',
                message:
                    'The Discover catalog is loading. Pull to refresh and try again.',
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
