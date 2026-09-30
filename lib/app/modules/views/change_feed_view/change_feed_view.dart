import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
import 'package:api_scout/shared/widgets/ads/ad_banner_slot.dart';
import 'package:go_router/go_router.dart';

/// Full registry change feed, opened from the home section "view all".
class ChangeFeedView extends StatefulWidget {
  const ChangeFeedView({super.key});

  @override
  State<ChangeFeedView> createState() => _ChangeFeedViewState();
}

class _ChangeFeedViewState extends State<ChangeFeedView> {
  late Future<List<ChangeFeedEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.getChangeFeed();
  }

  void _reload() {
    setState(() => _future = RemoteService.getChangeFeed());
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.intelligenceChangeFeed, style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: AdBannerSlot(),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<ChangeFeedEvent>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(
                message: l10n.intelligenceChangeFeed,
                scrollable: true,
              );
            }
            if (snapshot.hasError) {
              return AppErrorState(
                title: l10n.stateSomethingWentWrong,
                message: snapshot.error.toString(),
                onRetry: _reload,
                scrollable: true,
              );
            }
            final events = snapshot.data ?? const <ChangeFeedEvent>[];
            if (events.isEmpty) {
              return AppEmptyState(
                title: l10n.intelligenceChangeFeedEmpty,
                message: l10n.statePullToRefresh,
                icon: PhosphorIconsRegular.sparkle,
                scrollable: true,
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ChangeFeedTile(
                  event: event,
                  onTap: () {
                    final slug = event.apiSlug;
                    if (slug == null || slug.isEmpty) return;
                    context.push(AppRoutes.apiDetailPath(slug));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
