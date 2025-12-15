import 'dart:convert';
import 'category_apis.dart';

APIsDataResponse apisDataResponseFromJson(String str) =>
    APIsDataResponse.fromJson(json.decode(str));

String apisDataResponseToJson(APIsDataResponse data) =>
    json.encode(data.toJson());

class APIsDataResponse {
  bool success;
  List<CategoryApis> data;
  int count;
  String fileName;
  String folder;
  String exportedAt;

  APIsDataResponse({
    required this.success,
    required this.data,
    required this.count,
    required this.fileName,
    required this.folder,
    required this.exportedAt,
  });

  factory APIsDataResponse.fromJson(Map<String, dynamic> json) {
    List<CategoryApis> parsedData = [];

    try {
      final dataField = json["data"];

      if (dataField is List<dynamic>) {
        parsedData = List<CategoryApis>.from(
          dataField.map((x) {
            try {
              if (x is Map<String, dynamic>) {
                return CategoryApis.fromJson(x);
              }
            } catch (e) {
              // Skip invalid category entries and log
              print('Error parsing category: $e');
            }
            return null;
          }).whereType<CategoryApis>(),
        );
      }
    } catch (e) {
      print('Error parsing data field: $e');
    }

    return APIsDataResponse(
      success: json["success"] ?? false,
      data: parsedData,
      count: json["count"] ?? parsedData.length,
      fileName: json["fileName"] ?? "",
      folder: json["folder"] ?? "",
      exportedAt: json["exportedAt"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "count": count,
        "fileName": fileName,
        "folder": folder,
        "exportedAt": exportedAt,
      };

  /// Get total number of APIs across all categories
  int get totalApis {
    return data.fold(0, (sum, category) => sum + category.apis.length);
  }

  /// Get a category by title
  CategoryApis? getCategoryByTitle(String title) {
    try {
      return data.firstWhere(
        (category) => category.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all APIs from all categories as a flat list
  List<ApiItem> getAllApisAsList() {
    final List<ApiItem> allApis = [];
    for (final category in data) {
      allApis.addAll(category.apis);
    }
    return allApis;
  }

  /// Search for APIs by name across all categories
  List<ApiItem> searchApisByName(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllApisAsList()
        .where(
          (api) => api.name.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get APIs by category title
  List<ApiItem> getApisByCategory(String categoryTitle) {
    final category = getCategoryByTitle(categoryTitle);
    return category?.apis ?? [];
  }

  /// Export timestamp as DateTime
  DateTime? get exportedDateTime {
    try {
      return DateTime.parse(exportedAt);
    } catch (e) {
      return null;
    }
  }

  /// Check if the data is fresh (exported within last 24 hours)
  bool get isFresh {
    final exported = exportedDateTime;
    if (exported == null) return false;
    final now = DateTime.now();
    return now.difference(exported).inHours < 24;
  }

  /// Get data parsing summary for debugging
  Map<String, dynamic> getDataSummary() {
    return {
      'totalCategories': data.length,
      'totalApis': totalApis,
      'categoryNames': data.map((c) => c.title).toList(),
      'apisPerCategory': {
        for (final category in data) category.title: category.apis.length
      },
    };
  }

  /// Validate data integrity
  bool validateData() {
    if (!success) return false;
    if (data.isEmpty) return false;

    // Check if at least one category has APIs
    return data.any((category) => category.apis.isNotEmpty);
  }

  /// Get categories with most APIs
  List<CategoryApis> getTopCategories({int limit = 10}) {
    final sorted = List<CategoryApis>.from(data);
    sorted.sort((a, b) => b.apis.length.compareTo(a.apis.length));
    return sorted.take(limit).toList();
  }

  /// Get alive APIs count (APIs that are currently working)
  int get aliveApisCount {
    return getAllApisAsList().where((api) => api.isAlive == true).length;
  }

  /// Get dead APIs count (APIs that are not working)
  int get deadApisCount {
    return getAllApisAsList().where((api) => api.isAlive == false).length;
  }

  /// Get availability percentage
  double get availabilityPercentage {
    final total = totalApis;
    if (total == 0) return 0.0;
    return (aliveApisCount / total) * 100;
  }

  /// Filter APIs by various criteria
  List<ApiItem> filterApis({
    String? categoryTitle,
    bool? requireHttps,
    bool? requireCors,
    String? authType,
    bool? requireAuth,
    bool? onlyAlive,
  }) {
    var filtered = <ApiItem>[];

    if (categoryTitle != null) {
      filtered = getApisByCategory(categoryTitle);
    } else {
      filtered = getAllApisAsList();
    }

    if (requireHttps == true) {
      filtered = filtered.where((api) => api.supportsHttps).toList();
    }

    if (requireCors == true) {
      filtered = filtered.where((api) => api.supportsCors).toList();
    }

    if (authType != null) {
      filtered = filtered
          .where((api) => api.auth.toLowerCase() == authType.toLowerCase())
          .toList();
    }

    if (requireAuth == true) {
      filtered = filtered.where((api) => api.requiresAuth).toList();
    }

    if (onlyAlive == true) {
      filtered = filtered.where((api) => api.isAlive == true).toList();
    }

    return filtered;
  }
}
