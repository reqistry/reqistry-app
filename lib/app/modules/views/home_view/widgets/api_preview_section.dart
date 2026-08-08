import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/api.dart' as api_model;
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/latest_api_card.dart';
import 'package:api_scout/shared/widgets/ui/section_header_link.dart';

class ApiPreviewSection extends StatefulWidget {
  final String title;
  final String route;
  final String emptyTitle;
  final String emptyMessage;
  final int refreshTick;
  final Future<List<ApiItem>> Function() fetch;

  const ApiPreviewSection({
    super.key,
    required this.title,
    required this.route,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.refreshTick,
    required this.fetch,
  });

  @override
  State<ApiPreviewSection> createState() => _ApiPreviewSectionState();
}

class _ApiPreviewSectionState extends State<ApiPreviewSection> {
  late Future<List<ApiItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetch();
  }

  @override
  void didUpdateWidget(covariant ApiPreviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      _future = widget.fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderLink(
          title: widget.title,
          onTap: () => context.push(widget.route),
        ),
        const SizedBox(height: AppSpacing.s12),
        FutureBuilder<List<ApiItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(
                message: AppLocalizations.of(context)!.stateLoadingTitle(widget.title.toLowerCase()),
                compact: true,
              );
            }

            if (snapshot.hasError) {
              return AppErrorState(
                title: AppLocalizations.of(context)!.stateCouldNotLoadApis,
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
                        color: c.surface,
                        border: Border.all(
                          color: c.surfaceVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.article,
                            size: 20,
                            color: c.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Text(
                            AppLocalizations.of(context)!.actionViewAll,
                            style: AppTextStyles.labelSmUpper.copyWith(
                              color: c.onSurface,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            PhosphorIconsRegular.arrowRight,
                            size: 16,
                            color: c.onSurfaceVariant,
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
