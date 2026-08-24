import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:api_scout/app/services/notification/fcm_service.dart';
import 'package:api_scout/app/services/notification/local_notification_service.dart';
import 'package:api_scout/config/routes.dart';

// State
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationEnabled extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;
  final String? fcmToken;
  final NotificationPreferences? preferences;

  const NotificationEnabled({
    required this.notifications,
    required this.unreadCount,
    this.fcmToken,
    this.preferences,
  });

  @override
  List<Object?> get props =>
      [notifications, unreadCount, fcmToken, preferences];
}

class NotificationDisabled extends NotificationState {
  const NotificationDisabled();
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationPermissionDenied extends NotificationState {
  const NotificationPermissionDenied();
}

// Cubit
class NotificationCubit extends Cubit<NotificationState> {
  final FcmService _fcmService = FcmService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  StreamSubscription? _foregroundSubscription;
  StreamSubscription? _permissionSubscription;
  StreamSubscription? _localTapSubscription;

  NotificationCubit() : super(const NotificationInitial()) {
    _init();
  }

  Future<void> _init() async {
    await _localNotificationService.init();
    await _setupListeners();
    // Best-effort initial load so badges/feeds are correct on cold start.
    // Fails silently when Hive/token aren't ready yet.
    try {
      await _loadNotifications();
    } catch (_) {}
  }

  Future<void> _setupListeners() async {
    _foregroundSubscription = _fcmService.notificationStream.listen((message) {
      _handleForegroundMessage(message);
    });

    _permissionSubscription = _fcmService.permissionStream.listen((settings) {
      _handlePermissionChange(settings);
    });

    _localTapSubscription =
        _localNotificationService.notificationTapStream.listen((data) {
      _fcmService.trackEvent('opened', data);
      routeNotificationTap(data);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _localNotificationService.showForegroundNotification(message);

    if (state is NotificationEnabled) {
      final currentState = state as NotificationEnabled;
      // Normalize to the same shape as the Hive feed cache.
      final entry = {
        'id': message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': Map<String, dynamic>.from(message.data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'read': false,
      };
      final updatedNotifications = [entry, ...currentState.notifications];
      emit(NotificationEnabled(
        notifications: updatedNotifications,
        unreadCount: currentState.unreadCount + 1,
        fcmToken: currentState.fcmToken,
        preferences: currentState.preferences,
      ));
    }
  }

  void _handlePermissionChange(NotificationSettings settings) {
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      emit(const NotificationPermissionDenied());
    }
  }

  Future<void> initializeNotifications() async {
    try {
      emit(const NotificationLoading());
      await _fcmService.init();
      await _loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> requestPermission() async {
    try {
      final settings = await _fcmService.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _loadNotifications();
      } else {
        emit(const NotificationPermissionDenied());
      }
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> enableNotifications() async {
    try {
      emit(const NotificationLoading());
      await _fcmService.enable();
      await _loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> disableNotifications() async {
    try {
      await _fcmService.disable();
      emit(const NotificationDisabled());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _loadNotifications() async {
    final notifications = _fcmService.getInAppNotifications();
    final unreadCount = _fcmService.unreadCount;
    final fcmToken = _fcmService.currentToken;

    if (fcmToken == null || fcmToken.isEmpty) {
      emit(const NotificationDisabled());
      return;
    }

    emit(NotificationEnabled(
      notifications: notifications,
      unreadCount: unreadCount,
      fcmToken: fcmToken,
      preferences: await _fcmService.getPreferences(),
    ));
  }

  Future<void> updatePreference(String key, bool value) async {
    final current = state;
    if (current is! NotificationEnabled) return;
    final preferences = await _fcmService.updatePreference(key, value);
    if (preferences == null) return;
    emit(NotificationEnabled(
      notifications: current.notifications,
      unreadCount: current.unreadCount,
      fcmToken: current.fcmToken,
      preferences: preferences,
    ));
  }

  Future<void> refresh() => _loadNotifications();

  Future<void> markAsRead(String notificationId) async {
    await _fcmService.markAsRead(notificationId);
    await _loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _fcmService.markAllAsRead();
    await _loadNotifications();
  }

  Future<void> removeNotification(String notificationId) async {
    await _fcmService.removeNotification(notificationId);
    await _loadNotifications();
  }

  Future<void> clearAll() async {
    await _fcmService.clearAll();
    await _loadNotifications();
  }

  void handleNotificationTap(Map<String, dynamic> data) {
    routeNotificationTap(data);
  }

  @override
  Future<void> close() {
    _foregroundSubscription?.cancel();
    _permissionSubscription?.cancel();
    _localTapSubscription?.cancel();
    return super.close();
  }
}
