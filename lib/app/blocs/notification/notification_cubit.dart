import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:api_scout/app/services/notification/fcm_service.dart';
import 'package:api_scout/app/services/notification/local_notification_service.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

class RequestPermission extends NotificationEvent {
  const RequestPermission();
}

class EnableNotifications extends NotificationEvent {
  const EnableNotifications();
}

class DisableNotifications extends NotificationEvent {
  const DisableNotifications();
}

class NotificationReceived extends NotificationEvent {
  final RemoteMessage message;
  const NotificationReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationTapped extends NotificationEvent {
  final Map<String, dynamic> data;
  const NotificationTapped(this.data);

  @override
  List<Object?> get props => [data];
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;
  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

class ClearNotifications extends NotificationEvent {
  const ClearNotifications();
}

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

  const NotificationEnabled({
    required this.notifications,
    required this.unreadCount,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, fcmToken];
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

  NotificationCubit() : super(const NotificationInitial()) {
    _init();
  }

  Future<void> _init() async {
    await _localNotificationService.init();
    await _setupListeners();
  }

  Future<void> _setupListeners() async {
    // Listen for foreground messages
    _foregroundSubscription = _fcmService.notificationStream.listen((message) {
      _handleForegroundMessage(message);
    });

    // Listen for permission changes
    _permissionSubscription = _fcmService.permissionStream.listen((settings) {
      _handlePermissionChange(settings);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification when app is in foreground
    _localNotificationService.showForegroundNotification(message);

    // Add to state
    if (state is NotificationEnabled) {
      final currentState = state as NotificationEnabled;
      final updatedNotifications = [
        message.data,
        ...currentState.notifications
      ];
      emit(NotificationEnabled(
        notifications: updatedNotifications,
        unreadCount: currentState.unreadCount + 1,
        fcmToken: currentState.fcmToken,
      ));
    }
  }

  void _handlePermissionChange(NotificationSettings settings) {
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      emit(const NotificationPermissionDenied());
    }
  }

  /// Initialize notifications
  Future<void> initializeNotifications() async {
    try {
      emit(const NotificationLoading());
      await _fcmService.init();
      await _loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Request permission
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

  /// Enable notifications
  Future<void> enableNotifications() async {
    try {
      emit(const NotificationLoading());
      await _fcmService.enable();
      await _loadNotifications();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Disable notifications
  Future<void> disableNotifications() async {
    try {
      await _fcmService.disable();
      emit(const NotificationDisabled());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Load notifications from cache
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
    ));
  }

  Future<void> refresh() => _loadNotifications();

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _fcmService.markAsRead(notificationId);
    await _loadNotifications();
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    await _fcmService.markAllAsRead();
    await _loadNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    await _fcmService.clearAll();
    await _loadNotifications();
  }

  /// Handle notification tap
  void handleNotificationTap(Map<String, dynamic> data) {
    // Route based on notification type
    // This will be handled by the router
  }

  @override
  Future<void> close() {
    _foregroundSubscription?.cancel();
    _permissionSubscription?.cancel();
    _fcmService.dispose();
    _localNotificationService.dispose();
    return super.close();
  }
}
