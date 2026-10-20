import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/services/ads/ad_insertion.dart';
import 'package:api_scout/app/services/ads/ads_controller.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/shared/widgets/ads/catalog_native_ad_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/l10n/app_localizations.dart';

enum ApiCollectionKind { latest, recommended }

class ApiCollectionView extends StatefulWidget {
  final ApiCollectionKind kind;

  const ApiCollectionView({
    super.key,
    required this.kind,
  });

  @override
  State<ApiCollectionView> createState() => _ApiCollectionViewState();
}

class _ApiCollectionViewState extends State<ApiCollectionView> {
  late Future<List<ApiItem>> _future;

  /// Combined-list slots whose native fill failed; rendered as nothing.
  final Set<int> _deadSlots = {};

  void _dropSlot(int slot) {
    if (_deadSlots.add(slot) && mounted) setState(() {});
  }

  String _title(BuildContext context) => widget.kind == ApiCollectionKind.latest
      ? AppLocalizations.of(context)!.sectionLatestAdded
      : AppLocalizations.of(context)!.sectionRecommendedForYou;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ApiItem>> _load({AppLocalizations? l10n}) {
    return widget.kind == ApiCollectionKind.latest
        ? RemoteService.getRecentlyAddedApis(limit: 50, l10n: l10n)
        : RemoteService.getRecommendedApiItems(limit: 50, l10n: l10n);
  }

  Future<void> _refresh() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _future = _load(l10n: l10n);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(_title(context), style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ApiItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(
                  message: AppLocalizations.of(context)!
                      .stateLoadingTitle(_title(context)),
                  scrollable: true);
            }
            if (snapshot.hasError) {
              return AppErrorState(
                title: AppLocalizations.of(context)!.stateCouldNotLoadApis,
                message: snapshot.error.toString(),
                onRetry: () => setState(
                    () => _future = _load(l10n: AppLocalizations.of(context)!)),
                scrollable: true,
              );
            }
            final apis = snapshot.data ?? const <ApiItem>[];
            if (apis.isEmpty) {
              return AppEmptyState(
                title: AppLocalizations.of(context)!.stateNoApis,
                message: AppLocalizations.of(context)!.statePullToRefresh,
                icon: PhosphorIconsRegular.bracketsCurly,
                scrollable: true,
              );
            }
            return ListenableBuilder(
              listenable: AdsController.shared,
              builder: (context, _) {
                // Native ads interleave among collection APIs only when UMP
                // permits; otherwise the list is purely organic.
                final adsOn = AdsController.shared.canShowAds;
                final organic = apis.length;
                final slots =
                    adsOn ? AdInsertion.slotCount(organic) : organic;
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  itemCount: slots,
                  itemBuilder: (context, index) {
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
                      final api = apis[organicIndex];
                      return ApiCard(
                        key: ValueKey(api.id.isNotEmpty ? api.id : api.link),
                        api: api,
                        category: api.category.isNotEmpty
                            ? api.category
                            : _title(context),
                        sourceScreen:
                            widget.kind == ApiCollectionKind.recommended
                                ? 'recommendation'
                                : 'latest',
                      );
                    }
                    final api = apis[index];
                    return ApiCard(
                      api: api,
                      category: api.category.isNotEmpty
                          ? api.category
                          : _title(context),
                      sourceScreen: widget.kind == ApiCollectionKind.recommended
                          ? 'recommendation'
                          : 'latest',
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
