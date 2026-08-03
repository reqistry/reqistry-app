import 'category.dart';

class CategoriesResponse {
  final List<CategoryDetail> categories;

  CategoriesResponse({required this.categories});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final cats = json['categories'];
    if (cats is List) {
      return CategoriesResponse(
        categories: cats
            .whereType<Map<String, dynamic>>()
            .map((c) => CategoryDetail.fromJson(c))
            .toList(),
      );
    }
    return CategoriesResponse(categories: []);
  }

  List<Category> toCategories() {
    return categories
        .map((c) => Category(
              id: c.id,
              hasTrendyBorder: c.isTrending,
              name: c.name,
              description: c.description,
              imageUrl: c.imageUrl,
              icon: null,
              tags: c.tags,
              apiCount: c.apiCount,
            ))
        .toList();
  }
}

class CategoryDetail {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int apiCount;
  final List<String> tags;
  final bool isTrending;

  CategoryDetail({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl,
    this.apiCount = 0,
    this.tags = const [],
    this.isTrending = false,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      apiCount: json['apiCount'] ?? 0,
      tags: json['tags'] != null
          ? List<String>.from((json['tags'] as List).map((x) => x.toString()))
          : [],
      isTrending: json['isTrending'] ?? false,
    );
  }
}
