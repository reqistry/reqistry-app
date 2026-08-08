import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/shared/widgets/api/status_dot.dart';
import 'package:api_scout/shared/widgets/api/api_badge_row.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';

import '../../../../data/models/category_apis.dart';
import '../../../../data/models/api_detail.dart';
import '../../../../data/models/api.dart' as new_api;

class ApiCard extends StatefulWidget {
  const ApiCard({
    super.key,
    required this.api,
    required this.category,
  });

  final ApiItem api;
  final String category;

  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  void _navigateToDetail() {
    final newApiModel = new_api.Api(
      id: widget.api.id,
      slug: slugifyApiName(widget.api.name),
      name: widget.api.name,
      description: widget.api.description,
      auth: widget.api.auth,
      https: widget.api.supportsHttps,
      cors: widget.api.supportsCors,
      link: widget.api.link,
      imageUrl: widget.api.imageUrl,
      categoryId: widget.api.category.isNotEmpty
          ? widget.api.category
          : widget.category,
      pricing: widget.api.pricing,
      alive: widget.api.isAlive,
      documentationUrl: widget.api.documentation,
      apiType: widget.api.apiType,
      rateLimit: widget.api.rateLimit,
      corsStatus: widget.api.cors,
      responseTimeMs: widget.api.responseTime,
      statusCode: widget.api.statusCode,
      lastCheckedAt: widget.api.lastCheckedDateTime,
    );
    context.push(
      AppRoutes.apiDetailPath(newApiModel.slug),
      extra: newApiModel,
    );
  }

  bool get _isFavorited {
    return context.read<FavoritesCubit>().isFavorited(widget.api.link);
  }

  void _toggleFavorite() {
    final favoritesCubit = context.read<FavoritesCubit>();
    if (_isFavorited) {
      final bookmarkId = favoritesCubit.getBookmarkId(widget.api.link);
      if (bookmarkId != null) {
        favoritesCubit.removeBookmark(bookmarkId);
        if (mounted) setState(() {});
      }
    } else {
      if (widget.api.id.isEmpty) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: 'Bookmark unavailable',
          message: 'This API is missing a backend ID.',
          type: AppSnackbarType.error,
        );
        return;
      }
      favoritesCubit.addBookmark(
          apiId: widget.api.id, apiName: widget.api.name);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.surfaceVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Row(
                children: [
                  CategoryImagePlaceholder(
                    name: widget.api.name,
                    imageUrl: widget.api.imageUrl,
                    size: 40,
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.api.name,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          widget.api.category.isNotEmpty
                              ? widget.api.category
                              : widget.category,
                          style: AppTextStyles.labelSmUpper.copyWith(
                            color: c.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  StatusDot(isAlive: widget.api.isAlive),
                  const SizedBox(width: AppSpacing.s8),
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      _isFavorited
                          ? PhosphorIconsFill.bookmarkSimple
                          : PhosphorIconsRegular.bookmarkSimple,
                      size: 20,
                      color: _isFavorited
                          ? c.primary
                          : c.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ApiBadgeRow(api: widget.api),
          ],
        ),
      ),
    );
  }
}
