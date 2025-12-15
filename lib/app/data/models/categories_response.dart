import 'dart:convert';
import 'category.dart';
import '../../services/fetch_api/remote_service.dart';

CategoriesResponse categoriesResponseFromJson(String str) =>
    CategoriesResponse.fromJson(json.decode(str));

String categoriesResponseToJson(CategoriesResponse data) =>
    json.encode(data.toJson());

class CategoriesResponse {
  final bool success;
  final int count;
  final List<String> data;
  final String fileName;
  final String folder;
  final String exportedAt;

  CategoriesResponse({
    required this.success,
    required this.count,
    required this.data,
    required this.fileName,
    required this.folder,
    required this.exportedAt,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) =>
      CategoriesResponse(
        success: json["success"] ?? false,
        count: json["count"] ?? 0,
        data: json["data"] != null
            ? List<String>.from((json["data"] as List).map((x) => x.toString()))
            : [],
        fileName: json["fileName"] ?? '',
        folder: json["folder"] ?? '',
        exportedAt: json["exportedAt"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "count": count,
        "data": List<dynamic>.from(data.map((x) => x)),
        "fileName": fileName,
        "folder": folder,
        "exportedAt": exportedAt,
      };

  /// Convert categories list to Category objects with metadata
  /// Fetches trendy categories from remote source
  Future<List<Category>> toCategories() async {
    try {
      // Fetch trendy categories from remote source
      final trendyCategories = await RemoteService.getTrendyCategories();
      final trendyLowercase =
          trendyCategories.map((c) => c.toLowerCase()).toList();

      return data.asMap().entries.map((entry) {
        int index = entry.key;
        String name = entry.value;
        return Category(
          id: index.toString(),
          hasTrendyBorder: trendyLowercase.contains(name.toLowerCase()),
          name: name,
          description: null,
          imageUrl: null,
          icon: null,
          tags: null,
        );
      }).toList();
    } catch (e) {
      // Fallback: no trendy categories if fetch fails
      return data.asMap().entries.map((entry) {
        int index = entry.key;
        String name = entry.value;
        return Category(
          id: index.toString(),
          hasTrendyBorder: false,
          name: name,
          description: null,
          imageUrl: null,
          icon: null,
          tags: null,
        );
      }).toList();
    }
  }
}
