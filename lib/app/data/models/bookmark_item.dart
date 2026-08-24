import 'package:equatable/equatable.dart';
import 'package:api_scout/app/data/models/category_apis.dart' show ApiItem;

class BookmarkItem extends Equatable {
  final String id;
  final BookmarkApi api;
  final DateTime createdAt;

  const BookmarkItem({
    required this.id,
    required this.api,
    required this.createdAt,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      id: json['id'] ?? '',
      api: BookmarkApi.fromJson(json['api'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, api, createdAt];
}

class BookmarkApi extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String link;
  final String? imageUrl;
  final String? documentationUrl;
  final bool httpsSupport;
  final String corsStatus;
  final String status;
  final String categoryName;
  final String authTypeName;
  final String apiTypeName;
  final String pricingTypeName;
  final HealthStatus? currentHealth;

  const BookmarkApi({
    required this.id,
    required this.name,
    this.slug = '',
    required this.description,
    required this.link,
    this.imageUrl,
    this.documentationUrl,
    this.httpsSupport = false,
    this.corsStatus = '',
    this.status = '',
    this.categoryName = '',
    this.authTypeName = '',
    this.apiTypeName = '',
    this.pricingTypeName = '',
    this.currentHealth,
  });

  factory BookmarkApi.fromJson(Map<String, dynamic> json) {
    String nestedName(String key, [String fallbackKey = '']) {
      final value = json[key];
      if (value is Map) return value['name']?.toString() ?? '';
      return value?.toString() ?? json[fallbackKey]?.toString() ?? '';
    }

    bool boolValue(dynamic value) {
      final text = value?.toString().toLowerCase();
      return value == true || text == 'true' || text == 'yes';
    }

    final health = json['currentHealth'];

    return BookmarkApi(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      imageUrl: json['imageUrl']?.toString(),
      documentationUrl: json['documentationUrl'],
      httpsSupport: boolValue(json['httpsSupport'] ?? json['https']),
      corsStatus: json['corsStatus']?.toString() ?? '',
      status: json['status'] ?? '',
      categoryName: nestedName('category', 'categoryName'),
      authTypeName: nestedName('authType', 'authTypeName'),
      apiTypeName: nestedName('apiType', 'apiTypeName'),
      pricingTypeName: nestedName('pricingType', 'pricingTypeName'),
      currentHealth: health is Map
          ? HealthStatus.fromJson(Map<String, dynamic>.from(health))
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, link, corsStatus];
}

class HealthStatus extends Equatable {
  final bool isAlive;
  final int? responseTimeMs;
  final int? statusCode;
  final double? uptime30d;

  const HealthStatus({
    this.isAlive = false,
    this.responseTimeMs,
    this.statusCode,
    this.uptime30d,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      isAlive: json['isAlive'] ?? false,
      responseTimeMs: json['responseTimeMs'],
      statusCode: json['statusCode'],
      uptime30d: (json['uptime30d'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [isAlive, responseTimeMs, statusCode];
}

extension BookmarkApiX on BookmarkApi {
  /// Convert a bookmarked API into the unified list model used by cards.
  ApiItem toApiItem() => ApiItem(
        id: id,
        slug: slug,
        name: name,
        description: description,
        auth: authTypeName.isEmpty ? 'None' : authTypeName,
        https: httpsSupport ? 'true' : 'false',
        cors: corsStatus.isEmpty ? 'Unknown' : corsStatus,
        link: link,
        imageUrl: imageUrl,
        category: categoryName,
        apiType: apiTypeName.isEmpty ? 'REST' : apiTypeName,
        pricing: pricingTypeName.isEmpty ? 'Unknown' : pricingTypeName,
        rateLimit: 'Unknown',
        documentation: documentationUrl ?? '',
        isAlive: currentHealth?.isAlive ?? false,
        responseTime: currentHealth?.responseTimeMs ?? 0,
        statusCode: currentHealth?.statusCode,
        lastChecked: '',
      );
}
