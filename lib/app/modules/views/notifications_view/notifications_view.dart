import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/config/routes.dart' show routeNotificationTap;

/// In-app notification feed backed by the FCM Hive cache.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        title: Text(
          'Notifications',
          style: TextStyle(color: c.onSurface, fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationEnabled || state.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Clear all',
                icon: Icon(PhosphorIconsRegular.trash, color: c.onSurfaceVariant),
                onPressed: () => context.read<NotificationCubit>().clearAll(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }
          if (state is! NotificationEnabled || state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIconsRegular.bellSlash,
                      size: 48, color: c.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.s8),
                  Text('No notifications yet',
                      style: TextStyle(color: c.onSurfaceVariant)),
                ],
              ),
            );
          }

          final notifications = state.notifications;
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(notifications[index]);
                final read = item['read'] == true;
                return Dismissible(
                  key: ValueKey(item['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => context
                      .read<NotificationCubit>()
                      .removeNotification(item['id'].toString()),
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
                      borderRadius: BorderRadius.circular(12),
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
                            : 'Reqistry',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.onSurface,
                          fontWeight:
                              read ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        item['body']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.onSurfaceVariant),
                      ),
                      trailing: Text(
                        _timeAgo(item['timestamp']),
                        style: TextStyle(
                            fontSize: 11, color: c.onSurfaceVariant),
                      ),
                      onTap: () {
                        final cubit = context.read<NotificationCubit>();
                        final navigator = Navigator.of(context);
                        final data = item['data'];
                        () async {
                          await cubit.markAsRead(item['id'].toString());
                          if (data is Map) {
                            routeNotificationTap(Map<String, dynamic>.from(data));
                          }
                          if (!navigator.mounted) return;
                          navigator.pop();
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

  String _timeAgo(dynamic timestamp) {
    final ts = int.tryParse(timestamp?.toString() ?? '');
    if (ts == null) return '';
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}
