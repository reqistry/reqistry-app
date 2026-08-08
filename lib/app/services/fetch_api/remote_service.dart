import 'package:dio/dio.dart';
import 'package:api_scout/config/env.dart';
import '../../data/models/apis_data_response.dart';
import '../../data/models/categories_response.dart';
import '../../data/models/category_apis.dart';
import '../../data/models/api.dart' as api_model;
import '../../data/models/apis_search_response.dart';
import '../auth/dio_client.dart';
import 'failure.dart';

class RemoteService {
  static String get baseUrl => Env.apiUrl;

  static Dio get _dio => DioClient().unauthDio;
  static Dio get _authDio => DioClient().dio;

  static Future<CategoriesResponse> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.data == null) {
        throw Failure('Empty response', 'Server returned empty data');
      }
      return CategoriesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch categories');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process categories data');
    }
  }

  static Future<List<String>> getTrendyCategories() async {
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
      throw _handleDioError(e, 'Failed to fetch trendy categories');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process trendy categories');
    }
  }

  static Future<CategoryDetail> getCategory(String categoryId) async {
    if (categoryId.isEmpty) {
      throw Failure('Invalid input', 'Category ID cannot be empty');
    }
    try {
      final response = await _dio.get('/categories/$categoryId');
      if (response.data == null) {
        throw Failure('Empty response', 'Server returned empty data');
      }
      return CategoryDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch category');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process category data');
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
      if (apiType != null && apiType.isNotEmpty) {
        queryParams['apiType'] = apiType;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (cors != null) queryParams['cors'] = cors;
      if (https != null) queryParams['https'] = https.toString();
      if (alive != null) queryParams['alive'] = alive.toString();
      if (maxResponseTime != null) {
        queryParams['maxResponseTime'] = maxResponseTime;
      }

      final response = await _dio.get('/search', queryParameters: queryParams);
      if (response.data == null) {
        throw Failure('Empty response', 'Server returned empty data');
      }
      return SearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Search failed');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process search results');
    }
  }

  static Future<List<api_model.Api>> getRecommendations({
    int limit = 10,
  }) async {
    try {
      final response = await _authDio.get(
        '/v1/recommend',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data == null) return [];
      final List<dynamic> apisData = data is List ? data : data['data'] ?? [];

      return apisData
          .whereType<Map<String, dynamic>>()
          .map((item) => api_model.Api.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Recommendations failed');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process recommendations');
    }
  }

  static Future<List<ApiItem>> getRecommendedApiItems({
    int limit = 20,
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
      throw _handleDioError(e, 'Recommendations failed');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process recommendations');
    }
  }

  static Future<Map<String, dynamic>> submitApi({
    required String name,
    required String link,
  }) async {
    if (name.trim().isEmpty) {
      throw Failure('Invalid input', 'API name cannot be empty');
    }
    if (link.trim().isEmpty) {
      throw Failure('Invalid input', 'API link cannot be empty');
    }
    try {
      final response = await _dio.post(
        '/submit',
        data: {'name': name.trim(), 'link': link.trim()},
        options: Options(
          extra: const {RequestErrorNotifierInterceptor.silentKey: true},
        ),
      );
      if (response.data == null) {
        throw Failure('Empty response', 'Server returned empty data');
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e, 'API submission failed');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process submission response');
    }
  }

  static Future<APIsDataResponse> getData({String? apiUrl}) async {
    try {
      final response = await _dio.get(
        apiUrl ?? '/APIs.json',
        queryParameters: {},
      );

      if (response.data == null) {
        throw Failure('Empty response', 'Server returned empty data');
      }

      final apisDataResponse = response.data is Map<String, dynamic>
          ? APIsDataResponse.fromJson(response.data)
          : apisDataResponseFromJson(response.data as String);

      if (!apisDataResponse.validateData()) {
        throw Failure('Invalid Data', 'The API response data is invalid');
      }

      return apisDataResponse;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch APIs');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process APIs data');
    }
  }

  static Future<CategoryApis> getCategoryApis({
    required String categoryId,
    int page = 1,
    int limit = 100,
  }) async {
    if (categoryId.isEmpty) {
      throw Failure('Invalid input', 'Category ID cannot be empty');
    }
    try {
      final response = await _dio.get(
        '/categories/$categoryId/apis',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data == null) {
        throw Failure('Empty response', 'Server returned empty data');
      }
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ApiItem.fromJson)
          .toList();
      return CategoryApis(title: categoryId, apis: items);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch category APIs');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process category APIs');
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentlyAdded({
    int limit = 20,
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
      throw _handleDioError(e, 'Failed to fetch recently added');
    } on Failure {
      rethrow;
    } catch (e) {
      throw Failure('Parse error', 'Failed to process recently added data');
    }
  }

  static Future<List<ApiItem>> getRecentlyAddedApis({
    int limit = 20,
  }) async {
    final items = await getRecentlyAdded(limit: limit);
    return items
        .map(ApiItem.fromJson)
        .where((api) => api.link.isNotEmpty)
        .toList();
  }

  static Failure _handleDioError(DioException e, String defaultTitle) {
    if (e.response?.data is Map) {
      final error = e.response?.data['error'];
      if (error != null) {
        return Failure(defaultTitle, error);
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Failure('Connection timeout', 'Check your internet connection');
    }
    return Failure(defaultTitle, 'Something went wrong');
  }
}
