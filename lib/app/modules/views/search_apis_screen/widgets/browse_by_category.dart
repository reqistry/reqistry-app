import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/app/modules/views/search_apis_screen/widgets/discover_category_card.dart';

class BrowseByCategory extends StatefulWidget {
  final List<Category> categories;
  final Future<void> Function() onRefresh;

  const BrowseByCategory({
    super.key,
    required this.categories,
    required this.onRefresh,
  });

  @override
  State<BrowseByCategory> createState() => _BrowseByCategoryState();
}

class _BrowseByCategoryState extends State<BrowseByCategory> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Category> get _filtered {
    if (_query.isEmpty) return widget.categories;
    final q = _query.toLowerCase();
    return widget.categories
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Text(
            AppLocalizations.of(context)!.sectionBrowseByCategory,
            style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: TextField(
            controller: _controller,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.formFilterCategoriesHint,
              prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass,
                  color: c.outline, size: 18),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      child: Icon(PhosphorIconsRegular.x,
                          color: c.outline, size: 16),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 64),
                        child: AppEmptyState(
                          title: AppLocalizations.of(context)!.stateNoMatch,
                          message:
                              AppLocalizations.of(context)!.stateNoCategoriesMatch(_query),
                          icon: PhosphorIconsRegular.magnifyingGlass,
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: AppSpacing.s8,
                      mainAxisSpacing: AppSpacing.s8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final category = filtered[index];

                      return GestureDetector(
                        onTap: () => context.push(
                          AppRoutes.categoryApis,
                          extra: category,
                        ),
                        child: DiscoverCategoryCard(category: category),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
