import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
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
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
            bottom: BorderSide(color: c.surfaceVariant, width: 1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            autofocus: true,
            style: AppTextStyles.bodyMd.copyWith(
              decoration: TextDecoration.none,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.formSearchHint,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: c.onSurfaceVariant,
                decoration: TextDecoration.none,
              ),
              prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass,
                  color: c.onSurface),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: c.surfaceVariant)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: c.surfaceVariant)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: c.primary, width: 1)),
              filled: true,
              fillColor: c.surface,
            ),
            onSubmitted: (_) {
              final q = searchController.text.trim();
              if (q.length >= 3) {
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
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: c.surfaceVariant, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsRegular.slidersHorizontal,
                          size: 20, color: c.onSurface),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.sectionFilters,
                          style: AppTextStyles.headlineSm
                              .copyWith(color: c.onSurface),
                        ),
                      ),
                      if (filterCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          color: c.primary,
                          child: Text(
                            '$filterCount',
                            style: AppTextStyles.labelSm
                                .copyWith(color: c.onPrimary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                      ],
                      Icon(PhosphorIconsRegular.caretRight,
                          size: 20, color: c.outline),
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
