import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'advanced_filters_sheet.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  const SearchHeader({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
            bottom: BorderSide(color: AppColors.surfaceVariant, width: 1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            autofocus: true,
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'Search APIs (e.g., weather, payment...)',
              hintStyle: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass,
                  color: AppColors.onSurface),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.surfaceVariant)),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.surfaceVariant)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.primary, width: 1)),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onSubmitted: (_) {
              final q = searchController.text.trim();
              if (q.isNotEmpty) {
                context.read<SearchBloc>().add(SearchQueryChanged(query: q));
                context.read<SearchBloc>().add(SearchPerformed());
              }
            },
          ),
          const SizedBox(height: AppSpacing.s8),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              final filterCount = _getActiveFilterCount(state);
              return GestureDetector(
                onTap: () => _showAdvancedFilters(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.surfaceVariant, width: 1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.slidersHorizontal,
                          size: 20, color: AppColors.onSurface),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          'FILTERS',
                          style: AppTextStyles.headlineSm
                              .copyWith(color: AppColors.onSurface),
                        ),
                      ),
                      if (filterCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          color: AppColors.primary,
                          child: Text(
                            '$filterCount',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.onPrimary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                      ],
                      const Icon(PhosphorIconsRegular.caretRight,
                          size: 20, color: AppColors.outline),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SearchBloc>(),
        child: const AdvancedFiltersSheet(),
      ),
    );
  }
}

int _getActiveFilterCount(SearchState s) {
  int count = 0;
  if (s.pricing.isNotEmpty) count++;
  if (s.auth.isNotEmpty) count++;
  if (s.apiType.isNotEmpty) count++;
  if (s.category.isNotEmpty) count++;
  if (s.cors != null) count++;
  if (s.https != null) count++;
  if (s.alive != null) count++;
  if (s.maxResponseTime != null) count++;
  return count;
}
