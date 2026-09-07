// Pro billing + power-feature models. All payloads defensive: server nulls
// are common and unknown enum strings must not throw.

class Entitlements {
  final bool isPro;
  final String tier;
  final DateTime? proExpiresAt;
  final bool trialUsed;
  final bool emailLinked;
  final int compareMax;
  final int watchlistsMax;
  final int agentKeysMax;
  final int stackHistoryDays;

  const Entitlements({
    required this.isPro,
    required this.tier,
    this.proExpiresAt,
    this.trialUsed = false,
    this.emailLinked = false,
    this.compareMax = 4,
    this.watchlistsMax = 0,
    this.agentKeysMax = 0,
    this.stackHistoryDays = 0,
  });

  factory Entitlements.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final limits =
        data['limits'] is Map<String, dynamic> ? data['limits'] as Map<String, dynamic> : const <String, dynamic>{};
    int limit(String key, int fallback) =>
        (limits[key] as num?)?.toInt() ?? fallback;
    DateTime? expires;
    if (data['proExpiresAt'] != null) {
      expires = DateTime.tryParse(data['proExpiresAt'].toString());
    }
    return Entitlements(
      isPro: data['isPro'] == true || data['tier']?.toString() == 'pro',
      tier: data['tier']?.toString() ?? 'free',
      proExpiresAt: expires,
      trialUsed: data['trialUsed'] == true,
      emailLinked: data['emailLinked'] == true,
      compareMax: limit('compareMax', 4),
      watchlistsMax: limit('watchlistsMax', 0),
      agentKeysMax: limit('agentKeysMax', 0),
      stackHistoryDays: limit('stackHistoryDays', 0),
    );
  }
}

class ShipCheckReport {
  final String apiId;
  final String slug;
  final String name;
  final String verdict;
  final int score;
  final String grade;
  final String? summary;
  final Map<String, dynamic> factors;
  final Map<String, String> checks;
  final DateTime? computedAt;

  const ShipCheckReport({
    required this.apiId,
    required this.slug,
    required this.name,
    required this.verdict,
    required this.score,
    required this.grade,
    this.summary,
    this.factors = const {},
    this.checks = const {},
    this.computedAt,
  });

  bool get ships => verdict == 'ship';
  bool get avoid => verdict == 'avoid';

  factory ShipCheckReport.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final factors = data['factors'];
    final checks = data['checks'];
    return ShipCheckReport(
      apiId: data['apiId']?.toString() ?? '',
      slug: data['slug']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Unknown',
      verdict: data['verdict']?.toString() ?? 'caution',
      score: (data['score'] as num?)?.toInt() ?? 0,
      grade: data['grade']?.toString() ?? '?',
      summary: data['summary']?.toString(),
      factors: factors is Map<String, dynamic>
          ? factors
          : (factors is Map ? Map<String, dynamic>.from(factors) : const {}),
      checks: checks is Map
          ? checks.map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
      computedAt: data['computedAt'] != null
          ? DateTime.tryParse(data['computedAt'].toString())
          : null,
    );
  }
}

class WatchItem {
  final String id;
  final String kind;
  final String value;
  final DateTime? createdAt;

  const WatchItem({
    required this.id,
    required this.kind,
    required this.value,
    this.createdAt,
  });

  factory WatchItem.fromJson(Map<String, dynamic> json) {
    return WatchItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'keyword',
      value: json['value']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class AgentKeyItem {
  final String id;
  final String prefix;
  final String name;
  final int? dailyQuota;
  final int usedToday;
  final bool isActive;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;
  final String? key;

  const AgentKeyItem({
    required this.id,
    required this.prefix,
    required this.name,
    this.dailyQuota,
    this.usedToday = 0,
    this.isActive = true,
    this.lastUsedAt,
    this.createdAt,
    this.key,
  });

  factory AgentKeyItem.fromJson(Map<String, dynamic> json) {
    return AgentKeyItem(
      id: json['id']?.toString() ?? '',
      prefix: json['prefix']?.toString() ?? '',
      name: json['name']?.toString() ?? 'agent key',
      dailyQuota: (json['dailyQuota'] as num?)?.toInt(),
      usedToday: (json['usedToday'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.tryParse(json['lastUsedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      key: json['key']?.toString(),
    );
  }
}

class StackHistoryItem {
  final String id;
  final int downCount;
  final int? avgTrust;
  final int apiCount;
  final DateTime? createdAt;

  const StackHistoryItem({
    required this.id,
    required this.downCount,
    this.avgTrust,
    required this.apiCount,
    this.createdAt,
  });

  factory StackHistoryItem.fromJson(Map<String, dynamic> json) {
    return StackHistoryItem(
      id: json['id']?.toString() ?? '',
      downCount: (json['downCount'] as num?)?.toInt() ?? 0,
      avgTrust: (json['avgTrust'] as num?)?.toInt(),
      apiCount: (json['apiCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
