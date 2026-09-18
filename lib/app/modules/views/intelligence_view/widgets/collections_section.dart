import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Curated task-fit starters from `GET /v1/use-case-collections`.
///
/// Tapping a collection routes into the existing compare view with the
/// collection's API ids: no new result UI, the embedded rows already
/// carry full compare payloads.
class CollectionsSection extends StatefulWidget {
  const CollectionsSection({super.key});

  @override
  State<CollectionsSection> createState() => _CollectionsSectionState();
}

class _CollectionsSectionState extends State<CollectionsSection> {
  late final Future<List<UseCaseCollection>> _future;

  @override
  void initState() {
    super.initState();
    // Silent empty state on failure: collections supplement the manual
    // compare card and must never break the tab.
    _future = RemoteService.getUseCaseCollections()
        .then((value) => value, onError: (_) => <UseCaseCollection>[]);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<UseCaseCollection>>(
      future: _future,
      builder: (context, snapshot) {
        final collections = snapshot.data ?? const <UseCaseCollection>[];
        if (collections.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.intelligenceCollections,
              style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.intelligenceCollectionsSubtitle,
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: c.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            for (var i = 0; i < collections.length; i++)
              _CollectionCard(
                rank: i + 1,
                collection: collections[i],
              ),
          ],
        );
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final int rank;
  final UseCaseCollection collection;

  const _CollectionCard({required this.rank, required this.collection});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final preview = collection.apis.take(3).map((a) => a.name).join(' · ');
    final avg = collection.averageTrust;
    final grade = collection.averageGrade;
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
          onTap: () => context.push(
            AppRoutes.comparePath(collection.apis.map((a) => a.id).toList()),
          ),
          highlightColor: c.surfaceContainerHigh,
          splashColor: c.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rank.toString().padLeft(2, '0'),
                      style: AppTextStyles.withTabular(
                        AppTextStyles.codeMd.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (avg != null && grade != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s2,
                        ),
                        color: c.primary,
                        child: Text(
                          l10n.compareTrustScoreValue(avg, grade),
                          style: AppTextStyles.withTabular(
                            AppTextStyles.labelSmUpper.copyWith(
                              color: c.onPrimary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        l10n.collectionApisCount(collection.apis.length),
                        style: AppTextStyles.withTabular(
                          AppTextStyles.labelSmUpper.copyWith(
                            color: c.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  collection.title.toUpperCase(),
                  style: AppTextStyles.labelSmUpper.copyWith(
                    color: c.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n.collectionApisCount(collection.apis.length),
                  style: AppTextStyles.withTabular(
                    AppTextStyles.labelSmUpper.copyWith(
                      color: c.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    preview,
                    style: AppTextStyles.bodySm.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
