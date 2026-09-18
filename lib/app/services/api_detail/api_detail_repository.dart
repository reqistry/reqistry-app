import 'dart:async';

import 'package:api_scout/app/data/models/category_apis.dart' show ApiItem;
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/services/api_detail/api_detail_source.dart';
import 'package:api_scout/app/services/local_db/hive/initializer.dart';
import 'package:hive/hive.dart';

abstract class ApiDetailRepository {
  ApiDetail? readCached(String slug);

  Future<ApiDetail> load({
    required String slug,
    ApiItem? seed,
    bool forceRefresh = false,
  });

  Future<ApiDetail> loadAlternatives(ApiDetail detail);

  Future<ApiHealthSummary> refreshHealth(ApiDetail detail);

  Future<void> submitReport({
    required String apiId,
    required String slug,
    required String reason,
    String? note,
  });
}

class CachedApiDetailRepository implements ApiDetailRepository {
  CachedApiDetailRepository({ApiDetailSource? source})
      : _source = source ?? ApiDetailSource();

  static final CachedApiDetailRepository instance = CachedApiDetailRepository();

  final ApiDetailSource _source;
  final Map<String, Future<ApiDetail>> _detailRequests = {};
  final Map<String, Future<ApiHealthSummary>> _healthRequests = {};
  final Map<String, DateTime> _healthRefreshRequestedAt = {};

  Box get _cache => Hive.box(LocalDatabase.apiDetailCache);

  @override
  ApiDetail? readCached(String slug) {
    final raw = _cache.get(slug);
    if (raw is! Map) return null;
    try {
      return ApiDetail.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ApiDetail> load({
    required String slug,
    ApiItem? seed,
    bool forceRefresh = false,
  }) {
    return _detailRequests.putIfAbsent(slug, () async {
      try {
        final cached = readCached(slug);
        if (!forceRefresh) {
          if (cached != null && cached.isCoreFresh) {
            if (cached.isMetadataFresh) return cached;
          }
        }

        try {
          final detail = await _source.getApiDetail(slug);
          await _save(detail);
          return detail;
        } catch (_) {
          if (cached != null) return cached;
          rethrow;
        }
      } finally {
        _detailRequests.remove(slug);
      }
    });
  }

  @override
  Future<ApiDetail> loadAlternatives(ApiDetail detail) async {
    if (detail.areAlternativesFresh) return detail;
    final alternatives = await _source.getAlternatives(detail.id);
    final current = readCached(detail.slug) ?? detail;
    final updated = current.copyWith(
      alternatives: alternatives,
      alternativesUpdatedAt: DateTime.now(),
    );
    await _save(updated);
    return updated;
  }

  @override
  Future<ApiHealthSummary> refreshHealth(ApiDetail detail) {
    final lastRequest = _healthRefreshRequestedAt[detail.slug];
    if (lastRequest != null &&
        DateTime.now().difference(lastRequest) < const Duration(seconds: 30)) {
      return Future.value(detail.health);
    }
    return _healthRequests.putIfAbsent(detail.slug, () async {
      try {
        final health = await _source.refreshHealth(detail);
        final current = readCached(detail.slug) ?? detail;
        await _save(current.copyWith(health: health));
        _healthRefreshRequestedAt[detail.slug] = DateTime.now();
        return health;
      } finally {
        _healthRequests.remove(detail.slug);
      }
    });
  }

  @override
  Future<void> submitReport({
    required String apiId,
    required String slug,
    required String reason,
    String? note,
  }) async {
    await _source.submitReport(apiId: apiId, reason: reason, note: note);
  }

  Future<void> _save(ApiDetail detail) =>
      _cache.put(detail.slug, detail.toJson());
}
