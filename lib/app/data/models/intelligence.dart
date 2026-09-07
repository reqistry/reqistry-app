/// Models for the Intelligence tab: API comparison and registry change feed.
///
/// Trust payloads come from the backend growth routes (`/v1/apis/compare`,
/// `/v1/trust-scores/:id`, `/v1/use-case-collections`, `/v1/stack`).
/// Every field stays nullable/defensive: the server omits factors for
/// legacy rows and returns live-computed scores without `computedAt`.
///
/// Orders: trust factors render in this fixed order (backend weight order),
/// unknown keys append alphabetically after the known ones.
class TrustFactor {
  final String key;
  final int score;
  final int weight;
  final String label;

  const TrustFactor({
    required this.key,
    required this.score,
    required this.weight,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'weight': weight,
        'label': label,
      };

  static const List<String> displayOrder = [
    'uptime',
    'responseTime',
    'docsQuality',
    'authClarity',
    'cors',
    'pricingClarity',
    'freshness',
    'openApi',
  ];

  /// Parses the backend `factors` record into display order.
  /// Unknown factor keys are kept and appended alphabetically so new
  /// backend dimensions surface without an app update.
  static Map<String, TrustFactor> parseFactors(Object? raw) {
    if (raw is! Map) return const {};
    final parsed = <String, TrustFactor>{};
    raw.forEach((key, value) {
      final k = key.toString();
      if (value is! Map) return;
      final score = value['score'];
      parsed[k] = TrustFactor(
        key: k,
        score: score is num ? score.round().clamp(0, 100) : 0,
        weight: value['weight'] is num ? (value['weight'] as num).round() : 0,
        label: value['label']?.toString() ?? k,
      );
    });
    final ordered = <String, TrustFactor>{};
    for (final k in displayOrder) {
      if (parsed.containsKey(k)) ordered[k] = parsed[k]!;
    }
    final rest = parsed.keys
        .where((k) => !ordered.containsKey(k))
        .toList()
      ..sort();
    for (final k in rest) {
      ordered[k] = parsed[k]!;
    }
    return ordered;
  }
}

class CompareApi {
  final String id;
  final String slug;
  final String name;
  final String category;
  final int? trustScore;
  final String? trustGrade;
  final String? trustSummary;
  final Map<String, TrustFactor> trustFactors;
  final DateTime? trustComputedAt;
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
    this.trustFactors = const {},
    this.trustComputedAt,
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
      trustFactors:
          trust is Map ? TrustFactor.parseFactors(trust['factors']) : const {},
      trustComputedAt: trust is Map
          ? DateTime.tryParse(trust['computedAt']?.toString() ?? '')
          : null,
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

  /// Full-fidelity payload for Pro evidence-pack exports.
  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'category': category,
        'trustScore': trustScore,
        'trustGrade': trustGrade,
        'trustSummary': trustSummary,
        'trustFactors':
            trustFactors.map((key, factor) => MapEntry(key, factor.toJson())),
        'trustComputedAt': trustComputedAt?.toIso8601String(),
        'authType': authType,
        'pricingType': pricingType,
        'rateLimit': rateLimit,
        'sdkLanguages': sdkLanguages,
        'responseTimeMs': responseTimeMs,
        'uptime30d': uptime30d,
        'cors': cors,
        'https': https,
        'openApiAvailable': openApiAvailable,
        'documentationUrl': documentationUrl,
      };
}

class ChangeFeedEvent {
  final String id;
  final String eventType;
  final String title;
  final DateTime createdAt;
  final Map<String, dynamic> details;
  final String? apiName;
  final String? apiSlug;

  const ChangeFeedEvent({
    required this.id,
    required this.eventType,
    required this.title,
    required this.createdAt,
    this.details = const {},
    this.apiName,
    this.apiSlug,
  });

  /// Flat "key: value" summary of primitive detail entries, e.g.
  /// "score: 93 · grade: A". Nested values are skipped.
  String get detailsSummary => details.entries
      .where((e) =>
          e.value is String || e.value is num || e.value is bool)
      .map((e) => '${e.key}: ${e.value}')
      .join(' · ');

  factory ChangeFeedEvent.fromJson(Map<String, dynamic> json) {
    final api = json['api'];
    return ChangeFeedEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      details: json['details'] is Map
          ? Map<String, dynamic>.from(json['details'] as Map)
          : const {},
      apiName: api is Map ? api['name']?.toString() : null,
      apiSlug: api is Map ? api['slug']?.toString() : null,
    );
  }
}

/// Grade thresholds mirror the backend trust scorer
/// (`computeApiTrustScore` in `packages/contracts`).
String trustGradeFor(int score) {
  if (score >= 90) return 'A';
  if (score >= 75) return 'B';
  if (score >= 60) return 'C';
  if (score >= 45) return 'D';
  return 'F';
}

/// Curated task-fit collection from `GET /v1/use-case-collections`.
/// Each entry embeds full [CompareApi] rows so tapping a collection can
/// route straight into the existing compare view by id.
class UseCaseCollection {
  final String id;
  final String title;
  final String description;
  final List<CompareApi> apis;

  const UseCaseCollection({
    required this.id,
    required this.title,
    required this.description,
    this.apis = const [],
  });

  factory UseCaseCollection.fromJson(Map<String, dynamic> json) {
    return UseCaseCollection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString() ?? '',
      apis: (json['apis'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CompareApi.fromJson)
          .toList(),
    );
  }

  /// Mean of scored rows. Null when nothing in the collection is scored.
  int? get averageTrust {
    final scores = [
      for (final api in apis)
        if (api.trustScore != null) api.trustScore!,
    ];
    if (scores.isEmpty) return null;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  String? get averageGrade {
    final avg = averageTrust;
    return avg == null ? null : trustGradeFor(avg);
  }
}

/// Server-side rollup of the user's saved stack from `GET /v1/stack`.
/// Supplements (never replaces) the local counts: the backend sees health
/// transitions the device may have missed while offline.
class StackSummary {
  final int apiCount;
  final int projectCount;
  final int downCount;
  final int? averageTrustScore;

  const StackSummary({
    this.apiCount = 0,
    this.projectCount = 0,
    this.downCount = 0,
    this.averageTrustScore,
  });

  factory StackSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'];
    final map = summary is Map<String, dynamic>
        ? summary
        : Map<String, dynamic>.from(json);
    int asInt(Object? v) => v is num ? v.round() : 0;
    return StackSummary(
      apiCount: asInt(map['apiCount']),
      projectCount: asInt(map['projectCount']),
      downCount: asInt(map['downCount']),
      averageTrustScore: map['averageTrustScore'] is num
          ? (map['averageTrustScore'] as num).round()
          : null,
    );
  }
}

/// Cheapest pricing tier wins. Unknown ranks last.
int pricingRank(String pricing) {
  final v = pricing.trim().toLowerCase();
  if (v == 'free') return 0;
  if (v == 'freemium') return 1;
  if (v == 'paid' || v == 'enterprise') return 2;
  return 3;
}

/// Index of the unique extreme in [scores], or -1 on ties/empties.
/// Ties show no BEST badge: an indecisive badge is worse than none.
int uniqueBestIndex(List<int> scores, {bool lowerIsBetter = false}) {
  if (scores.isEmpty) return -1;
  var best = 0;
  for (var i = 1; i < scores.length; i++) {
    final better = lowerIsBetter
        ? scores[i] < scores[best]
        : scores[i] > scores[best];
    if (better) best = i;
  }
  final bestValue = scores[best];
  var matches = 0;
  for (final s in scores) {
    if (s == bestValue) matches++;
  }
  return matches == 1 ? best : -1;
}

/// Rule-based verdict over a comparison: highest trust wins, speed and
/// uptime add context. Mirrors the product doc's structured decision
/// (recommended + why), computed fully on-device from compare payloads.
class CompareVerdict {
  final CompareApi topPick;
  final CompareApi? fastest;
  final CompareApi? bestUptime;

  const CompareVerdict({
    required this.topPick,
    this.fastest,
    this.bestUptime,
  });
}

CompareVerdict? buildCompareVerdict(List<CompareApi> apis) {
  if (apis.isEmpty) return null;
  CompareApi top = apis.first;
  for (final api in apis.skip(1)) {
    if ((api.trustScore ?? -1) > (top.trustScore ?? -1)) top = api;
  }
  CompareApi? fastest;
  for (final api in apis) {
    final ms = api.responseTimeMs;
    if (ms == null) continue;
    if (fastest == null || ms < fastest.responseTimeMs!) fastest = api;
  }
  CompareApi? uptime;
  for (final api in apis) {
    final u = api.uptime30d;
    if (u == null) continue;
    if (uptime == null || u > (uptime.uptime30d ?? -1)) uptime = api;
  }
  return CompareVerdict(topPick: top, fastest: fastest, bestUptime: uptime);
}
