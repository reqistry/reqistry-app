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
import 'package:api_scout/l10n/app_localizations.dart';

import '../../../../data/models/category_apis.dart';
import '../../../../data/models/api_detail.dart';

class ApiCard extends StatefulWidget {
  const ApiCard({
    super.key,
    required this.api,
    required this.category,
    this.sourceScreen = 'browse',
  });

  final ApiItem api;
  final String category;
  final String sourceScreen;

  @override
  State<ApiCard> createState() => _ApiCardState();
}

class _ApiCardState extends State<ApiCard> {
  void _navigateToDetail() {
    final slug = widget.api.slug.isNotEmpty
        ? widget.api.slug
        : slugifyApiName(widget.api.name);
    context.push(
      AppRoutes.apiDetailPath(slug, source: widget.sourceScreen),
      extra: widget.api,
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
        favoritesCubit.removeBookmark(bookmarkId,
            l10n: AppLocalizations.of(context)!);
        if (mounted) setState(() {});
      }
    } else {
      if (widget.api.id.isEmpty) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: AppLocalizations.of(context)!.snackbarBookmarkUnavailable,
          message:
              AppLocalizations.of(context)!.snackbarBookmarkUnavailableMessage,
          type: AppSnackbarType.error,
        );
        return;
      }
      favoritesCubit.addBookmark(
          apiId: widget.api.id,
          apiName: widget.api.name,
          l10n: AppLocalizations.of(context)!);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.surfaceVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToDetail,
          highlightColor: c.surfaceContainerHigh,
          splashColor: c.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s12,
                  AppSpacing.s4,
                  AppSpacing.s4,
                  AppSpacing.s4,
                ),
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
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    StatusDot(isAlive: widget.api.isAlive),
                    IconButton(
                      onPressed: _toggleFavorite,
                      tooltip: _isFavorited
                          ? l10n.apiDetailRemoveBookmark
                          : l10n.apiDetailBookmarkApi,
                      constraints:
                          const BoxConstraints.tightFor(width: 48, height: 48),
                      iconSize: 20,
                      icon: Icon(
                        _isFavorited
                            ? PhosphorIconsFill.bookmarkSimple
                            : PhosphorIconsRegular.bookmarkSimple,
                        color: _isFavorited ? c.primary : c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ApiBadgeRow(api: widget.api),
            ],
          ),
        ),
      ),
    );
  }
}
