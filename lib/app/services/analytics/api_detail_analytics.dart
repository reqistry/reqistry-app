import 'dart:async';

import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/analytics/posthog_service.dart';
import 'package:dio/dio.dart';

class ApiDetailAnalytics {
  ApiDetailAnalytics._();
  static final String _sessionId =
      'mobile-${DateTime.now().microsecondsSinceEpoch}';
  static final Set<String> _evaluatedSearchApis = {};
  static final Set<String> _qualifiedSearchApis = {};

  static void trackSearch({
    required String? query,
    required bool hasFilters,
    required int resultCount,
  }) {
    if ((query == null || query.trim().isEmpty) && !hasFilters) return;
    unawaited(_sendSearch(query, hasFilters, resultCount));
    unawaited(PostHogService.instance.capture('api_search', {
      if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
      'has_filters': hasFilters,
      'result_count': resultCount,
    }));
  }

  static void track(
    String event, {
    required String apiId,
    required String categoryId,
    required String healthState,
    required bool bookmarkState,
    required int projectCount,
    String sourceScreen = 'unknown',
  }) {
    if (event == 'api_detail_view' && sourceScreen == 'search') {
      _evaluatedSearchApis.add(apiId);
    }
    unawaited(_send(event, apiId, categoryId, healthState, bookmarkState,
        projectCount, sourceScreen));
    // Mirror into PostHog for funnels/replays; /track stays for warehouse.
    unawaited(PostHogService.instance.capture(event, {
      'api_id': apiId,
      'category_id': categoryId,
      'health_state': healthState,
      'bookmark_state': bookmarkState,
      'project_count': projectCount,
      'source_screen': sourceScreen,
    }));
    if ({'api_save', 'api_project_add', 'api_outbound_doc'}.contains(event) &&
        _evaluatedSearchApis.contains(apiId) &&
        _qualifiedSearchApis.add(apiId)) {
      unawaited(_send(
        'qualified_api_decision',
        apiId,
        categoryId,
        healthState,
        bookmarkState,
        projectCount,
        sourceScreen,
        decisionType: event,
      ));
    }
  }

  static Future<void> _send(
    String event,
    String apiId,
    String categoryId,
    String healthState,
    bool bookmarkState,
    int projectCount,
    String sourceScreen, {
    String? decisionType,
  }) async {
    try {
      await DioClient().unauthDio.post(
            '/track',
            data: {
              'eventType': event,
              'path': '/apis/$apiId',
              'element': event,
              'sessionId': _sessionId,
              'metadata': {
                'schemaVersion': 1,
                'source': 'mobile',
                'apiId': apiId,
                'categoryId': categoryId,
                'sourceScreen': sourceScreen,
                'projectCount': projectCount,
                'bookmarkState': bookmarkState,
                'healthState': healthState,
                'dataFreshness': 'client_cache_first',
                if (decisionType != null) 'decisionType': decisionType,
              },
            },
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
    } catch (_) {}
  }

  static Future<void> _sendSearch(
      String? query, bool hasFilters, int resultCount) async {
    try {
      await DioClient().unauthDio.post(
            '/track',
            data: {
              'eventType': 'api_search',
              'path': '/search',
              'element': 'search-results',
              'sessionId': _sessionId,
              'metadata': {
                'schemaVersion': 1,
                'source': 'mobile',
                if (query != null && query.trim().isNotEmpty)
                  'query': query.trim(),
                'hasFilters': hasFilters,
                'resultCount': resultCount,
              },
            },
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
    } catch (_) {}
  }
}
