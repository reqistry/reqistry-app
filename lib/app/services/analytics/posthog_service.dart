import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'package:api_scout/config/env.dart';

/// Single entry point for PostHog mobile telemetry (Android + iOS).
///
/// Wraps `posthog_flutter` so call sites stay small and every event carries
/// the same app context. No-op until [init] succeeds with a project token.
class PostHogService {
  PostHogService._();
  static final PostHogService instance = PostHogService._();

  bool _ready = false;
  String _appVersion = '';
  int _buildNumber = 0;

  bool get isReady => _ready;

  Future<void> init() async {
    if (_ready) return;
    final token = Env.posthogProjectToken;
    if (token.isEmpty) {
      debugPrint('[PostHog] missing POSTHOG_PROJECT_TOKEN, telemetry off');
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      _buildNumber = int.tryParse(info.buildNumber) ?? 0;
    } catch (_) {}
    final config = PostHogConfig(token);
    config.host = Env.posthogHost;
    config.debug = kDebugMode;
    config.captureApplicationLifecycleEvents = true;
    config.sessionReplay = true;
    config.sessionReplayConfig.maskAllTexts = true;
    config.sessionReplayConfig.maskAllImages = true;
    await Posthog().setup(config);
    _ready = true;
  }

  Map<String, Object> _context([Map<String, Object>? extra]) => {
        'source': 'mobile',
        if (_appVersion.isNotEmpty) 'app_version': _appVersion,
        if (_buildNumber > 0) 'build_number': _buildNumber,
        ...?extra,
      };

  Future<void> capture(String event,
      [Map<String, Object>? properties]) async {
    if (!_ready) return;
    try {
      await Posthog().capture(
        eventName: event,
        properties: _context(properties),
      );
    } catch (_) {}
  }

  Future<void> screen(String name, [Map<String, Object>? properties]) async {
    if (!_ready) return;
    try {
      await Posthog().screen(
        screenName: name,
        properties: _context(properties),
      );
    } catch (_) {}
  }

  /// Identify with the stable backend device/user id so mobile events join
  /// the same person as server bookmark/folder/project events.
  Future<void> identify({
    required String userId,
    String? email,
    String? name,
    String? authProvider,
  }) async {
    if (!_ready || userId.isEmpty) return;
    try {
      await Posthog().identify(
        userId: userId,
        userProperties: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (name != null && name.isNotEmpty) 'name': name,
          if (authProvider != null && authProvider.isNotEmpty)
            'auth_provider': authProvider,
          'source': 'mobile',
        },
      );
    } catch (_) {}
  }

  Future<void> reset() async {
    if (!_ready) return;
    try {
      await Posthog().reset();
    } catch (_) {}
  }

  Future<void> captureError(Object error, StackTrace? stack,
      [Map<String, Object>? properties]) async {
    if (!_ready) return;
    try {
      await Posthog().captureException(
        error: error,
        stackTrace: stack,
        properties: _context(properties),
      );
    } catch (_) {}
  }

  /// Headers linking backend events/logs/exceptions to this mobile session
  /// in the replay player. Mirrors posthog-js tracing_headers.
  Future<Map<String, String>> tracingHeaders() async {
    if (!_ready) return const {};
    try {
      final distinctId = await Posthog().getDistinctId();
      final sessionId = await Posthog().getSessionId();
      return {
        if (distinctId.isNotEmpty) 'X-POSTHOG-DISTINCT-ID': distinctId,
        if (sessionId != null && sessionId.isNotEmpty)
          'X-POSTHOG-SESSION-ID': sessionId,
      };
    } catch (_) {
      return const {};
    }
  }
}
