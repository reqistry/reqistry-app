import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/paywall/paywall_cubit.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/modules/views/search_screen/widgets/search_header.dart';
import 'package:api_scout/app/modules/views/search_screen/widgets/search_results_list.dart';
import 'package:api_scout/config/app_routes.dart';
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
          AppLocalizations.of(context)!.tabSearch,
          style:
              AppTextStyles.headlineSm.copyWith(color: c.onSurface),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
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
            const _WatchSearchRow(),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context)!;
                  return AsyncStateHandler(
                    isLoading: (state.isSearching || state.isLoadingMore) &&
                        state.searchResults.isEmpty,
                    errorMessage: state.errorMessage.isNotEmpty &&
                            state.searchResults.isEmpty
                        ? state.errorMessage
                        : null,
                    isEmpty: state.searchResults.isEmpty,
                    loadingMessage: l10n.stateSearchingApis,
                    errorTitle: l10n.snackbarSearchErrorTitle,
                    emptyTitle: state.hasSearched
                        ? l10n.stateNoMatchFound
                        : l10n.onboardingSearchFabTitle,
                    emptyMessage: state.hasSearched
                        ? l10n.stateTryDifferentKeyword
                        : l10n.onboardingSearchFabDesc,
                    emptyIcon: PhosphorIconsRegular.magnifyingGlass,
                    onRetry: state.hasSearched
                        ? () => context
                            .read<SearchBloc>()
                            .add(SearchPerformed(l10n: l10n))
                        : null,
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

/// Pro keyword watch entry. Visible after a real search; free users land
/// on the paywall, Pro users watch the query directly.
class _WatchSearchRow extends StatelessWidget {
  const _WatchSearchRow();

  Future<void> _watch(BuildContext context, String query) async {
    final l10n = AppLocalizations.of(context)!;
    if (!context.read<PaywallCubit>().isPro) {
      context.push(AppRoutes.pro);
      return;
    }
    try {
      await RemoteService.addWatch(kind: 'keyword', value: query, l10n: l10n);
      if (!context.mounted) return;
      AppSnackBarHelper.show(
        title: l10n.watchAdded,
        message: query,
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (!state.hasSearched || state.query.trim().isEmpty) {
          return const SizedBox.shrink();
        }
        final c = AppColors.of(Theme.of(context).brightness);
        final l10n = AppLocalizations.of(context)!;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _watch(context, state.query.trim()),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(
                  bottom: BorderSide(color: c.surfaceVariant, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.bellRinging,
                    size: 18,
                    color: c.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      l10n.watchAction,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 18,
                    color: c.outline,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
