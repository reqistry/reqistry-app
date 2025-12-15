import 'dart:convert';

List<Category> categoriesFromJson(String str) => List<Category>.from(
      json.decode(str).map(
            (x) => Category.fromJson(x),
          ),
    );

String categoriesToJson(List<Category> data) => json.encode(
      List<dynamic>.from(
        data.map(
          (x) => x.toJson(),
        ),
      ),
    );

class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int apiCount;
  final String? icon;
  final List<String>? tags;
  final bool hasTrendyBorder;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.apiCount = 0,
    this.icon,
    this.tags,
    this.hasTrendyBorder = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"] ?? json["title"]?.toString() ?? "",
        name: json["name"] ?? json["title"] ?? "",
        description: json["description"],
        imageUrl: json["imageUrl"],
        apiCount: json["apiCount"] ?? (json["apis"] as List?)?.length ?? 0,
        icon: json["icon"],
        tags: json["tags"] != null ? List<String>.from(json["tags"]) : null,
        hasTrendyBorder: json["hasTrendyBorder"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        if (description != null) "description": description,
        if (imageUrl != null) "imageUrl": imageUrl,
        "apiCount": apiCount,
        if (icon != null) "icon": icon,
        if (tags != null) "tags": tags,
        "hasTrendyBorder": hasTrendyBorder,
      };
}
