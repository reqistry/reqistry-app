import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

class SearchResultsList extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;

  const SearchResultsList({super.key, required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: BoxDecoration(
            color: c.surfaceContainer,
            border: Border(
                bottom: BorderSide(color: c.surfaceVariant, width: 1)),
          ),
          child: Row(
            children: [
              Text('${state.totalResults} results',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: c.onSurface)),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsRegular.sortAscending,
                        size: 18, color: c.primary),
                    const SizedBox(width: AppSpacing.s4),
                    Text('SORT',
                        style: AppTextStyles.labelSmUpper
                            .copyWith(color: c.primary, fontSize: 11)),
                  ],
                ),
                onSelected: (value) {
                  final parts = value.split('_');
                  context.read<SearchBloc>().add(
                      SearchSortChanged(sortBy: parts[0], sortOrder: parts[1]));
                  context.read<SearchBloc>().add(SearchPerformed());
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'name_asc', child: Text('Name (A-Z)')),
                  const PopupMenuItem(
                      value: 'name_desc', child: Text('Name (Z-A)')),
                  const PopupMenuItem(
                      value: 'responseTime_asc', child: Text('Fastest First')),
                  const PopupMenuItem(
                      value: 'responseTime_desc', child: Text('Slowest First')),
                  const PopupMenuItem(
                      value: 'category_asc', child: Text('Category (A-Z)')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<SearchBloc>().add(SearchPerformed());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: state.searchResults.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.searchResults.length) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Center(
                      child: state.isLoadingMore
                          ? const AppLoading(
                              message: 'Loading more',
                              compact: true,
                              size: 24,
                            )
                          : ElevatedButton.icon(
                              onPressed: () => context
                                  .read<SearchBloc>()
                                  .add(SearchLoadMore()),
                              icon: const Icon(
                                  PhosphorIconsRegular.arrowsClockwise,
                                  size: 18),
                              label: Text('LOAD MORE',
                                  style: AppTextStyles.labelSmUpper
                                      .copyWith(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c.surface,
                                foregroundColor: c.onSurface,
                                side: BorderSide(
                                    color: c.surfaceVariant),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                                elevation: 0,
                              ),
                            ),
                    ),
                  );
                }
                final api = state.searchResults[index];
                final category =
                    state.category.isNotEmpty ? state.category.first : 'Search';
                return ApiCard(api: api, category: category);
              },
            ),
          ),
        ),
      ],
    );
  }
}
