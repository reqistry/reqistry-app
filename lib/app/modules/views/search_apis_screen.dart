import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/search_controller/search_controller.dart';
import 'apis_view/widgets/api_card.dart';

class SearchApisScreen extends StatelessWidget {
  const SearchApisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchApiController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: controller.searchTextController,
                    decoration: InputDecoration(
                      hintText: 'Search APIs (e.g., weather, payment...)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          Obx(() => controller.filters.value.hasActiveFilters
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: controller.resetFilters,
                                  tooltip: 'Clear all',
                                )
                              : const SizedBox.shrink()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    onSubmitted: (_) {
                      final q = controller.searchTextController.text.trim();
                      final can = q.isNotEmpty ||
                          controller.filters.value.hasActiveFilters;
                      if (can) controller.performSearch();
                    },
                  ),
                  const SizedBox(height: 8),

                  // Quick Filters
                  Obx(() {
                    final active = controller.activeQuickFilter.value;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickFilterChip(
                            label: 'Free',
                            icon: Icons.money_off,
                            selected: active == 'free',
                            onTap: () {
                              if (active == 'free') {
                                controller.resetFilters();
                              } else {
                                controller.quickFilter(preset: 'free');
                              }
                            },
                          ),
                          _QuickFilterChip(
                            label: 'No Auth',
                            icon: Icons.lock_open,
                            selected: active == 'no-auth',
                            onTap: () {
                              if (active == 'no-auth') {
                                controller.resetFilters();
                              } else {
                                controller.quickFilter(preset: 'no-auth');
                              }
                            },
                          ),
                          _QuickFilterChip(
                            label: 'Fast (<500ms)',
                            icon: Icons.speed,
                            selected: active == 'fast',
                            onTap: () {
                              if (active == 'fast') {
                                controller.resetFilters();
                              } else {
                                controller.quickFilter(preset: 'fast');
                              }
                            },
                          ),
                          _QuickFilterChip(
                            label: 'Secure (HTTPS)',
                            icon: Icons.security,
                            selected: active == 'secure',
                            onTap: () {
                              if (active == 'secure') {
                                controller.resetFilters();
                              } else {
                                controller.quickFilter(preset: 'secure');
                              }
                            },
                          ),
                          _QuickFilterChip(
                            label: 'CORS Enabled',
                            icon: Icons.public,
                            selected: active == 'cors',
                            onTap: () {
                              if (active == 'cors') {
                                controller.resetFilters();
                              } else {
                                controller.quickFilter(preset: 'cors');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Search & Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.searchTextController,
                          builder: (context, value, _) {
                            final can = value.text.trim().isNotEmpty ||
                                controller.filters.value.hasActiveFilters;
                            return FilledButton.icon(
                              onPressed:
                                  can ? () => controller.performSearch() : null,
                              icon: const Icon(Icons.search),
                              label: const Text('Apply search & filters'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _showAdvancedFilters(context, controller),
                        icon: const Icon(Icons.tune),
                        label: Obx(() {
                          final count =
                              _getActiveFilterCount(controller.filters.value);
                          return Text(
                              count > 0 ? 'Filters ($count)' : 'Filters');
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Results
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value &&
                    controller.searchResults.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.searchResults.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search Error',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller.searchTextController,
                            builder: (context, value, _) {
                              final can = value.text.trim().isNotEmpty ||
                                  controller.filters.value.hasActiveFilters;
                              return FilledButton.icon(
                                onPressed: can
                                    ? () => controller.performSearch()
                                    : null,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.searchResults.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 80,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for APIs',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use the search bar and filters above to find APIs',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Results Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${controller.totalResults.value} results',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          // Sort dropdown
                          PopupMenuButton<String>(
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sort,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sort',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            onSelected: (value) {
                              final parts = value.split('_');
                              controller.filters.value.sortBy = parts[0];
                              controller.filters.value.sortOrder = parts[1];
                              controller.filters.refresh();
                              // Apply local sorting immediately
                              controller.applyLocalSort();
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'name_asc',
                                child: Text('Name (A-Z)'),
                              ),
                              const PopupMenuItem(
                                value: 'name_desc',
                                child: Text('Name (Z-A)'),
                              ),
                              const PopupMenuItem(
                                value: 'responseTime_asc',
                                child: Text('Fastest First'),
                              ),
                              const PopupMenuItem(
                                value: 'responseTime_desc',
                                child: Text('Slowest First'),
                              ),
                              const PopupMenuItem(
                                value: 'category_asc',
                                child: Text('Category (A-Z)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Results List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          controller.performSearch();
                          // Wait a moment for the search to complete
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                        },
                        child: ListView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.searchResults.length +
                              (controller.hasMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.searchResults.length) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: controller.isLoadingMore.value
                                      ? const CircularProgressIndicator()
                                      : FilledButton.icon(
                                          onPressed: controller.loadMoreResults,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Load More'),
                                        ),
                                ),
                              );
                            }

                            final api = controller.searchResults[index];
                            final category =
                                controller.filters.value.category.isNotEmpty
                                    ? controller.filters.value.category.first
                                    : 'Search';

                            return ApiCard(
                              api: api,
                              category: category,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  int _getActiveFilterCount(SearchFilters filters) {
    int count = 0;
    if (filters.pricing.isNotEmpty) count++;
    if (filters.auth.isNotEmpty) count++;
    if (filters.apiType.isNotEmpty) count++;
    if (filters.category.isNotEmpty) count++;
    if (filters.cors != null) count++;
    if (filters.https != null) count++;
    if (filters.alive != null) count++;
    if (filters.maxResponseTime != null) count++;
    return count;
  }

  void _showAdvancedFilters(
      BuildContext context, SearchApiController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AdvancedFiltersSheet(controller: controller),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        labelStyle: TextStyle(
          color: selected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurface,
        ),
        avatar: null,
      ),
    );
  }
}

class _AdvancedFiltersSheet extends StatelessWidget {
  final SearchApiController controller;

  const _AdvancedFiltersSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Advanced Filters',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        controller.resetFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Filters List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCategoriesFilter(controller),
                    const SizedBox(height: 16),
                    _buildPricingFilter(controller),
                    const SizedBox(height: 16),
                    _buildAuthFilter(controller),
                    const SizedBox(height: 16),
                    _buildApiTypeFilter(controller),
                    const SizedBox(height: 16),
                    _buildHttpsFilter(controller, theme),
                    const SizedBox(height: 16),
                    _buildCorsFilter(controller),
                    const SizedBox(height: 16),
                    _buildStatusFilter(controller),
                    const SizedBox(height: 16),
                    _buildResponseTimeFilter(controller, theme),
                  ],
                ),
              ),
              // Apply Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: SafeArea(
                  child: FilledButton.icon(
                    onPressed: () {
                      controller.performSearch();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Apply Filters & Search'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesFilter(SearchApiController controller) {
    return _FilterSection(
      title: 'Categories',
      icon: Icons.category,
      child: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.availableCategories
              .map((category) => Obx(() {
                    final isSelected =
                        controller.filters.value.category.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        controller.toggleFilter(
                          controller.filters.value.category,
                          category,
                        );
                      },
                    );
                  }))
              .toList(),
        );
      }),
    );
  }

  Widget _buildPricingFilter(SearchApiController controller) {
    return _FilterSection(
      title: 'Pricing',
      icon: Icons.attach_money,
      child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['free', 'freemium', 'paid'].map((pricing) {
              final isSelected =
                  controller.filters.value.pricing.contains(pricing);
              return FilterChip(
                label: Text(pricing.capitalize!),
                selected: isSelected,
                onSelected: (_) {
                  controller.toggleFilter(
                    controller.filters.value.pricing,
                    pricing,
                  );
                },
              );
            }).toList(),
          )),
    );
  }

  Widget _buildAuthFilter(SearchApiController controller) {
    return _FilterSection(
      title: 'Authentication',
      icon: Icons.vpn_key,
      child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['none', 'apiKey', 'OAuth', 'Bearer'].map((auth) {
              final isSelected = controller.filters.value.auth.contains(auth);
              return FilterChip(
                label: Text(auth == 'none' ? 'No Auth' : auth),
                selected: isSelected,
                onSelected: (_) {
                  controller.toggleFilter(
                    controller.filters.value.auth,
                    auth,
                  );
                },
              );
            }).toList(),
          )),
    );
  }

  Widget _buildApiTypeFilter(SearchApiController controller) {
    return _FilterSection(
      title: 'API Type',
      icon: Icons.api,
      child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ['REST', 'GraphQL', 'SOAP', 'WebSocket', 'gRPC'].map((type) {
              final isSelected =
                  controller.filters.value.apiType.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (_) {
                  controller.toggleFilter(
                    controller.filters.value.apiType,
                    type,
                  );
                },
              );
            }).toList(),
          )),
    );
  }

  Widget _buildHttpsFilter(SearchApiController controller, ThemeData theme) {
    return _FilterSection(
      title: 'HTTPS Support',
      icon: Icons.lock,
      child: Obx(() => Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('HTTPS Only'),
                  selected: controller.filters.value.https == 'true',
                  onSelected: (selected) {
                    controller.filters.value.https = selected ? 'true' : null;
                    controller.filters.refresh();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('HTTP Only'),
                  selected: controller.filters.value.https == 'false',
                  onSelected: (selected) {
                    controller.filters.value.https = selected ? 'false' : null;
                    controller.filters.refresh();
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildCorsFilter(SearchApiController controller) {
    return _FilterSection(
      title: 'CORS Support',
      icon: Icons.public,
      child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['yes', 'no', 'unknown'].map((cors) {
              final isSelected = controller.filters.value.cors == cors;
              return ChoiceChip(
                label: Text(cors == 'yes'
                    ? 'Enabled'
                    : cors == 'no'
                        ? 'Disabled'
                        : 'Unknown'),
                selected: isSelected,
                onSelected: (selected) {
                  controller.filters.value.cors = selected ? cors : null;
                  controller.filters.refresh();
                },
              );
            }).toList(),
          )),
    );
  }

  Widget _buildStatusFilter(SearchApiController controller) {
    return _FilterSection(
      title: 'API Status',
      icon: Icons.power,
      child: Obx(() => Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Working Only'),
                  selected: controller.filters.value.alive == 'true',
                  onSelected: (selected) {
                    controller.filters.value.alive = selected ? 'true' : null;
                    controller.filters.refresh();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Down Only'),
                  selected: controller.filters.value.alive == 'false',
                  onSelected: (selected) {
                    controller.filters.value.alive = selected ? 'false' : null;
                    controller.filters.refresh();
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildResponseTimeFilter(
      SearchApiController controller, ThemeData theme) {
    return _FilterSection(
      title: 'Max Response Time',
      icon: Icons.speed,
      child: Obx(() {
        final maxTime = controller.filters.value.maxResponseTime;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: (maxTime ?? 2000).toDouble(),
                    min: 100,
                    max: 5000,
                    divisions: 49,
                    label: maxTime != null ? '${maxTime}ms' : 'No limit',
                    onChanged: (value) {
                      controller.filters.value.maxResponseTime = value.toInt();
                      controller.filters.refresh();
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    maxTime != null ? '${maxTime}ms' : 'No limit',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (maxTime != null)
              TextButton(
                onPressed: () {
                  controller.filters.value.maxResponseTime = null;
                  controller.filters.refresh();
                },
                child: const Text('Remove limit'),
              ),
          ],
        );
      }),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
