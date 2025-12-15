import 'dart:io';
import "package:http/http.dart" as http;
import 'package:public_apis_desktop_client/app/services/crashlytics/crashlytics.dart';
import '../../data/models/apis_data_response.dart';
import '../../data/models/categories_response.dart';
import '../../data/models/api.dart' as api_model;
import '../../data/models/apis_search_response.dart';
import '../../utils/singelton/categories_apis.dart';
import 'failure.dart';
import 'dart:convert';

class RemoteService {
  static const _baseUrl = "https://publicapis.gwhyyy.com";
  static const clientApiKey =
      "sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213";

  static String get baseUrl => _baseUrl;

  /// Get all categories from the server
  /// Returns the complete response object with all metadata from the server
  /// Server returns: {"success": true, "data": ["Category1", "Category2", ...], "count": N, "fileName": "...", "folder": "...", "exportedAt": "..."}
  static Future<CategoriesResponse> getCategories() async {
    try {
      final uri = Uri.parse("$_baseUrl/APIs.json");
      final queryParams = <String, String>{
        'file': 'categories',
        'key': clientApiKey,
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

  /// Get trendy categories list from remote source
  /// Returns a list of category names that should be marked as featured/trendy
  static Future<List<String>> getTrendyCategories() async {
    try {
      final uri = Uri.parse("$_baseUrl/trendy-categories");
      final queryParams = <String, String>{
        'key': clientApiKey,
      };

      final response = await http.get(
        uri.replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Handle both array and object responses
        // If response is an array directly
        if (jsonData is List) {
          return List<String>.from(jsonData.map((x) => x.toString()));
        }

        // If response is an object with a 'data' or 'categories' field
        if (jsonData is Map<String, dynamic>) {
          final data = jsonData['data'] ?? jsonData['categories'] ?? [];
          return List<String>.from((data as List).map((x) => x.toString()));
        }

        return [];
      } else {
        throw Failure(
          "Server Error",
          "Failed to fetch trendy categories: ${response.statusCode}",
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
  /// Uses repeatable query parameters and includes `token` in the query for easy debugging/copying.
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
      final uri = Uri.parse("$_baseUrl/search");

      // Build repeatable query params
      final Map<String, List<String>> qpAll = {
        'page': [page.toString()],
        'limit': [limit.toString()],
        'sortBy': [sortBy],
        'sortOrder': [sortOrder],
        'token': [clientApiKey],
      };

      if (q != null && q.isNotEmpty) qpAll['q'] = [q];
      if (pricing != null && pricing.isNotEmpty) qpAll['pricing'] = pricing;
      if (auth != null && auth.isNotEmpty) qpAll['auth'] = auth;
      if (apiType != null && apiType.isNotEmpty) qpAll['apiType'] = apiType;
      if (category != null && category.isNotEmpty) qpAll['category'] = category;
      if (cors != null && cors.isNotEmpty) qpAll['cors'] = [cors];
      if (https != null) qpAll['https'] = [https.toString()];
      if (alive != null) qpAll['alive'] = [alive.toString()];
      if (maxResponseTime != null) {
        qpAll['maxResponseTime'] = [maxResponseTime.toString()];
      }

      // Encode query string with repeatable parameters
      final queryString = qpAll.entries
          .expand((e) => e.value.map((v) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(v)}'))
          .join('&');

      final searchUri = Uri.parse('${uri.toString()}?$queryString');
      final response = await http.get(searchUri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return SearchResponse.fromJson(jsonData);
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
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/recommend");
      final queryParams = <String, String>{
        'type': type,
        'limit': limit.toString(),
        'key': clientApiKey,
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
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/submit");

      final body = <String, dynamic>{
        'name': name,
        'link': link,
        'description': description,
        'category': category,
        'key': clientApiKey,
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
        uri.replace(queryParameters: {'key': clientApiKey}),
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

  /// Get all APIs from _baseUrl/APIs.json
  /// Returns APIsDataResponse containing all APIs organized by category
  /// Response includes: success status, data (list of categories), count, fileName, folder, and exportedAt timestamp
  static Future<APIsDataResponse> getData({String? apiUrl}) async {
    try {
      final uri = Uri.parse(apiUrl ?? "$_baseUrl/APIs.json");
      final queryParams = <String, String>{
        'key': clientApiKey,
      };

      final response = await http.get(
        uri.replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final apisDataResponse = apisDataResponseFromJson(response.body);

        // Validate parsed data
        if (!apisDataResponse.validateData()) {
          throw Failure(
            "Invalid Data",
            "The API response data is invalid or empty",
          );
        }

        // Store the categories in singleton for global access
        CategoriesApisSingleton.all = apisDataResponse.data;

        return apisDataResponse;
      } else {
        throw Failure(
          "Server Error",
          "Failed to fetch APIs: ${response.statusCode}",
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
}
