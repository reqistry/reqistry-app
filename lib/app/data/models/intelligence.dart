/// Models for the Intelligence tab: API comparison and registry change feed.
class CompareApi {
  final String id;
  final String slug;
  final String name;
  final String category;
  final int? trustScore;
  final String? trustGrade;
  final String? trustSummary;
  final String authType;
  final String pricingType;
  final String rateLimit;
  final List<String> sdkLanguages;
  final int? responseTimeMs;
  final num? uptime30d;
  final String cors;
  final bool? https;
  final bool openApiAvailable;
  final String? documentationUrl;

  const CompareApi({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    this.trustScore,
    this.trustGrade,
    this.trustSummary,
    required this.authType,
    required this.pricingType,
    required this.rateLimit,
    required this.sdkLanguages,
    this.responseTimeMs,
    this.uptime30d,
    required this.cors,
    this.https,
    required this.openApiAvailable,
    this.documentationUrl,
  });

  factory CompareApi.fromJson(Map<String, dynamic> json) {
    final trust = json['trustScore'];
    return CompareApi(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Uncategorized',
      trustScore: trust is Map && trust['score'] is num
          ? (trust['score'] as num).round()
          : null,
      trustGrade:
          trust is Map ? trust['grade']?.toString() : null,
      trustSummary:
          trust is Map ? trust['summary']?.toString() : null,
      authType: json['authType']?.toString() ?? 'Unknown',
      pricingType: json['pricingType']?.toString() ?? 'Unknown',
      rateLimit: json['rateLimit']?.toString() ?? 'Unknown',
      sdkLanguages: (json['sdkLanguages'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      responseTimeMs: json['responseTimeMs'] is num
          ? (json['responseTimeMs'] as num).round()
          : null,
      uptime30d: json['uptime30d'] is num ? json['uptime30d'] as num : null,
      cors: json['cors']?.toString() ?? 'Unknown',
      https: json['https'] is bool ? json['https'] as bool : null,
      openApiAvailable: json['openApiAvailable'] == true,
      documentationUrl: json['documentationUrl']?.toString(),
    );
  }
}

class ChangeFeedEvent {
  final String id;
  final String eventType;
  final String title;
  final DateTime createdAt;
  final String? apiName;
  final String? apiSlug;

  const ChangeFeedEvent({
    required this.id,
    required this.eventType,
    required this.title,
    required this.createdAt,
    this.apiName,
    this.apiSlug,
  });

  factory ChangeFeedEvent.fromJson(Map<String, dynamic> json) {
    final api = json['api'];
    return ChangeFeedEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      apiName: api is Map ? api['name']?.toString() : null,
      apiSlug: api is Map ? api['slug']?.toString() : null,
    );
  }
}
