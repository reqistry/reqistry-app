import 'dart:convert';
import 'category.dart';

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
  List<Category> toCategories() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      String name = entry.value;
      return Category(
        id: index.toString(),
        name: name,
        description: null,
        imageUrl: null,
        icon: null,
        tags: null,
      );
    }).toList();
  }
}
