import 'package:dio/dio.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import '../../data/models/categories_response.dart';
import '../../data/models/category_apis.dart';
import '../../data/models/apis_search_response.dart';
import '../../data/models/bookmark_item.dart';
import '../../data/models/intelligence.dart';
import '../../data/models/pro.dart';
import '../../data/models/submission.dart';
import '../auth/dio_client.dart';
import '../analytics/api_detail_analytics.dart';
import 'failure.dart';

class RemoteService {
  static String get baseUrl => Env.apiUrl;

  static Dio get _dio => DioClient().unauthDio;
  static Dio get _authDio => DioClient().dio;

  static Future<CategoriesResponse> getCategories(
      {AppLocalizations? l10n}) async {
    try {
      final response = await _dio.get('/categories');
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      return CategoriesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch categories', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process categories data');
    }
  }

  static Future<List<String>> getTrendyCategories(
      {AppLocalizations? l10n}) async {
    try {
      final response = await _dio.get('/trendy-categories');
      final data = response.data;
      if (data == null) return [];
      if (data is List) {
        return List<String>.from(data.map((x) => x.toString()));
      }
      if (data is Map<String, dynamic>) {
        final list = data['data'] ?? [];
        return List<String>.from((list as List).map((x) => x.toString()));
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch trendy categories', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process trendy categories');
    }
  }

  static Future<CategoryDetail> getCategory(String categoryId,
      {AppLocalizations? l10n}) async {
    if (categoryId.isEmpty) {
      throw Failure(l10n?.errorInvalidInput ?? 'Invalid input',
          l10n?.errorCategoryIdEmpty ?? 'Category ID cannot be empty');
    }
    try {
      final response = await _dio.get('/categories/$categoryId');
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      return CategoryDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch category', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process category data');
    }
  }

  static Future<SearchResponse> searchApis({
    String? q,
    List<String>? pricing,
    List<String>? auth,
    List<String>? apiType,
    List<String>? category,
    String? cors,
    bool? https,
    bool? alive,
    int? maxResponseTime,
    String sortBy = 'name',
    String sortOrder = 'asc',
    int page = 1,
    int limit = 20,
    AppLocalizations? l10n,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (pricing != null && pricing.isNotEmpty) {
        queryParams['pricing'] = pricing;
      }
      if (auth != null && auth.isNotEmpty) queryParams['auth'] = auth;
      // NOTE: `apiType` and `maxResponseTime` are NOT backend query params
      // (SearchQuerySchema strips unknown keys). They are applied as
      // client-side post-filters in SearchBloc._onSearch. Kept in the
      // signature so callers keep passing user intent in one place.
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (cors != null) queryParams['cors'] = cors;
      if (https != null) queryParams['https'] = https.toString();
      if (alive != null) queryParams['alive'] = alive.toString();

      final response = await _dio.get('/search', queryParameters: queryParams);
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      final result = SearchResponse.fromJson(response.data);
      ApiDetailAnalytics.trackSearch(
        query: q,
        hasFilters: (pricing?.isNotEmpty ?? false) ||
            (auth?.isNotEmpty ?? false) ||
            (apiType?.isNotEmpty ?? false) ||
            (category?.isNotEmpty ?? false) ||
            cors != null ||
            https != null ||
            alive != null ||
            maxResponseTime != null,
        // count reflects the server page; apiType/maxResponseTime narrow
        // further on the client (see SearchBloc).
        resultCount: result.count,
      );
      return result;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Search failed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process search results');
    }
  }

  static Future<List<ApiItem>> getRecommendedApiItems({
    int limit = 20,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _authDio.get(
        '/v1/recommend',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data == null) return [];
      final List<dynamic> items = data is List ? data : data['data'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(ApiItem.fromJson)
          .where((api) => api.link.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Recommendations failed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process recommendations');
    }
  }

  /// Submits an API for review via `POST /v1/apis` (authenticated so the
  /// backend can attribute the submission to this device for lifecycle
  /// notifications and `GET /v1/submissions/mine`). The legacy public
  /// `POST /submit` accepts the same payload without attribution.
  /// Contract requires at least one of name/link (`LegacySubmitSchema`);
  /// forms collect both, but the service enforces the contract minimum.
  static Future<Map<String, dynamic>> submitApi({
    required String name,
    required String link,
    AppLocalizations? l10n,
  }) async {
    final trimmedName = name.trim();
    final trimmedLink = link.trim();
    if (trimmedName.isEmpty && trimmedLink.isEmpty) {
      throw Failure(l10n?.errorInvalidInput ?? 'Invalid input',
          l10n?.errorApiNameEmpty ?? 'API name cannot be empty');
    }
    if (trimmedLink.isNotEmpty) {
      final parsed = Uri.tryParse(trimmedLink);
      final valid = parsed != null &&
          parsed.hasScheme &&
          parsed.hasAuthority &&
          (parsed.scheme.toLowerCase() == 'https' ||
              parsed.scheme.toLowerCase() == 'http');
      if (!valid) {
        throw Failure(l10n?.errorInvalidInput ?? 'Invalid input',
            l10n?.formInvalidUrl ?? 'Enter a valid http(s) URL');
      }
    }
    try {
      final response = await _authDio.post(
        '/v1/apis',
        data: {
          if (trimmedName.isNotEmpty) 'name': trimmedName,
          if (trimmedLink.isNotEmpty) 'link': trimmedLink,
        },
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      if (response.data is! Map) {
        throw Failure(
            l10n?.errorParseError ?? 'Parse error',
            l10n?.errorFailedToProcessData ??
                'Failed to process submission response');
      }
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleDioError(e, 'API submission failed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process submission response');
    }
  }

  /// Personal submission history for the current device identity.
  ///
  /// `GET /v1/submissions/mine` returns newest-first pages of
  /// `{data: [...], pagination: {...}}`.
  static Future<List<SubmissionItem>> getMySubmissions({
    int page = 1,
    int limit = 20,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _authDio.get(
        '/v1/submissions/mine',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      final data = response.data;
      final List<dynamic> items =
          data is Map ? (data['data'] as List? ?? const []) : const [];
      return items
          .whereType<Map>()
          .map((item) =>
              SubmissionItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.submissionId.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch submissions', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process submissions');
    }
  }

  /// All bookmarks for the current device, paging through `GET
  /// /v1/bookmarks` (backend max 100/page) so large accounts never see a
  /// silently truncated Saved tab or export.
  static Future<List<BookmarkItem>> getAllBookmarks({
    int limit = 100,
    AppLocalizations? l10n,
  }) async {
    try {
      final all = <BookmarkItem>[];
      var page = 1;
      while (true) {
        final response = await _authDio.get(
          '/v1/bookmarks',
          queryParameters: {'page': page, 'limit': limit},
        );
        if (response.data == null) {
          throw Failure(
              l10n?.errorEmptyResponse ?? 'Empty response',
              l10n?.errorServerReturnedEmptyData ??
                  'Server returned empty data');
        }
        final data = response.data;
        final raw = data is Map ? data['bookmarks'] : null;
        final items = (raw as List? ?? const [])
            .whereType<Map>()
            .map((b) => BookmarkItem.fromJson(Map<String, dynamic>.from(b)))
            .toList();
        all.addAll(items);
        num? total;
        if (data is Map) {
          final pagination = data['pagination'];
          total =
              (pagination is Map ? pagination['total'] : data['total']) as num?;
        }
        if (items.length < limit) break;
        if (total != null && all.length >= total.toInt()) break;
        page++;
      }
      return all;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch bookmarks', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process bookmarks');
    }
  }

  static Future<CategoryApis> getCategoryApis({
    required String categoryId,
    int page = 1,
    int limit = 100,
    AppLocalizations? l10n,
  }) async {
    if (categoryId.isEmpty) {
      throw Failure(l10n?.errorInvalidInput ?? 'Invalid input',
          l10n?.errorCategoryIdEmpty ?? 'Category ID cannot be empty');
    }
    try {
      // Page through the category (backend max 100/page) so catalogs over
      // 100 APIs never truncate silently. The `page` argument sets the
      // first page; callers use the default to fetch the whole category.
      final all = <ApiItem>[];
      var current = page;
      while (true) {
        final response = await _dio.get(
          '/categories/$categoryId/apis',
          queryParameters: {'page': current, 'limit': limit},
        );
        if (response.data == null) {
          throw Failure(
              l10n?.errorEmptyResponse ?? 'Empty response',
              l10n?.errorServerReturnedEmptyData ??
                  'Server returned empty data');
        }
        final data = Map<String, dynamic>.from(response.data as Map);
        final items = (data['data'] as List? ?? [])
            .whereType<Map>()
            .map((e) => ApiItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        all.addAll(items);
        final total = (data['total'] as num?)?.toInt();
        if (items.length < limit) break;
        if (total != null && all.length >= total) break;
        current++;
      }
      return CategoryApis(title: categoryId, apis: all);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch category APIs', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process category APIs');
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentlyAdded({
    int limit = 20,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/recently-added',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data == null) return [];
      final List<dynamic> items = data is List ? data : data['data'] ?? [];
      return items.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch recently added', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process recently added data');
    }
  }

  static Future<List<ApiItem>> getRecentlyAddedApis({
    int limit = 20,
    AppLocalizations? l10n,
  }) async {
    final items = await getRecentlyAdded(limit: limit, l10n: l10n);
    return items
        .map(ApiItem.fromJson)
        .where((api) => api.link.isNotEmpty)
        .toList();
  }

  static Future<List<CompareApi>> compareApis({
    required List<String> ids,
    AppLocalizations? l10n,
  }) async {
    if (ids.length < 2) {
      throw Failure(l10n?.errorInvalidInput ?? 'Invalid input',
          l10n?.compareSelectAtLeastTwo ?? 'Select at least two APIs');
    }
    try {
      final response = await _authDio.get(
        '/v1/apis/compare',
        queryParameters: {'ids': ids.join(',')},
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      final data = response.data;
      final List<dynamic> items = data is List ? data : data['data'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(CompareApi.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Comparison failed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process comparison data');
    }
  }

  static Future<List<ChangeFeedEvent>> getChangeFeed({
    int limit = 40,
    DateTime? since,
    String? query,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/change-feed',
        queryParameters: {
          'limit': limit,
          if (since != null) 'since': since.toUtc().toIso8601String(),
          if (query?.trim().isNotEmpty == true) 'q': query!.trim(),
        },
      );
      if (response.data == null) return [];
      final data = response.data;
      final List<dynamic> items =
          data is List ? data : (data['data'] ?? data['events']) ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(ChangeFeedEvent.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch change feed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process change feed');
    }
  }

  static Future<List<UseCaseCollection>> getUseCaseCollections({
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _dio.get('/v1/use-case-collections');
      if (response.data == null) return [];
      final data = response.data;
      final List<dynamic> items = data is List ? data : data['data'] ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(UseCaseCollection.fromJson)
          .where((c) => c.id.isNotEmpty && c.apis.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch collections', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process collections data');
    }
  }

  static Future<StackSummary?> getStackSummary({
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _authDio.get('/v1/stack');
      if (response.data == null) return null;
      final data = response.data;
      if (data is! Map) return null;
      return StackSummary.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch stack summary', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  /// Current device entitlements (tier source of truth). Null on network
  /// failure so callers keep the local flag.
  static Future<Entitlements?> getEntitlements({AppLocalizations? l10n}) async {
    try {
      final response = await _authDio.get('/v1/billing/entitlements');
      if (response.data == null) return null;
      return Entitlements.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (_) {
      return null;
    }
  }

  /// Reports a Play purchase token for server-side verification. Returns
  /// fresh entitlements; throws [Failure] (402 email_required included).
  static Future<Entitlements> verifyPlayPurchase({
    required String purchaseToken,
    String? productId,
    String? orderId,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _authDio.post(
        '/v1/billing/verify',
        data: {
          'purchaseToken': purchaseToken,
          if (productId != null) 'productId': productId,
          if (orderId != null) 'orderId': orderId,
        },
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      return Entitlements.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e, 'Purchase verification failed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to verify purchase');
    }
  }

  /// Pro production-safety verdict for one API (id or slug — both are
  /// sent, the backend matches either).
  static Future<ShipCheckReport> shipCheck({
    required String apiRef,
    AppLocalizations? l10n,
  }) async {
    final ref = apiRef.trim();
    if (ref.isEmpty) {
      throw Failure(l10n?.errorInvalidInput ?? 'Invalid input',
          l10n?.errorApiNameEmpty ?? 'API name cannot be empty');
    }
    try {
      final response = await _authDio.post(
        '/v1/ship-check',
        data: {'apiId': ref, 'slug': ref},
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      return ShipCheckReport.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e, 'Ship-check failed', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to load ship-check');
    }
  }

  static Future<List<WatchItem>> getWatchlists({AppLocalizations? l10n}) async {
    try {
      final response = await _authDio.get('/v1/watchlists');
      if (response.data == null) return [];
      final data = response.data;
      final items = data is Map ? (data['data'] as List? ?? const []) : const [];
      return items
          .whereType<Map>()
          .map((e) => WatchItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch watchlists', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process watchlists');
    }
  }

  static Future<WatchItem> addWatch({
    required String kind,
    required String value,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _authDio.post(
        '/v1/watchlists',
        data: {'kind': kind, 'value': value.trim()},
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      final data = Map<String, dynamic>.from(response.data as Map);
      final item = data['data'];
      if (item is! Map) {
        throw Failure(l10n?.errorParseError ?? 'Parse error',
            l10n?.errorFailedToProcessData ?? 'Failed to process watchlist');
      }
      return WatchItem.fromJson(Map<String, dynamic>.from(item));
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to add watch', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process watchlist');
    }
  }

  static Future<void> removeWatch(String id) async {
    await _authDio.delete(
      '/v1/watchlists/$id',
      options: Options(
        extra: const {RequestErrorNotifierInterceptor.silentKey: true},
      ),
    );
  }

  static Future<List<AgentKeyItem>> getAgentKeys({AppLocalizations? l10n}) async {
    try {
      final response = await _authDio.get('/v1/agent-keys');
      if (response.data == null) return [];
      final data = response.data;
      final items = data is Map ? (data['data'] as List? ?? const []) : const [];
      return items
          .whereType<Map>()
          .map((e) => AgentKeyItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch agent keys', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process agent keys');
    }
  }

  static Future<AgentKeyItem> createAgentKey({
    String? name,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _authDio.post(
        '/v1/agent-keys',
        data: {if (name?.trim().isNotEmpty == true) 'name': name!.trim()},
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      final data = Map<String, dynamic>.from(response.data as Map);
      final item = data['data'];
      if (item is! Map) {
        throw Failure(l10n?.errorParseError ?? 'Parse error',
            l10n?.errorFailedToProcessData ?? 'Failed to process agent key');
      }
      return AgentKeyItem.fromJson(Map<String, dynamic>.from(item));
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create agent key', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process agent key');
    }
  }

  static Future<void> revokeAgentKey(String id) async {
    await _authDio.delete(
      '/v1/agent-keys/$id',
      options: Options(
        extra: const {RequestErrorNotifierInterceptor.silentKey: true},
      ),
    );
  }

  static Future<List<StackHistoryItem>> getStackHistory({AppLocalizations? l10n}) async {
    try {
      final response = await _authDio.get('/v1/stack/history');
      if (response.data == null) return [];
      final data = response.data;
      final items = data is Map ? (data['data'] as List? ?? const []) : const [];
      return items
          .whereType<Map>()
          .map((e) => StackHistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch stack history', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ?? 'Failed to process stack history');
    }
  }

  /// Sends a contact message to `POST /admin/v1/contact-messages` (public).
  /// Returns the server confirmation message. Throws [Failure] with the
  /// server's validation error text when the backend rejects the payload.
  static Future<String> sendContactMessage({
    required String name,
    required String email,
    required String message,
    String? subject,
    AppLocalizations? l10n,
  }) async {
    try {
      final response = await _dio.post(
        '/admin/v1/contact-messages',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'subject': (subject ?? '').trim(),
          'message': message.trim(),
        },
      );
      if (response.data == null) {
        throw Failure(l10n?.errorEmptyResponse ?? 'Empty response',
            l10n?.errorServerReturnedEmptyData ?? 'Server returned empty data');
      }
      final data = response.data;
      final confirmation = data is Map ? data['message']?.toString() : null;
      return confirmation == null || confirmation.isEmpty
          ? (l10n?.snackbarContactSentMessage ?? 'Your message has been sent.')
          : confirmation;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to send message', l10n);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure(
          l10n?.errorParseError ?? 'Parse error',
          l10n?.errorFailedToProcessData ??
              'Failed to process contact response');
    }
  }

  static Failure _handleDioError(
      DioException e, String defaultTitle, AppLocalizations? l10n) {
    if (e.response?.data is Map) {
      final error = e.response?.data['error'];
      if (error != null) {
        return Failure(defaultTitle, error);
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Failure(
          l10n?.errorConnectionTimeout ?? 'Connection timeout',
          l10n?.errorCheckInternetConnection ??
              'Check your internet connection');
    }
    return Failure(
        defaultTitle, l10n?.stateSomethingWentWrong ?? 'Something went wrong');
  }
}
