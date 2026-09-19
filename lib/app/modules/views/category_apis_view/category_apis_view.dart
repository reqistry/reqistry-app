import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/blocs/category_apis/category_apis_cubit.dart';
import 'package:api_scout/app/services/ads/ad_insertion.dart';
import 'package:api_scout/app/services/ads/ads_controller.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/ads/catalog_native_ad_card.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';
import 'package:api_scout/shared/widgets/ui/stat_widgets.dart';
import 'package:api_scout/shared/widgets/ui/async_state_handler.dart';
import 'package:api_scout/app/modules/views/category_apis_view/widgets/category_watch_button.dart';
import '../apis_view/widgets/api_card.dart';

class CategoryApisView extends StatefulWidget {
  final Object argument;

  const CategoryApisView({super.key, required this.argument});

  @override
  State<CategoryApisView> createState() => _CategoryApisViewState();
}

class _CategoryApisViewState extends State<CategoryApisView> {
  /// Combined-list slots whose native fill failed; rendered as nothing.
  final Set<int> _deadSlots = {};

  void _dropSlot(int slot) {
    if (_deadSlots.add(slot) && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: BlocBuilder<CategoryApisCubit, CategoryApisState>(
          builder: (context, state) {
            return Text(
              state.categoryTitle.isNotEmpty
                  ? state.categoryTitle
                  : AppLocalizations.of(context)!.stateCategory,
              style: AppTextStyles.headlineSm,
            );
          },
        ),
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<CategoryApisCubit, CategoryApisState>(
        builder: (context, state) {
          return AsyncStateHandler(
            isLoading: state.isLoading,
            errorMessage:
                state.errorMessage.isNotEmpty ? state.errorMessage : null,
            isEmpty: state.apis.isEmpty,
            loadingMessage:
                AppLocalizations.of(context)!.stateLoadingCategoryApis,
            errorTitle: AppLocalizations.of(context)!.stateCouldNotLoadCategory,
            emptyTitle: AppLocalizations.of(context)!.stateNoApisAvailable,
            emptyMessage:
                AppLocalizations.of(context)!.stateCategoryEmptyMessage,
            onRetry: () => context
                .read<CategoryApisCubit>()
                .retryFetch(l10n: AppLocalizations.of(context)),
            child: RefreshIndicator(
              onRefresh: () => context
                  .read<CategoryApisCubit>()
                  .retryFetch(l10n: AppLocalizations.of(context)),
              child: ListenableBuilder(
                listenable: AdsController.shared,
                builder: (context, _) {
                  // Slot 0 is the category summary header; native ads
                  // interleave among the APIs only when UMP permits.
                  final adsOn = AdsController.shared.canShowAds;
                  final organic = state.apis.length;
                  final slots =
                      adsOn ? AdInsertion.slotCount(organic) : organic;
                  return ListView.separated(
                    itemCount: slots + 1,
                    padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.itemGap),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _CategorySummary(state: state);
                      }
                      final slot = index - 1;
                      if (adsOn) {
                        final organicIndex =
                            AdInsertion.organicIndexForSlot(slot, organic);
                        if (organicIndex == -1) {
                          if (_deadSlots.contains(slot)) {
                            return const SizedBox.shrink();
                          }
                          return CatalogNativeAdCard(
                            key: ValueKey('native-ad-$slot'),
                            onUnavailable: () => _dropSlot(slot),
                          );
                        }
                        final api = state.apis[organicIndex];
                        return ApiCard(
                          key: ValueKey(api.id.isNotEmpty ? api.id : api.link),
                          api: api,
                          category: state.categoryTitle,
                        );
                      }

                      final api = state.apis[slot];
                      return ApiCard(
                        api: api,
                        category: state.categoryTitle,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  final CategoryApisState state;

  const _CategorySummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final meta = state.categoryMeta;
    final apis = state.apis;
    final aliveCount = apis.where((api) => api.isAlive).length;
    final httpsCount = apis.where((api) => api.supportsHttps).length;
    final openAuthCount = apis.where((api) {
      final auth = api.auth.toLowerCase();
      return auth == 'none' || auth == 'no' || auth == 'no auth';
    }).length;
    final responseTimes = apis
        .where((api) => api.responseTime > 0)
        .map((api) => api.responseTime)
        .toList();
    final avgResponse = responseTimes.isEmpty
        ? 0
        : (responseTimes.reduce((a, b) => a + b) / responseTimes.length)
            .round();

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: AppCachedImage(
              imageUrl: meta?.imageUrl,
              fallback: CategoryImagePlaceholder(
                title: meta?.name ?? state.categoryTitle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meta?.name ?? state.categoryTitle,
                        style: AppTextStyles.headlineSm,
                      ),
                    ),
                    if (meta?.hasTrendyBorder == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s4,
                        ),
                        color: c.primary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIconsRegular.trendUp,
                              size: 12,
                              color: c.onPrimary,
                            ),
                            const SizedBox(width: AppSpacing.s4),
                            Text(
                              AppLocalizations.of(context)!.stateTrending,
                              style: AppTextStyles.labelSmUpper.copyWith(
                                color: c.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if ((meta?.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    meta!.description!,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: c.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                if ((meta?.tags ?? const <String>[]).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s12),
                  Wrap(
                    spacing: AppSpacing.s6,
                    runSpacing: AppSpacing.s6,
                    children: meta!.tags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.surfaceVariant),
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: AppTextStyles.labelSmUpper.copyWith(
                            color: c.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                CategoryWatchButton(
                  category: meta?.name ?? state.categoryTitle,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.6,
                  crossAxisSpacing: AppSpacing.s8,
                  mainAxisSpacing: AppSpacing.s8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatTile(
                        label: AppLocalizations.of(context)!.categoryApis,
                        value: '${apis.length}'),
                    StatTile(
                        label: AppLocalizations.of(context)!.categoryAlive,
                        value: '$aliveCount'),
                    StatTile(
                        label: AppLocalizations.of(context)!.categoryHttps,
                        value: '$httpsCount'),
                    StatTile(
                        label: AppLocalizations.of(context)!.categoryNoAuth,
                        value: '$openAuthCount'),
                    StatTile(
                      label: AppLocalizations.of(context)!.categoryAvgResponse,
                      value: avgResponse > 0
                          ? '${avgResponse}ms'
                          : AppLocalizations.of(context)!.miscNA,
                    ),
                    StatTile(
                      label: AppLocalizations.of(context)!.categoryCatalogTotal,
                      value: '${meta?.apiCount ?? apis.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
