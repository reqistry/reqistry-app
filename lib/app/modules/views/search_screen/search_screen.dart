import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'widgets/search_header.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc()..add(SearchCategoriesLoaded()),
      child: _SearchBody(searchController: _searchController),
    );
  }
}

class _SearchBody extends StatefulWidget {
  final TextEditingController searchController;

  const _SearchBody({required this.searchController});

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<SearchBloc>().state;
      if (!state.isLoadingMore && state.hasMore) {
        context.read<SearchBloc>().add(SearchLoadMore());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          'SEARCH',
          style:
              AppTextStyles.headlineSm.copyWith(color: c.onSurface),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceVariant),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(searchController: widget.searchController),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.isSearching && state.searchResults.isEmpty) {
                    return const AppLoading(message: 'Searching APIs');
                  }
                  if (state.errorMessage.isNotEmpty &&
                      state.searchResults.isEmpty) {
                    return AppErrorState(
                      title: 'Search error',
                      message: state.errorMessage,
                      onRetry: () =>
                          context.read<SearchBloc>().add(SearchPerformed()),
                    );
                  }
                  if (state.searchResults.isEmpty) {
                    return const AppEmptyState(
                      title: 'No matches found',
                      message:
                          'Try a different keyword or loosen your filters to discover more APIs.',
                      icon: PhosphorIconsRegular.magnifyingGlass,
                    );
                  }
                  return _ResultsList(
                      state: state, scrollController: _scrollController);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final SearchState state;
  final ScrollController scrollController;

  const _ResultsList({required this.state, required this.scrollController});

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
