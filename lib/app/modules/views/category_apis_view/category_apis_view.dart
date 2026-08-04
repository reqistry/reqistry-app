import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/category_apis/category_apis_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';
import '../apis_view/widgets/api_card.dart';

class CategoryApisView extends StatelessWidget {
  final Object argument;

  const CategoryApisView({super.key, required this.argument});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: BlocBuilder<CategoryApisCubit, CategoryApisState>(
          builder: (context, state) {
            return Text(
              state.categoryTitle.isNotEmpty ? state.categoryTitle : 'Category',
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
          if (state.isLoading) {
            return const AppLoading(message: 'Loading category APIs');
          }

          if (state.errorMessage.isNotEmpty) {
            return AppErrorState(
              title: 'Could not load category',
              message: state.errorMessage,
              onRetry: () => context.read<CategoryApisCubit>().retryFetch(),
            );
          }

          if (state.apis.isEmpty) {
            return const AppEmptyState(
              title: 'No APIs available',
              message:
                  'This category is empty right now. Try another category in the Discover tab.',
              icon: PhosphorIconsRegular.bracketsCurly,
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<CategoryApisCubit>().retryFetch(),
            child: ListView.separated(
              itemCount: state.apis.length + 1,
              padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.itemGap),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategorySummary(state: state);
                }

                final api = state.apis[index - 1];
                return ApiCard(
                  api: api,
                  category: state.categoryTitle,
                );
              },
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
                        child: Text(
                          'TRENDING',
                          style: AppTextStyles.labelSmUpper.copyWith(
                            color: c.onPrimary,
                            fontSize: 9,
                          ),
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
                const SizedBox(height: AppSpacing.sectionGap),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.6,
                  crossAxisSpacing: AppSpacing.s8,
                  mainAxisSpacing: AppSpacing.s8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatTile(label: 'APIS', value: '${apis.length}'),
                    _StatTile(label: 'ALIVE', value: '$aliveCount'),
                    _StatTile(label: 'HTTPS', value: '$httpsCount'),
                    _StatTile(label: 'NO AUTH', value: '$openAuthCount'),
                    _StatTile(
                      label: 'AVG RESPONSE',
                      value: avgResponse > 0 ? '${avgResponse}ms' : 'N/A',
                    ),
                    _StatTile(
                      label: 'CATALOG TOTAL',
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s8),
      decoration: BoxDecoration(
        color: c.background,
        border: Border.all(color: c.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmUpper.copyWith(
              color: c.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLg.copyWith(
              color: c.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
