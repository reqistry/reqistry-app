import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';

class SearchApisScreen extends StatelessWidget {
  const SearchApisScreen({super.key});

  Future<void> _refresh(BuildContext context) {
    return context.read<HomeCategoriesCubit>().retryFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('DISCOVER', style: AppTextStyles.headlineSm),
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
              height: 1, child: ColoredBox(color: AppColors.surfaceVariant)),
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

          return _BrowseByCategory(
            categories: state.categories,
            onRefresh: () => _refresh(context),
          );
        },
      ),
    );
  }
}

class _BrowseByCategory extends StatelessWidget {
  final List<Category> categories;
  final Future<void> Function() onRefresh;

  const _BrowseByCategory({
    required this.categories,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Text(
            'BROWSE BY CATEGORY',
            style: AppTextStyles.labelSmUpper.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: AppSpacing.s8,
                mainAxisSpacing: AppSpacing.s8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.categoryApis,
                    extra: category,
                  ),
                  child: _CategoryCard(category: category),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppCachedImage(
              imageUrl: imageUrl,
              fallback: CategoryImagePlaceholder(
                title: category.name,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTextStyles.headlineSm.fontFamily,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (category.hasTrendyBorder)
            Positioned(
              top: AppSpacing.s8,
              right: AppSpacing.s8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s6,
                  vertical: AppSpacing.s2,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Text(
                  'TRENDING',
                  style: AppTextStyles.labelSmUpper.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
