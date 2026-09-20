import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Local notification service for displaying notifications when app is in foreground
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Stream for notification taps
  final _notificationTapStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationTapStream =>
      _notificationTapStreamController.stream;

  /// Initialize local notifications
  Future<void> init() async {
    if (_isInitialized) return;

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('[LocalNotification] Initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.payload ?? '');
      if (decoded is Map) {
        final envelope = Map<String, dynamic>.from(decoded);
        // New envelope shape carries title/body alongside data.
        if (envelope['data'] is Map &&
            (envelope.containsKey('title') ||
                envelope.containsKey('body'))) {
          data = {
            'data': Map<String, dynamic>.from(envelope['data'] as Map),
            'title': envelope['title'],
            'body': envelope['body'],
          };
        } else {
          data = envelope;
        }
      }
    } catch (_) {}
    _notificationTapStreamController.add(data);
    debugPrint('[LocalNotification] Tapped: $data');
  }

  /// Show foreground notification from FCM message
  Future<void> showForegroundNotification(RemoteMessage message) async {
    if (!_isInitialized) await init();

    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'reqistry_channel',
      'Reqistry Notifications',
      channelDescription: 'Notifications from Reqistry',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        notification.body ?? '',
        contentTitle: notification.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      // Envelope keeps title/body for the in-app alert; the router only
      // reads `data`. Old data-only payloads still decode (see below).
      payload: message.data.isNotEmpty
          ? jsonEncode({
              'data': message.data,
              'title': notification.title,
              'body': notification.body,
            })
          : null,
    );
  }

  /// Show custom local notification
  Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool silent = false,
  }) async {
    if (!_isInitialized) await init();

    final androidDetails = AndroidNotificationDetails(
      'reqistry_channel',
      'Reqistry Notifications',
      channelDescription: 'Notifications from Reqistry',
      importance: silent ? Importance.low : Importance.high,
      priority: silent ? Priority.low : Priority.high,
      icon: '@mipmap/ic_launcher',
      silent: silent,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload);
  }

  /// Cancel a notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Get pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  /// Dispose resources
  void dispose() {
    _notificationTapStreamController.close();
  }
}
