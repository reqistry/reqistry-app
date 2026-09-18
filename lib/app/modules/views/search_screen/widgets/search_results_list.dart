import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/services/ads/ad_insertion.dart';
import 'package:api_scout/app/services/ads/ads_controller.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/ads/catalog_native_ad_card.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

class SearchResultsList extends StatefulWidget {
  final SearchState state;
  final ScrollController scrollController;

  const SearchResultsList(
      {super.key, required this.state, required this.scrollController});

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  /// Combined-list slots whose native fill failed; rendered as nothing.
  final Set<int> _deadSlots = {};

  void _dropSlot(int slot) {
    if (_deadSlots.add(slot) && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final state = widget.state;
    final scrollController = widget.scrollController;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          decoration: BoxDecoration(
            color: c.surfaceContainer,
            border:
                Border(bottom: BorderSide(color: c.surfaceVariant, width: 1)),
          ),
          child: Row(
            children: [
              Text(
                  AppLocalizations.of(context)!
                      .resultsCount(state.totalResults),
                  style: AppTextStyles.withTabular(
                      AppTextStyles.bodyMd.copyWith(color: c.onSurface))),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsRegular.sortAscending,
                        size: 18, color: c.primary),
                    const SizedBox(width: AppSpacing.s4),
                    Text(AppLocalizations.of(context)!.actionSort,
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
                  PopupMenuItem(
                      value: 'name_asc',
                      child: Text(AppLocalizations.of(context)!.sortNameAsc)),
                  PopupMenuItem(
                      value: 'name_desc',
                      child: Text(AppLocalizations.of(context)!.sortNameDesc)),
                  PopupMenuItem(
                      value: 'responseTime_asc',
                      child:
                          Text(AppLocalizations.of(context)!.sortFastestFirst)),
                  PopupMenuItem(
                      value: 'responseTime_desc',
                      child:
                          Text(AppLocalizations.of(context)!.sortSlowestFirst)),
                  PopupMenuItem(
                      value: 'category_asc',
                      child:
                          Text(AppLocalizations.of(context)!.sortCategoryAsc)),
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
            child: ListenableBuilder(
              listenable: AdsController.shared,
              builder: (context, _) {
                // Native ads interleave via AdInsertion only when UMP
                // permits; otherwise the list is purely organic.
                final adsOn = AdsController.shared.canShowAds;
                final organic = state.searchResults.length;
                final slots = adsOn ? AdInsertion.slotCount(organic) : organic;
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: slots + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == slots) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        child: Center(
                          child: state.isLoadingMore
                              ? AppLoading(
                                  message: AppLocalizations.of(context)!
                                      .stateLoadingMore,
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
                                  label: Text(
                                      AppLocalizations.of(context)!
                                          .actionLoadMore,
                                      style: AppTextStyles.labelSmUpper
                                          .copyWith(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: c.surface,
                                    foregroundColor: c.onSurface,
                                    side: BorderSide(color: c.surfaceVariant),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                    elevation: 0,
                                  ),
                                ),
                        ),
                      );
                    }
                    if (adsOn) {
                      final organicIndex =
                          AdInsertion.organicIndexForSlot(index, organic);
                      if (organicIndex == -1) {
                        if (_deadSlots.contains(index)) {
                          return const SizedBox.shrink();
                        }
                        return CatalogNativeAdCard(
                          key: ValueKey('native-ad-$index'),
                          onUnavailable: () => _dropSlot(index),
                        );
                      }
                      final api = state.searchResults[organicIndex];
                      final category = state.category.isNotEmpty
                          ? state.category.first
                          : AppLocalizations.of(context)!
                              .apiDetailSearchFallback;
                      return ApiCard(
                        key: ValueKey(api.id.isNotEmpty ? api.id : api.link),
                        api: api,
                        category: category,
                        sourceScreen: 'search',
                      );
                    }
                    final api = state.searchResults[index];
                    final category = state.category.isNotEmpty
                        ? state.category.first
                        : AppLocalizations.of(context)!.apiDetailSearchFallback;
                    return ApiCard(
                      key: ValueKey(api.id.isNotEmpty ? api.id : api.link),
                      api: api,
                      category: category,
                      sourceScreen: 'search',
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
