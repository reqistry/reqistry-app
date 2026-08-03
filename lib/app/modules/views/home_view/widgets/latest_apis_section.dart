import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

import 'package:api_scout/app/data/models/api.dart' as api_model;

import 'latest_api_card.dart';

class RecommendedApisSection extends StatelessWidget {
  final int refreshTick;

  const RecommendedApisSection({
    super.key,
    required this.refreshTick,
  });

  @override
  Widget build(BuildContext context) {
    return _ApiPreviewSection(
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
    return _ApiPreviewSection(
      title: 'LATEST ADDED',
      route: AppRoutes.latestApis,
      emptyTitle: 'No recent APIs',
      emptyMessage: 'New catalog additions will appear here.',
      refreshTick: refreshTick,
      fetch: () => RemoteService.getRecentlyAddedApis(limit: 3),
    );
  }
}

class _ApiPreviewSection extends StatefulWidget {
  final String title;
  final String route;
  final String emptyTitle;
  final String emptyMessage;
  final int refreshTick;
  final Future<List<ApiItem>> Function() fetch;

  const _ApiPreviewSection({
    required this.title,
    required this.route,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.refreshTick,
    required this.fetch,
  });

  @override
  State<_ApiPreviewSection> createState() => _ApiPreviewSectionState();
}

class _ApiPreviewSectionState extends State<_ApiPreviewSection> {
  late Future<List<ApiItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetch();
  }

  @override
  void didUpdateWidget(covariant _ApiPreviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      _future = widget.fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push(widget.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.labelSmUpper.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                const Icon(
                  PhosphorIconsRegular.arrowRight,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        FutureBuilder<List<ApiItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(
                message: 'Loading ${widget.title.toLowerCase()}',
                compact: true,
              );
            }

            if (snapshot.hasError) {
              return AppErrorState(
                title: 'Could not load APIs',
                message: snapshot.error.toString(),
                compact: true,
              );
            }

            final apis = (snapshot.data ?? const <ApiItem>[])
                .where((api) => api.link.isNotEmpty)
                .toList();

            if (apis.isEmpty) {
              return AppEmptyState(
                title: widget.emptyTitle,
                message: widget.emptyMessage,
                icon: PhosphorIconsRegular.bracketsCurly,
                compact: true,
              );
            }

            return Column(
              children: [
                ...apis.map((api) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s4,
                    ),
                    child: LatestApiCard(
                      api: api,
                      onTap: () => context.push(
                        AppRoutes.apiDetailPath(slugifyApiName(api.name)),
                        extra: _toApi(api),
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s4,
                  ),
                  child: GestureDetector(
                    onTap: () => context.push(widget.route),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.surfaceVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            PhosphorIconsRegular.article,
                            size: 20,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Text(
                            'VIEW ALL',
                            style: AppTextStyles.labelSmUpper.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            PhosphorIconsRegular.arrowRight,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  api_model.Api _toApi(ApiItem item) {
    return api_model.Api(
      id: item.id,
      slug: slugifyApiName(item.name),
      name: item.name,
      description: item.description,
      auth: item.auth,
      https: item.supportsHttps,
      cors: item.supportsCors,
      link: item.link,
      categoryId: item.category,
      pricing: item.pricing,
      alive: item.isAlive,
      documentationUrl: item.documentation,
      apiType: item.apiType,
      rateLimit: item.rateLimit,
      corsStatus: item.cors,
      responseTimeMs: item.responseTime,
      statusCode: item.statusCode,
      lastCheckedAt: item.lastCheckedDateTime,
    );
  }
}
