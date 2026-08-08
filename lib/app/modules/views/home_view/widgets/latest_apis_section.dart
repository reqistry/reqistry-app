import 'package:flutter/material.dart';
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
      title: 'RECOMMENDED FOR YOU',
      route: AppRoutes.recommendedApis,
      emptyTitle: 'No recommendations yet',
      emptyMessage: 'Recommendations will appear as you use the catalog.',
      refreshTick: refreshTick,
      fetch: () => RemoteService.getRecommendedApiItems(limit: 3),
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
      title: 'LATEST ADDED',
      route: AppRoutes.latestApis,
      emptyTitle: 'No recent APIs',
      emptyMessage: 'New catalog additions will appear here.',
      refreshTick: refreshTick,
      fetch: () => RemoteService.getRecentlyAddedApis(limit: 3),
    );
  }
}
