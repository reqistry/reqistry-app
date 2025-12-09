import 'dart:io';
import "package:http/http.dart" as http;
import 'package:public_apis_desktop_client/app/services/crashlytics/crashlytics.dart';
import '../../data/models/AllApis.dart';
import '../../data/models/categories_response.dart';
import '../../data/models/api.dart' as api_model;
import '../../utils/singelton/categories_apis.dart';
import 'failure.dart';
import 'dart:convert';

class RemoteService {
  static const _baseUrl = "https://publicapis.gwhyyy.com";
  static const _authToken = "secret123";
  static const _url =
      "https://raw.githubusercontent.com/anasfik/public-apis-json-api/main/result/apis.json";

  static String get url => _url;
  static String get baseUrl => _baseUrl;

  /// Get all categories from the server
  /// Returns the complete response object with all metadata from the server
  /// Server returns: {"success": true, "data": ["Category1", "Category2", ...], "count": N, "fileName": "...", "folder": "...", "exportedAt": "..."}
  static Future<CategoriesResponse> getCategories({String? token}) async {
    try {
      final uri = Uri.parse("$_baseUrl/APIs.json");
      final queryParams = <String, String>{
        'file': 'categories',
        'token': token ?? _authToken,
      };

      final response = await http.get(
        uri.replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return CategoriesResponse.fromJson(jsonData);
      } else {
        throw Failure(
          "Server Error",
          "Failed to fetch categories: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Failure(
        "no internet connection",
        "check your internet connection and try again",
      );
    } on HttpException {
      throw Failure(
        "no service found",
        "sorry, the service is not available at the moment",
      );
    } on FormatException {
      throw Failure(
        "Invalid Response Format",
        "we're working on this issue, please try again later",
      );
    } catch (e) {
      Crashlytics().crashlyticsInstance.recordError(e, StackTrace.current);
      throw Failure(
        "unknown error",
        "we're trying to fix this issue, please try again later",
      );
    }
  }

  /// Search APIs with various filters
  /// Supports filtering by: keyword, pricing, auth, cors, https, apiType, category, alive, maxResponseTime
  /// Also supports sorting and pagination
  static Future<Map<String, dynamic>> searchApis({
    String? query,
    String? pricing,
    String? auth,
    String? cors,
    String? https,
    String? apiType,
    String? category,
    String? alive,
    String? maxResponseTime,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/search");
      final queryParams = <String, String>{
        'token': token ?? _authToken,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (pricing != null && pricing.isNotEmpty)
        queryParams['pricing'] = pricing;
      if (auth != null && auth.isNotEmpty) queryParams['auth'] = auth;
      if (cors != null && cors.isNotEmpty) queryParams['cors'] = cors;
      if (https != null && https.isNotEmpty) queryParams['https'] = https;
      if (apiType != null && apiType.isNotEmpty)
        queryParams['apiType'] = apiType;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;
      if (alive != null && alive.isNotEmpty) queryParams['alive'] = alive;
      if (maxResponseTime != null && maxResponseTime.isNotEmpty)
        queryParams['maxResponseTime'] = maxResponseTime;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty)
        queryParams['sortOrder'] = sortOrder;

      final response =
          await http.get(uri.replace(queryParameters: queryParams));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData;
      } else {
        throw Failure(
          "Server Error",
          "Search failed: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Failure(
        "no internet connection",
        "check your internet connection and try again",
      );
    } on HttpException {
      throw Failure(
        "no service found",
        "sorry, the service is not available at the moment",
      );
    } on FormatException {
      throw Failure(
        "Invalid Response Format",
        "we're working on this issue, please try again later",
      );
    } catch (e) {
      Crashlytics().crashlyticsInstance.recordError(e, StackTrace.current);
      throw Failure(
        "unknown error",
        "we're trying to fix this issue, please try again later",
      );
    }
  }

  /// Get recommended APIs
  /// Types: best (with criteria: fastest, most-reliable, free, no-auth, cors-enabled, https-only)
  ///        similar (with apiName)
  ///        usecase (with useCase: weather, social, payment, maps, mail, sms, storage, search)
  static Future<List<api_model.Api>> getRecommendations({
    required String type,
    String? criteria,
    String? apiName,
    String? useCase,
    int limit = 10,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/recommend");
      final queryParams = <String, String>{
        'type': type,
        'limit': limit.toString(),
        'token': token ?? _authToken,
      };

      if (criteria != null && criteria.isNotEmpty)
        queryParams['criteria'] = criteria;
      if (apiName != null && apiName.isNotEmpty)
        queryParams['apiName'] = apiName;
      if (useCase != null && useCase.isNotEmpty)
        queryParams['useCase'] = useCase;

      final response =
          await http.get(uri.replace(queryParameters: queryParams));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> apisData =
            jsonData is List ? jsonData : jsonData['data'] ?? [];

        final apis = <api_model.Api>[];
        for (final item in apisData) {
          if (item is Map<String, dynamic>) {
            apis.add(api_model.Api.fromJson(item));
          }
        }
        return apis;
      } else {
        throw Failure(
          "Server Error",
          "Recommendations failed: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Failure(
        "no internet connection",
        "check your internet connection and try again",
      );
    } on HttpException {
      throw Failure(
        "no service found",
        "sorry, the service is not available at the moment",
      );
    } on FormatException {
      throw Failure(
        "Invalid Response Format",
        "we're working on this issue, please try again later",
      );
    } catch (e) {
      Crashlytics().crashlyticsInstance.recordError(e, StackTrace.current);
      throw Failure(
        "unknown error",
        "we're trying to fix this issue, please try again later",
      );
    }
  }

  /// Get submission statistics (no authentication required)
  static Future<Map<String, dynamic>> getSubmissionStats() async {
    try {
      final uri = Uri.parse("$_baseUrl/submit/stats");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Failure(
          "Server Error",
          "Failed to fetch submission stats: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Failure(
        "no internet connection",
        "check your internet connection and try again",
      );
    } on HttpException {
      throw Failure(
        "no service found",
        "sorry, the service is not available at the moment",
      );
    } catch (e) {
      Crashlytics().crashlyticsInstance.recordError(e, StackTrace.current);
      throw Failure(
        "unknown error",
        "we're trying to fix this issue, please try again later",
      );
    }
  }

  /// Submit a new API for review
  static Future<Map<String, dynamic>> submitApi({
    required String name,
    required String link,
    required String description,
    required String category,
    String? auth,
    bool? https,
    String? cors,
    String? pricing,
    String? documentation,
    String? rateLimit,
    String? submitterEmail,
    String? submitterName,
    String? notes,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/submit");

      final body = <String, dynamic>{
        'name': name,
        'link': link,
        'description': description,
        'category': category,
        'token': token ?? _authToken,
      };

      if (auth != null) body['auth'] = auth;
      if (https != null) body['https'] = https;
      if (cors != null) body['cors'] = cors;
      if (pricing != null) body['pricing'] = pricing;
      if (documentation != null) body['documentation'] = documentation;
      if (rateLimit != null) body['rateLimit'] = rateLimit;
      if (submitterEmail != null) body['submitterEmail'] = submitterEmail;
      if (submitterName != null) body['submitterName'] = submitterName;
      if (notes != null) body['notes'] = notes;

      final response = await http.post(
        uri.replace(queryParameters: {'token': token ?? _authToken}),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Failure(
          "Server Error",
          "API submission failed: ${response.statusCode}",
        );
      }
    } on SocketException {
      throw Failure(
        "no internet connection",
        "check your internet connection and try again",
      );
    } on HttpException {
      throw Failure(
        "no service found",
        "sorry, the service is not available at the moment",
      );
    } catch (e) {
      Crashlytics().crashlyticsInstance.recordError(e, StackTrace.current);
      throw Failure(
        "unknown error",
        "we're trying to fix this issue, please try again later",
      );
    }
  }

  /// Legacy method for backward compatibility
  static Future<List<CategoryApis>> getData({String? apiUrl}) async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final response = await http.get(Uri.parse(apiUrl ?? _url));
      final categoriesApis = categoriesApisFromJson(response.body);
      CategoriesApisSingleton.all = categoriesApis;

      return categoriesApis;
    } on SocketException {
      throw Failure(
        "no internet connection",
        "check your internet connection and try again",
      );
    } on HttpException {
      throw Failure(
        "no service found",
        "sorry, the service is not available at the moment",
      );
    } on FormatException {
      throw Failure(
        "Invalid Response Format",
        "we're working on this issue, please try again later",
      );
    } catch (e) {
      Crashlytics().crashlyticsInstance.recordError(e, StackTrace.current);
      throw Failure(
        "unknown error",
        "we're trying to fix this issue, please try again later",
      );
    }
  }
}
