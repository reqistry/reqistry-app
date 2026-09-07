import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/auth/auth_token_service.dart';

/// Hive returns untyped maps. Normalize to string-keyed maps.
/// Prevents `'_Map<dynamic, dynamic>'` cast crash on cache reads.
List<Map<String, dynamic>> _stringKeyedMapList(Object? raw) {
  if (raw is! List) return [];
  return [
    for (final e in raw)
      if (e is Map) Map<String, dynamic>.from(e),
  ];
}

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Hive.initFlutter();
  await Hive.openBox('fcm_cache');

  // Store notification for later display if app is closed
  final cache = Hive.box('fcm_cache');
  final notifications =
      _stringKeyedMapList(cache.get('pending_notifications'));
  notifications.add({
    'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'title': message.notification?.title ?? '',
    'body': message.notification?.body ?? '',
    'data': message.data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'read': false,
  });
  await cache.put('pending_notifications', notifications);
}

/// FCM token state
enum FcmTokenState {
  initial,
  registered,
  revoked,
  error,
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.savedApiHealth,
    required this.newMatchingApis,
    required this.weeklyDigest,
    required this.lifecycleUpdates,
    required this.pricingChanges,
    required this.trustAlerts,
  });

  final bool savedApiHealth;
  final bool newMatchingApis;
  final bool weeklyDigest;
  final bool lifecycleUpdates;
  final bool pricingChanges;
  final bool trustAlerts;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        savedApiHealth: json['savedApiHealth'] != false,
        newMatchingApis: json['newMatchingApis'] != false,
        weeklyDigest: json['weeklyDigest'] != false,
        lifecycleUpdates: json['lifecycleUpdates'] != false,
        pricingChanges: json['pricingChanges'] != false,
        trustAlerts: json['trustAlerts'] != false,
      );

  NotificationPreferences copyWith({
    bool? savedApiHealth,
    bool? newMatchingApis,
    bool? weeklyDigest,
    bool? lifecycleUpdates,
    bool? pricingChanges,
    bool? trustAlerts,
  }) {
    return NotificationPreferences(
      savedApiHealth: savedApiHealth ?? this.savedApiHealth,
      newMatchingApis: newMatchingApis ?? this.newMatchingApis,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      lifecycleUpdates: lifecycleUpdates ?? this.lifecycleUpdates,
      pricingChanges: pricingChanges ?? this.pricingChanges,
      trustAlerts: trustAlerts ?? this.trustAlerts,
    );
  }

  NotificationPreferences withKey(String key, bool value) {
    switch (key) {
      case 'savedApiHealth':
        return copyWith(savedApiHealth: value);
      case 'newMatchingApis':
        return copyWith(newMatchingApis: value);
      case 'weeklyDigest':
        return copyWith(weeklyDigest: value);
      case 'lifecycleUpdates':
        return copyWith(lifecycleUpdates: value);
      case 'pricingChanges':
        return copyWith(pricingChanges: value);
      case 'trustAlerts':
        return copyWith(trustAlerts: value);
      default:
        return this;
    }
  }
}

/// Manages Firebase Cloud Messaging token lifecycle
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AuthTokenService _tokenService = AuthTokenService();

  String? _currentToken;
  FcmTokenState _state = FcmTokenState.initial;
  Box? _cacheBox;
  bool _messageHandlersConfigured = false;
  static void Function(Map<String, dynamic> data,
      {String? title, String? body})? _notificationTapHandler;
  static Map<String, dynamic>? _pendingNotificationTap;
  static String? _pendingNotificationTitle;
  static String? _pendingNotificationBody;

  static set onNotificationTap(
      void Function(Map<String, dynamic> data,
              {String? title, String? body})?
          callback) {
    _notificationTapHandler = callback;
    final pending = _pendingNotificationTap;
    if (callback != null && pending != null) {
      _pendingNotificationTap = null;
      final title = _pendingNotificationTitle;
      final body = _pendingNotificationBody;
      _pendingNotificationTitle = null;
      _pendingNotificationBody = null;
      scheduleMicrotask(
          () => callback(pending, title: title, body: body));
    }
  }

  // Stream controllers
  final _tokenStreamController = StreamController<String?>.broadcast();
  final _notificationStreamController =
      StreamController<RemoteMessage>.broadcast();
  final _permissionStreamController =
      StreamController<NotificationSettings>.broadcast();

  /// Stream of FCM token changes
  Stream<String?> get tokenStream => _tokenStreamController.stream;

  /// Stream of incoming notifications
  Stream<RemoteMessage> get notificationStream =>
      _notificationStreamController.stream;

  /// Stream of permission changes
  Stream<NotificationSettings> get permissionStream =>
      _permissionStreamController.stream;

  /// Current FCM token
  String? get currentToken => _currentToken;

  /// Current token state
  FcmTokenState get state => _state;

  /// Initialize FCM service
  Future<void> init() async {
    try {
      _cacheBox = await Hive.openBox('fcm_cache');

      if (_cacheBox!.get('notifications_enabled', defaultValue: true) ==
          false) {
        _state = FcmTokenState.revoked;
        if (!_messageHandlersConfigured) {
          FirebaseMessaging.onBackgroundMessage(
              firebaseMessagingBackgroundHandler);
          _configureMessageHandling();
          _messageHandlersConfigured = true;
        }
        await _mergePendingNotifications();
        return;
      }

      // Request permission
      await requestPermission();

      // Get initial token
      _currentToken = await _messaging.getToken();
      _tokenStreamController.add(_currentToken);

      // Configure listeners once — init() can be called from bootstrap and
      // again from feature cubits; listeners must not stack.
      if (!_messageHandlersConfigured) {
        _messaging.onTokenRefresh.listen((newToken) {
          _currentToken = newToken;
          _tokenStreamController.add(newToken);
          _updateTokenOnBackend(newToken);
        });

        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);
        _configureMessageHandling();
        _messageHandlersConfigured = true;
      }

      // Fold notifications received while terminated into the in-app feed.
      await _mergePendingNotifications();

      debugPrint(
          '[FCM] Initialized with token: ${_currentToken?.substring(0, 20)}...');
    } catch (e) {
      debugPrint('[FCM] Initialization error: $e');
      _state = FcmTokenState.error;
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      carPlay: false,
      announcement: false,
    );

    _permissionStreamController.add(settings);

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Check current permission status
  Future<NotificationSettings> getPermissionSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  Future<bool> get isNotificationsEnabled async {
    final settings = await getPermissionSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Configure foreground and background message handling
  void _configureMessageHandling() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
      _notificationStreamController.add(message);

      // Store in cache for in-app display
      _storeNotification(message);
      trackEvent('received', message.data);
    });

    // Handle background messages (when app is opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Message opened app: ${message.messageId}');
      trackEvent('opened', message.data);
      _handleNotificationTap(
        message.data,
        title: message.notification?.title,
        body: message.notification?.body,
      );
    });

    // Check if app was opened from a terminated state via notification
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('[FCM] Initial message: ${message.messageId}');
        trackEvent('opened', message.data);
        _handleNotificationTap(
          message.data,
          title: message.notification?.title,
          body: message.notification?.body,
        );
      }
    });
  }

  /// Store notification in local cache
  void _storeNotification(RemoteMessage message) {
    if (_cacheBox == null) return;

    final notifications = _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );

    notifications.insert(0, {
      'id':
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'read': false,
    });

    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }

    _cacheBox!.put('in_app_notifications', notifications);
  }

  /// Handle notification tap - route to appropriate screen
  void _handleNotificationTap(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    final callback = _notificationTapHandler;
    if (callback != null) {
      callback(data, title: title, body: body);
    } else {
      _pendingNotificationTap = Map<String, dynamic>.from(data);
      _pendingNotificationTitle = title;
      _pendingNotificationBody = body;
    }
  }

  Future<void> trackEvent(String eventType, Map<String, dynamic> data) async {
    try {
      await DioClient().dio.post(
            '/v1/notifications/events',
            data: {
              if (data['deliveryId'] != null) 'deliveryId': data['deliveryId'],
              if (data['apiId'] != null) 'apiId': data['apiId'],
              'eventType': eventType,
              'metadata': {
                if (data['type'] != null) 'type': data['type'],
                if (data['action'] != null) 'action': data['action'],
              },
            },
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
    } catch (_) {}
  }

  Future<NotificationPreferences?> getPreferences() async {
    try {
      final response = await DioClient().dio.get(
            '/v1/notifications/preferences',
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
      return NotificationPreferences.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<NotificationPreferences?> updatePreference(
      String key, bool value) async {
    try {
      final response = await DioClient().dio.patch(
            '/v1/notifications/preferences',
            data: {key: value},
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
      return NotificationPreferences.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Move terminated-state notifications into the in-app feed.
  Future<void> _mergePendingNotifications() async {
    if (_cacheBox == null) return;
    final pending = _stringKeyedMapList(
      _cacheBox!.get('pending_notifications'),
    );
    if (pending.isEmpty) return;

    final notifications = _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );
    final existingIds = notifications.map((n) => n['id']).toSet();
    for (final item in pending) {
      if (!existingIds.contains(item['id'])) {
        notifications.insert(0, item);
      }
    }
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }
    await _cacheBox!.put('in_app_notifications', notifications);
    await _cacheBox!.put('pending_notifications', []);
  }

  /// Register FCM token with backend
  Future<bool> registerTokenOnBackend() async {
    if (_currentToken == null) return false;

    try {
      final dio = DioClient().dio;
      final response = await dio.post(
        '/v1/fcm-tokens',
        data: {
          'token': _currentToken,
          'platform':
              defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        },
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _state = FcmTokenState.registered;
        debugPrint('[FCM] Token registered on backend');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
      _state = FcmTokenState.error;
      return false;
    }
  }

  /// Revoke FCM token from backend
  Future<bool> revokeTokenOnBackend() async {
    if (_currentToken == null) return false;

    try {
      final dio = DioClient().dio;
      final response = await dio.delete(
        '/v1/fcm-tokens',
        data: {'token': _currentToken},
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );

      if (response.statusCode == 200) {
        _state = FcmTokenState.revoked;
        debugPrint('[FCM] Token revoked on backend');
        return true;
      }
      return false;
    } catch (e) {
      // 404 means the token is already gone server-side, which is the
      // desired end state (e.g. fresh install reusing a Firebase token).
      if (e is DioException && e.response?.statusCode == 404) {
        _state = FcmTokenState.revoked;
        return true;
      }
      debugPrint('[FCM] Failed to revoke token: $e');
      return false;
    }
  }

  /// Update token on backend (called on token refresh)
  Future<void> _updateTokenOnBackend(String newToken) async {
    if (_tokenService.isAuthenticated) {
      await registerTokenOnBackend();
    }
  }

  /// Rotate FCM token: delete current token from Firebase, then get a new one
  Future<String?> rotateToken() async {
    try {
      await _messaging.deleteToken();
      _currentToken = null;
      _tokenStreamController.add(null);

      final newToken = await _messaging.getToken();
      _currentToken = newToken;
      _tokenStreamController.add(newToken);

      debugPrint('[FCM] Token rotated: ${newToken?.substring(0, 20)}...');
      return newToken;
    } catch (e) {
      debugPrint('[FCM] Failed to rotate token: $e');
      return null;
    }
  }

  /// Enable FCM for authenticated user
  /// Flow: request permission → revoke old token → rotate → register new token
  Future<void> enable() async {
    if (!_tokenService.isAuthenticated) return;
    await _cacheBox?.put('notifications_enabled', true);

    final hasPermission = await isNotificationsEnabled;
    if (!hasPermission) {
      await requestPermission();
    }

    await _revokeRotateAndRegister();
  }

  /// Disable FCM and leave backend token revoked.
  Future<void> disable() async {
    await revokeTokenOnBackend();
    await _messaging.deleteToken();
    await _cacheBox?.put('notifications_enabled', false);
    _currentToken = null;
    _state = FcmTokenState.revoked;
    _tokenStreamController.add(null);
  }

  /// Core flow: revoke current token → rotate via Firebase → register new token
  Future<void> _revokeRotateAndRegister() async {
    try {
      // 1. Revoke the current token from the backend
      await revokeTokenOnBackend();

      // 2. Rotate the FCM token via Firebase (delete old, get new)
      await rotateToken();

      // 3. Register the new token on the backend
      if (_currentToken != null && _tokenService.isAuthenticated) {
        await registerTokenOnBackend();
      }
    } catch (e) {
      debugPrint('[FCM] Failed in revoke-rotate-register flow: $e');
    }
  }

  /// Get all registered tokens from backend
  Future<List<Map<String, dynamic>>> getRegisteredTokens() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/v1/fcm-tokens');
      final tokens = response.data['tokens'] as List? ?? [];
      return List<Map<String, dynamic>>.from(tokens);
    } catch (e) {
      debugPrint('[FCM] Failed to get tokens: $e');
      return [];
    }
  }

  /// Get in-app notifications from cache
  List<Map<String, dynamic>> getInAppNotifications() {
    if (_cacheBox == null) return [];
    return _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_cacheBox == null) return;

    final notifications = _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );

    final index = notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      notifications[index]['read'] = true;
      await _cacheBox!.put('in_app_notifications', notifications);
    }
  }

  /// Remove a single notification from the feed
  Future<void> removeNotification(String notificationId) async {
    if (_cacheBox == null) return;

    final notifications = _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );
    notifications.removeWhere((n) => n['id'] == notificationId);
    await _cacheBox!.put('in_app_notifications', notifications);
  }

  /// Restores a removed notification at its former position (swipe-undo).
  Future<void> restoreNotification(
      Map<String, dynamic> entry, int index) async {
    if (_cacheBox == null) return;
    final notifications = _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );
    if (notifications.any((n) => n['id'] == entry['id'])) return;
    final at = index.clamp(0, notifications.length);
    notifications.insert(at, Map<String, dynamic>.from(entry));
    await _cacheBox!.put('in_app_notifications', notifications);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_cacheBox == null) return;

    final notifications = _stringKeyedMapList(
      _cacheBox!.get('in_app_notifications'),
    );

    for (var i = 0; i < notifications.length; i++) {
      notifications[i]['read'] = true;
    }

    await _cacheBox!.put('in_app_notifications', notifications);
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    await _cacheBox?.put('in_app_notifications', []);
  }

  /// Get unread notification count
  int get unreadCount {
    final notifications = getInAppNotifications();
    return notifications.where((n) => n['read'] == false).length;
  }

  /// Dispose resources
  void dispose() {
    _tokenStreamController.close();
    _notificationStreamController.close();
    _permissionStreamController.close();
  }
}
