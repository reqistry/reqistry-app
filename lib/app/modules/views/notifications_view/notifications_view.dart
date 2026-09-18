import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/config/routes.dart' show routeNotificationTap;
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// In-app notification feed backed by the FCM Hive cache.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  Future<void> _confirmClearAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: l10n.notifFeedClearTitle,
      message: l10n.notifFeedClearMessage,
      confirmLabel: l10n.actionDelete,
      cancelLabel: l10n.actionCancel,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      await context.read<NotificationCubit>().clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        title: Text(
          l10n.notifFeedTitle,
          style: AppTextStyles.headlineSm.copyWith(color: c.onSurface),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationEnabled ||
                  state.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: l10n.notifFeedClearTooltip,
                icon:
                    Icon(PhosphorIconsRegular.trash, color: c.onSurfaceVariant),
                onPressed: () => _confirmClearAll(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return AppLoading(
              message: l10n.stateLoading,
              scrollable: true,
            );
          }
          if (state is NotificationError) {
            return AppErrorState(
              title: l10n.stateError,
              message: l10n.stateSomethingWentWrong,
              onRetry: () => context.read<NotificationCubit>().refresh(),
              scrollable: true,
            );
          }
          if (state is! NotificationEnabled || state.notifications.isEmpty) {
            return AppEmptyState(
              title: l10n.notifFeedEmptyTitle,
              message: l10n.notifFeedEmptyMessage,
              icon: PhosphorIconsRegular.bellSlash,
              scrollable: true,
            );
          }

          final notifications = state.notifications;
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.s8),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(notifications[index]);
                final read = item['read'] == true;
                return Dismissible(
                  key: ValueKey(item['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    final cubit = context.read<NotificationCubit>();
                    final removed = Map<String, dynamic>.from(item);
                    () async {
                      await cubit.removeNotification(item['id'].toString());
                      if (!context.mounted) return;
                      AppSnackbarManager.showSnackbar(
                        context: context,
                        title: l10n.snackbarRemovedTitle,
                        message: l10n.notifFeedRemovedMessage,
                        type: AppSnackbarType.info,
                        actionLabel: l10n.actionUndo,
                        onAction: () =>
                            cubit.restoreNotification(removed, index),
                      );
                    }();
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.s16),
                    color: Theme.of(context).colorScheme.error,
                    child: Icon(PhosphorIconsRegular.trash, color: c.onPrimary),
                  ),
                  child: Card(
                    color: read ? c.surface : c.surfaceContainerHighest,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: c.outlineVariant),
                    ),
                    child: ListTile(
                      leading: Icon(
                        read
                            ? PhosphorIconsRegular.bell
                            : PhosphorIconsFill.bellSimpleRinging,
                        color: read ? c.onSurfaceVariant : c.primary,
                      ),
                      title: Text(
                        item['title']?.toString().isNotEmpty == true
                            ? item['title'].toString()
                            : Env.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.onSurface,
                          fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        item['body']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.onSurfaceVariant),
                      ),
                      trailing: Text(
                        _timeAgo(context, item['timestamp']),
                        style: AppTextStyles.withTabular(
                          TextStyle(fontSize: 12, color: c.onSurfaceVariant),
                        ),
                      ),
                      onTap: () {
                        final cubit = context.read<NotificationCubit>();
                        final data = item['data'];
                        final title = item['title']?.toString();
                        final body = item['body']?.toString();
                        () async {
                          await cubit.markAsRead(item['id'].toString());
                          if (!context.mounted) return;
                          // Pop the feed before pushing the destination so
                          // the new screen is not immediately removed.
                          context.pop();
                          if (data is Map) {
                            routeNotificationTap(
                              Map<String, dynamic>.from(data),
                              title: title,
                              body: body,
                            );
                          }
                        }();
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(BuildContext context, dynamic timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final ts = int.tryParse(timestamp?.toString() ?? '');
    if (ts == null) return '';
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }
}
