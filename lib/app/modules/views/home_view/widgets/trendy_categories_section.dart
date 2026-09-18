import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/trending_category_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/ui/section_header_link.dart';

/// Trending categories rail on Home.
///
/// Same section language as the other home sections: header link plus
/// horizontal content. Shows trendy-flagged categories only; header
/// jumps to the Explore tab, cards open the category page.
class TrendyCategoriesSection extends StatelessWidget {
  const TrendyCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return BlocBuilder<HomeCategoriesCubit, HomeCategoriesState>(
      builder: (context, state) {
        final trendy = [
          for (final category in state.categories)
            if (category.hasTrendyBorder) category,
        ];
        if (trendy.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeaderLink(
              title:
                  AppLocalizations.of(context)!.sectionTrendingCategories,
              onTap: () => context
                  .read<MainShellCubit>()
                  .selectTab(AppRoutes.tabIndexSearch),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              height: 156,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                ),
                itemCount: trendy.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.s8),
                itemBuilder: (context, index) {
                  final category = trendy[index];
                  return SizedBox(
                    width: 184,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: ValueKey(category.id),
                        onTap: () => context.push(
                          AppRoutes.categoryApis,
                          extra: category,
                        ),
                        highlightColor: c.surfaceContainerHigh,
                        splashColor: c.surfaceContainerHighest,
                        child: TrendingCategoryCard(
                          category: category,
                          rank: index + 1,
                          total: trendy.length,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
