import 'project.dart';

class ProjectDetail {
  final String id;
  final String title;
  final int iconCodePoint;
  final int sortOrder;
  final List<String> apiLinks;
  final int apiCount;
  final List<ProjectItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectDetail({
    required this.id,
    required this.title,
    this.iconCodePoint = 0,
    this.sortOrder = 0,
    this.apiLinks = const [],
    this.apiCount = 0,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    return ProjectDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      iconCodePoint: json['iconCodePoint'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      apiLinks: json['apiLinks'] != null
          ? List<String>.from(
              (json['apiLinks'] as List).map((x) => x.toString()))
          : [],
      apiCount: json['apiCount'] ?? 0,
      items: json['items'] != null
          ? (json['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => ProjectItem.fromJson(i))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Project toProject() => Project(
        id: id,
        title: title,
        iconCodePoint: iconCodePoint,
        apiLinks: apiLinks,
        apiCount: apiCount,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class ProjectItem {
  final String link;
  final String? apiId;
  final int sortOrder;
  final DateTime addedAt;

  ProjectItem({
    required this.link,
    this.apiId,
    this.sortOrder = 0,
    required this.addedAt,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      link: json['link'] ?? '',
      apiId: json['apiId'],
      sortOrder: json['sortOrder'] ?? 0,
      addedAt: json['addedAt'] != null
          ? DateTime.tryParse(json['addedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ProjectMetadata {
  final String id;
  final String title;
  final int iconCodePoint;
  final int totalApis;
  final DateTime? lastAdded;
  final List<ProjectPreviewItem> preview;

  ProjectMetadata({
    required this.id,
    required this.title,
    this.iconCodePoint = 0,
    this.totalApis = 0,
    this.lastAdded,
    this.preview = const [],
  });

  factory ProjectMetadata.fromJson(Map<String, dynamic> json) {
    return ProjectMetadata(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      iconCodePoint: json['iconCodePoint'] ?? 0,
      totalApis: json['totalApis'] ?? 0,
      lastAdded: json['lastAdded'] != null
          ? DateTime.tryParse(json['lastAdded'])
          : null,
      preview: json['preview'] != null
          ? (json['preview'] as List)
              .whereType<Map<String, dynamic>>()
              .map((p) => ProjectPreviewItem.fromJson(p))
              .toList()
          : [],
    );
  }
}

class ProjectPreviewItem {
  final String? apiId;
  final String link;
  final String? name;
  final bool? isAlive;

  ProjectPreviewItem({
    this.apiId,
    required this.link,
    this.name,
    this.isAlive,
  });

  factory ProjectPreviewItem.fromJson(Map<String, dynamic> json) {
    return ProjectPreviewItem(
      apiId: json['apiId'],
      link: json['link'] ?? '',
      name: json['name'],
      isAlive: json['isAlive'],
    );
  }
}
