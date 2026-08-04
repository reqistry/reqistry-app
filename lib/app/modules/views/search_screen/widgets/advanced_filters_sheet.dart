import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/search/quick_filter_chip.dart';

class AdvancedFiltersSheet extends StatelessWidget {
  const AdvancedFiltersSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            final c = AppColors.of(Theme.of(context).brightness);
            return Container(
              decoration: BoxDecoration(
                  color: c.surface, borderRadius: BorderRadius.zero),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: AppSpacing.s12, bottom: AppSpacing.s8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: c.outlineVariant,
                        borderRadius: BorderRadius.zero),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      children: [
                        Icon(PhosphorIconsRegular.slidersHorizontal,
                            color: c.primary),
                        const SizedBox(width: AppSpacing.s12),
                        Text('Advanced Filters',
                            style: AppTextStyles.headlineSm
                                .copyWith(color: c.onSurface)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context
                                .read<SearchBloc>()
                                .add(SearchFiltersReset());
                            Navigator.pop(context);
                          },
                          child: Text('RESET ALL',
                              style: AppTextStyles.labelSmUpper.copyWith(
                                  color: c.primary, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: c.surfaceVariant),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      children: [
                        _buildCategoriesFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildPricingFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildAuthFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildApiTypeFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildHttpsFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildCorsFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildStatusFilter(context, state),
                        const SizedBox(height: AppSpacing.s16),
                        _buildResponseTimeFilter(context, state),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                        color: c.surface,
                        border: Border(
                            top: BorderSide(
                                color: c.surfaceVariant, width: 1))),
                    child: SafeArea(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<SearchBloc>().add(SearchPerformed());
                          Navigator.pop(context);
                        },
                        icon: const Icon(PhosphorIconsRegular.magnifyingGlass,
                            size: 18),
                        label: Text('APPLY FILTERS & SEARCH',
                            style: AppTextStyles.labelSmUpper
                                .copyWith(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: c.onPrimary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'CATEGORIES',
      icon: PhosphorIconsRegular.squaresFour,
      child: state.isLoadingCategories
          ? Center(
              child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s16),
                  child: CircularProgressIndicator(color: AppColors.of(Theme.of(context).brightness).primary)))
          : Wrap(
              spacing: AppSpacing.chipGap,
              runSpacing: AppSpacing.chipGap,
              children: state.availableCategories.map((category) {
                final isSelected = state.category.contains(category);
                return DesignChip(
                  label: category,
                  selected: isSelected,
                  onTap: () => context.read<SearchBloc>().add(
                      SearchFilterToggled(
                          filterType: FilterType.category, value: category)),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPricingFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'PRICING',
      icon: PhosphorIconsRegular.currencyDollar,
      child: Wrap(
        spacing: AppSpacing.chipGap,
        runSpacing: AppSpacing.chipGap,
        children: ['free', 'freemium', 'paid'].map((pricing) {
          final isSelected = state.pricing.contains(pricing);
          return DesignChip(
            label: pricing.toUpperCase(),
            selected: isSelected,
            onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                filterType: FilterType.pricing, value: pricing)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAuthFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'AUTHENTICATION',
      icon: PhosphorIconsRegular.key,
      child: Wrap(
        spacing: AppSpacing.chipGap,
        runSpacing: AppSpacing.chipGap,
        children: ['none', 'apiKey', 'OAuth', 'Bearer'].map((auth) {
          final isSelected = state.auth.contains(auth);
          return DesignChip(
            label: auth == 'none' ? 'NO AUTH' : auth.toUpperCase(),
            selected: isSelected,
            onTap: () => context.read<SearchBloc>().add(
                SearchFilterToggled(filterType: FilterType.auth, value: auth)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApiTypeFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'API TYPE',
      icon: PhosphorIconsRegular.bracketsCurly,
      child: Wrap(
        spacing: AppSpacing.chipGap,
        runSpacing: AppSpacing.chipGap,
        children: ['REST', 'GraphQL', 'SOAP', 'WebSocket', 'gRPC'].map((type) {
          final isSelected = state.apiType.contains(type);
          return DesignChip(
            label: type.toUpperCase(),
            selected: isSelected,
            onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                filterType: FilterType.apiType, value: type)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHttpsFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'HTTPS SUPPORT',
      icon: PhosphorIconsRegular.lock,
      child: Row(
        children: [
          Expanded(
            child: DesignChip(
              label: 'HTTPS ONLY',
              selected: state.https == true,
              onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                  filterType: FilterType.https,
                  value: (state.https == true ? null : true).toString())),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: DesignChip(
              label: 'HTTP ONLY',
              selected: state.https == false,
              onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                  filterType: FilterType.https,
                  value: (state.https == false ? null : false).toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorsFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'CORS SUPPORT',
      icon: PhosphorIconsRegular.globeHemisphereWest,
      child: Wrap(
        spacing: AppSpacing.chipGap,
        runSpacing: AppSpacing.chipGap,
        children: ['yes', 'no', 'unknown'].map((cors) {
          final isSelected = state.cors == cors;
          return DesignChip(
            label: cors == 'yes'
                ? 'ENABLED'
                : cors == 'no'
                    ? 'DISABLED'
                    : 'UNKNOWN',
            selected: isSelected,
            onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                filterType: FilterType.cors,
                value: (state.cors == cors ? null : cors).toString())),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'API STATUS',
      icon: PhosphorIconsRegular.power,
      child: Row(
        children: [
          Expanded(
            child: DesignChip(
              label: 'WORKING ONLY',
              selected: state.alive == true,
              onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                  filterType: FilterType.alive,
                  value: (state.alive == true ? null : true).toString())),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: DesignChip(
              label: 'DOWN ONLY',
              selected: state.alive == false,
              onTap: () => context.read<SearchBloc>().add(SearchFilterToggled(
                  filterType: FilterType.alive,
                  value: (state.alive == false ? null : false).toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeFilter(BuildContext context, SearchState state) {
    return FilterSection(
      title: 'MAX RESPONSE TIME',
      icon: PhosphorIconsRegular.speedometer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: (state.maxResponseTime ?? 2000).toDouble(),
                  min: 100,
                  max: 5000,
                  divisions: 49,
                  label: state.maxResponseTime != null
                      ? '${state.maxResponseTime}ms'
                      : 'No limit',
                  activeColor: AppColors.of(Theme.of(context).brightness).primary,
                  inactiveColor: AppColors.of(Theme.of(context).brightness).surfaceVariant,
                  onChanged: (value) => context.read<SearchBloc>().add(
                      SearchFilterToggled(
                          filterType: FilterType.maxResponseTime,
                          value: value.toInt().toString())),
                ),
              ),
              SizedBox(
                  width: 80,
                  child: Text(
                      state.maxResponseTime != null
                          ? '${state.maxResponseTime}ms'
                          : 'No limit',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.of(Theme.of(context).brightness).onSurface))),
            ],
          ),
          if (state.maxResponseTime != null)
            TextButton(
              onPressed: () => context.read<SearchBloc>().add(
                  SearchFilterToggled(
                      filterType: FilterType.maxResponseTime, value: 'null')),
              child: Text('REMOVE LIMIT',
                  style: AppTextStyles.labelSmUpper
                      .copyWith(color: AppColors.of(Theme.of(context).brightness).primary, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
