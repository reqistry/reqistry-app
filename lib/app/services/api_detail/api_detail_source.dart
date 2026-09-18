import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:dio/dio.dart';

class ApiDetailSource {
  final Dio _authDio = DioClient().dio;

  Future<ApiDetail> getApiDetail(String slug) async {
    final response = await _authDio.get('/v1/apis/$slug');
    final data = Map<String, dynamic>.from(response.data['data'] as Map);
    return ApiDetail.fromJson({
      ...data,
      'metadataUpdatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ApiAlternative>> getAlternatives(String apiId) async {
    final normalizedId = apiId.trim();
    if (normalizedId.isEmpty) return const [];
    final response = await _authDio.get(
      '/v1/apis/$normalizedId/alternatives',
      queryParameters: const {'limit': 3},
    );
    final items = response.data['data'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => ApiAlternative.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ApiHealthSummary> refreshHealth(ApiDetail detail) async {
    final apiId = detail.id.trim();
    if (apiId.isEmpty) return detail.health;
    final response = await _authDio.post(
      '/v1/apis/$apiId/health-check',
      options: Options(extra: const {
        'silentLoader': true,
        RequestErrorNotifierInterceptor.silentKey: true,
      }),
    );
    final health = await _readHealthResponse(
      detail,
      Map<String, dynamic>.from(response.data),
    );
    if (health == null) return detail.health;
    return health;
  }

  Future<void> submitReport({
    required String apiId,
    required String reason,
    String? note,
  }) async {
    final normalizedId = apiId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(apiId, 'apiId', 'API ID cannot be empty');
    }
    await _authDio.post(
      '/v1/apis/$normalizedId/reports',
      data: {
        'reason': reason,
        if (note?.trim().isNotEmpty == true) 'note': note!.trim(),
      },
      options: Options(extra: const {
        'silentLoader': true,
        RequestErrorNotifierInterceptor.silentKey: true,
      }),
    );
  }

  Future<ApiHealthSummary?> _readHealthResponse(
    ApiDetail detail,
    Map<String, dynamic> response,
  ) async {
    final data =
        Map<String, dynamic>.from(response['data'] as Map? ?? const {});
    final state = data['state']?.toString().toUpperCase();
    final currentHealth = data['health'];
    final previousHealth = data['previousHealth'];
    if (currentHealth is Map &&
        (state == null || state == 'CACHED' || state == 'COMPLETED')) {
      return ApiHealthSummary.fromJson(
        Map<String, dynamic>.from(currentHealth),
      );
    }

    final checkId = data['checkId']?.toString();
    if (checkId == null || checkId.isEmpty) {
      if (previousHealth is Map) {
        return ApiHealthSummary.fromJson(
          Map<String, dynamic>.from(previousHealth),
        );
      }
      return null;
    }

    for (var attempt = 0; attempt < 3; attempt++) {
      await Future<void>.delayed(
        Duration(milliseconds: (data['pollAfterMs'] as num?)?.round() ?? 1200),
      );
      if (detail.id.trim().isEmpty) break;
      final poll = await _authDio.get(
        '/v1/apis/${detail.id.trim()}/health-checks/$checkId',
        options: Options(extra: const {'silentLoader': true}),
      );
      final pollData =
          Map<String, dynamic>.from(poll.data['data'] as Map? ?? const {});
      final polledHealth = pollData['health'];
      if (polledHealth is Map) {
        return ApiHealthSummary.fromJson(
          Map<String, dynamic>.from(polledHealth),
        );
      }
    }
    if (previousHealth is Map) {
      return ApiHealthSummary.fromJson(
        Map<String, dynamic>.from(previousHealth),
      );
    }
    return null;
  }

}
