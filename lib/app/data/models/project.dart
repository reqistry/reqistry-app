import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String title;
  final int iconCodePoint;
  final List<String> apiLinks;
  final int apiCount;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.apiLinks = const [],
    this.apiCount = 0,
    this.sortOrder = 0,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      iconCodePoint: json['iconCodePoint'] ?? 0,
      apiLinks: json['apiLinks'] != null
          ? List<String>.from(
              (json['apiLinks'] as List).map((x) => x.toString()))
          : [],
      apiCount: json['apiCount'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Project copyWith({
    String? id,
    String? title,
    int? iconCodePoint,
    List<String>? apiLinks,
    int? apiCount,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      apiLinks: apiLinks ?? this.apiLinks,
      apiCount: apiCount ?? this.apiCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        iconCodePoint,
        apiLinks,
        apiCount,
        sortOrder,
        createdAt,
        updatedAt
      ];
}
