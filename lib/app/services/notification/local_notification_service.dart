import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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

    // Initialize timezone
    tz.initializeTimeZones();

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
      if (decoded is Map) data = Map<String, dynamic>.from(decoded);
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
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
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

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) await init();

    final androidDetails = AndroidNotificationDetails(
      'reqistry_scheduled',
      'Reqistry Scheduled Notifications',
      channelDescription: 'Scheduled notifications from Reqistry',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
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
