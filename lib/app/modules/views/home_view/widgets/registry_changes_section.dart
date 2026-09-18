import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/modules/views/intelligence_view/widgets/change_feed_tile.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/ui/section_header_link.dart';

/// Home section previewing the registry change feed (3 latest events).
class RegistryChangesSection extends StatefulWidget {
  final int refreshTick;

  const RegistryChangesSection({super.key, required this.refreshTick});

  @override
  State<RegistryChangesSection> createState() => _RegistryChangesSectionState();
}

class _RegistryChangesSectionState extends State<RegistryChangesSection> {
  late Future<List<ChangeFeedEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant RegistryChangesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      _future = _load();
    }
  }

  Future<List<ChangeFeedEvent>> _load() {
    return RemoteService.getChangeFeed(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderLink(
          title: l10n.intelligenceChangeFeed,
          onTap: () => context.push(AppRoutes.changeFeed),
        ),
        const SizedBox(height: AppSpacing.s12),
        FutureBuilder<List<ChangeFeedEvent>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(compact: true);
            }
            if (snapshot.hasError) {
              return AppErrorState(
                title: l10n.stateSomethingWentWrong,
                message: snapshot.error.toString(),
                compact: true,
              );
            }
            final events = snapshot.data ?? const <ChangeFeedEvent>[];
            if (events.isEmpty) {
              return AppEmptyState(
                title: l10n.intelligenceChangeFeedEmpty,
                icon: PhosphorIconsRegular.sparkle,
                compact: true,
              );
            }
            final c = AppColors.of(Theme.of(context).brightness);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  child: Column(
                    children: [
                      for (final event in events)
                        ChangeFeedTile(
                          event: event,
                          onTap: () => _openEvent(event),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s4,
                  ),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.changeFeed),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: c.surface,
                        border: Border.all(
                          color: c.surfaceVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.article,
                            size: 20,
                            color: c.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Text(
                            l10n.actionViewAll,
                            style: AppTextStyles.labelSmUpper.copyWith(
                              color: c.onSurface,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            PhosphorIconsRegular.arrowRight,
                            size: 16,
                            color: c.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _openEvent(ChangeFeedEvent event) {
    final slug = event.apiSlug;
    if (slug == null || slug.isEmpty) return;
    context.push(AppRoutes.apiDetailPath(slug));
  }
}
