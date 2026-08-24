import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart' show AppRoutes;
import 'package:api_scout/config/routes.dart' show AppRouter;
import 'package:api_scout/l10n/app_localizations.dart';

/// Registry change feed backed by GET /v1/change-feed.
class ChangeFeedSection extends StatefulWidget {
  const ChangeFeedSection({super.key});

  @override
  State<ChangeFeedSection> createState() => ChangeFeedSectionState();
}

class ChangeFeedSectionState extends State<ChangeFeedSection> {
  late Future<List<ChangeFeedEvent>> _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.getChangeFeed();
  }

  Future<void> reload() async {
    setState(() => _future = RemoteService.getChangeFeed());
    await _future;
  }

  Future<void> _reload() async {
    setState(() => _future = RemoteService.getChangeFeed());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.intelligenceChangeFeed, style: AppTextStyles.labelSmUpper),
        const SizedBox(height: AppSpacing.s12),
        FutureBuilder<List<ChangeFeedEvent>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.s24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  Text(
                    l10n.stateSomethingWentWrong,
                    style: AppTextStyles.labelSm
                        .copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  TextButton(
                      onPressed: _reload, child: Text(l10n.actionRetry)),
                ],
              );
            }
            final events = snapshot.data ?? const <ChangeFeedEvent>[];
            if (events.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Text(
                  l10n.intelligenceChangeFeedEmpty,
                  style:
                      AppTextStyles.labelSm.copyWith(color: c.onSurfaceVariant),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.fromBorderSide(BorderSide(color: c.outline)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < events.length; i++) ...[
                    _feedRow(c, events[i]),
                    if (i != events.length - 1)
                      Divider(height: 1, thickness: 1, color: c.surfaceVariant),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _feedRow(AppColorScheme c, ChangeFeedEvent event) {
    final time = DateFormat.MMMd().add_Hm().format(event.createdAt.toLocal());
    final slug = event.apiSlug;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: 2),
      leading: Icon(_eventIcon(event.eventType), size: 20, color: c.info),
      title: Text(event.title,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(time,
          style: AppTextStyles.labelSm.copyWith(color: c.onSurfaceVariant)),
      onTap: slug == null || slug.isEmpty
          ? null
          : () => AppRouter.router.push(AppRoutes.apiDetailPath(slug)),
    );
  }

  IconData _eventIcon(String eventType) {
    switch (eventType) {
      case 'trust_score_changed':
        return PhosphorIconsRegular.sealCheck;
      case 'price_changed':
      case 'pricing_changed':
        return PhosphorIconsRegular.currencyDollar;
      case 'health_changed':
        return PhosphorIconsRegular.pulse;
      default:
        return PhosphorIconsRegular.sparkle;
    }
  }
}
