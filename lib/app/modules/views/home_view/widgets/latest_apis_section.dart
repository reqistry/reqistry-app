import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/api_preview_section.dart';

class RecommendedApisSection extends StatelessWidget {
  final int refreshTick;

  const RecommendedApisSection({
    super.key,
    required this.refreshTick,
  });

  @override
  Widget build(BuildContext context) {
    return ApiPreviewSection(
      title: AppLocalizations.of(context)!.sectionRecommendedForYou,
      route: AppRoutes.recommendedApis,
      emptyTitle: AppLocalizations.of(context)!.stateNoRecommendationsYet,
      emptyMessage: AppLocalizations.of(context)!.stateRecommendationsWillAppear,
      refreshTick: refreshTick,
      fetch: () => RemoteService.getRecommendedApiItems(limit: 3, l10n: AppLocalizations.of(context)!),
    );
  }
}

class LatestApisSection extends StatelessWidget {
  final int refreshTick;

  const LatestApisSection({
    super.key,
    required this.refreshTick,
  });

  @override
  Widget build(BuildContext context) {
    return ApiPreviewSection(
      title: AppLocalizations.of(context)!.sectionLatestAdded,
      route: AppRoutes.latestApis,
      emptyTitle: AppLocalizations.of(context)!.stateNoRecentApis,
      emptyMessage: AppLocalizations.of(context)!.stateNewCatalogAdditions,
      refreshTick: refreshTick,
      fetch: () => RemoteService.getRecentlyAddedApis(limit: 3, l10n: AppLocalizations.of(context)!),
    );
  }
}
