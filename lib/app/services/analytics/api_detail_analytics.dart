import 'dart:async';

import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:dio/dio.dart';

class ApiDetailAnalytics {
  ApiDetailAnalytics._();

  static void track(
    String event, {
    required String apiId,
    required String categoryId,
    required String healthState,
    required bool bookmarkState,
    required int projectCount,
    String sourceScreen = 'unknown',
  }) {
    unawaited(_send(event, apiId, categoryId, healthState, bookmarkState,
        projectCount, sourceScreen));
  }

  static Future<void> _send(
    String event,
    String apiId,
    String categoryId,
    String healthState,
    bool bookmarkState,
    int projectCount,
    String sourceScreen,
  ) async {
    try {
      await DioClient().unauthDio.post(
            '/track',
            data: {
              'eventType': event,
              'path': '/apis/$apiId',
              'element': event,
              'metadata': {
                'api_id': apiId,
                'category_id': categoryId,
                'source_screen': sourceScreen,
                'search_query': null,
                'position_in_results': null,
                'authenticated_state': 'active_session',
                'project_count': projectCount,
                'bookmark_state': bookmarkState,
                'health_state': healthState,
                'data_freshness': 'client_cache_first',
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
