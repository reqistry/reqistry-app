import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/search_screen/widgets/search_header.dart';
import 'package:api_scout/app/modules/views/search_screen/widgets/search_results_list.dart';
import 'package:api_scout/shared/widgets/ui/async_state_handler.dart';

class SearchBody extends StatefulWidget {
  final TextEditingController searchController;

  const SearchBody({super.key, required this.searchController});

  @override
  State<SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
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
                  return AsyncStateHandler(
                    isLoading: state.isSearching && state.searchResults.isEmpty,
                    errorMessage: state.errorMessage.isNotEmpty && state.searchResults.isEmpty ? state.errorMessage : null,
                    isEmpty: state.searchResults.isEmpty,
                    loadingMessage: 'Searching APIs',
                    errorTitle: 'Search error',
                    emptyTitle: 'No matches found',
                    emptyMessage: 'Try a different keyword or loosen your filters to discover more APIs.',
                    emptyIcon: PhosphorIconsRegular.magnifyingGlass,
                    onRetry: () => context.read<SearchBloc>().add(SearchPerformed()),
                    child: SearchResultsList(
                      state: state,
                      scrollController: _scrollController,
                    ),
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
