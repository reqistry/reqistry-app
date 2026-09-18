import 'package:equatable/equatable.dart';
import 'category_apis.dart' show ApiItem;
import 'intelligence.dart' show TrustFactor;
import 'package:api_scout/l10n/app_localizations.dart';


enum ApiAuthType { none, apiKey, oauth2, basic, unknown }

enum ApiPricingType { free, freemium, paid, unknown }

enum CorsSupport { supported, unsupported, unknown }

enum ApiProtocol { rest, graphql, soap, websocket, unknown }

enum ApiHealthStatus {
  operational,
  authenticationRequired,
  rateLimited,
  degraded,
  unavailable,
  unknown,
}

class ApiCategory extends Equatable {
  final String id;
  final String name;
  final String slug;

  const ApiCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  factory ApiCategory.fromJson(Map<String, dynamic> json) => ApiCategory(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown',
        slug: json['slug']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [id, name, slug];
}

class ApiAccess extends Equatable {
  final ApiAuthType authType;
  final String authLabel;
  final ApiPricingType pricingType;
  final String pricingLabel;
  final String? rateLimit;
  final bool? creditCardRequired;
  final bool? commercialUseAllowed;

  const ApiAccess({
    required this.authType,
    required this.authLabel,
    required this.pricingType,
    required this.pricingLabel,
    this.rateLimit,
    this.creditCardRequired,
    this.commercialUseAllowed,
  });

  Map<String, dynamic> toJson() => {
        'authType': authType.name,
        'authLabel': authLabel,
        'pricingType': pricingType.name,
        'pricingLabel': pricingLabel,
        'rateLimit': rateLimit,
        'creditCardRequired': creditCardRequired,
        'commercialUseAllowed': commercialUseAllowed,
      };

  factory ApiAccess.fromJson(Map<String, dynamic> json) {
    final authType = parseAuthType(json['authType']?.toString());
    final pricingType = parsePricingType(json['pricingType']?.toString());
    return ApiAccess(
      authType: authType,
      authLabel: json['authLabel']?.toString() ?? authTypeLabel(authType, ''),
      pricingType: pricingType,
      pricingLabel:
          json['pricingLabel']?.toString() ?? pricingTypeLabel(pricingType, ''),
      rateLimit: json['rateLimit']?.toString(),
      creditCardRequired: json['creditCardRequired'] as bool?,
      commercialUseAllowed: json['commercialUseAllowed'] as bool?,
    );
  }

  @override
  List<Object?> get props => [
        authType,
        authLabel,
        pricingType,
        pricingLabel,
        rateLimit,
        creditCardRequired,
        commercialUseAllowed,
      ];
}

class ApiLinks extends Equatable {
  final Uri? baseUrl;
  final Uri? homepageUrl;
  final Uri? documentationUrl;
  final Uri? openApiUrl;
  final Uri? statusPageUrl;
  final Uri? termsUrl;

  const ApiLinks({
    this.baseUrl,
    this.homepageUrl,
    this.documentationUrl,
    this.openApiUrl,
    this.statusPageUrl,
    this.termsUrl,
  });

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl?.toString(),
        'homepageUrl': homepageUrl?.toString(),
        'documentationUrl': documentationUrl?.toString(),
        'openApiUrl': openApiUrl?.toString(),
        'statusPageUrl': statusPageUrl?.toString(),
        'termsUrl': termsUrl?.toString(),
      };

  factory ApiLinks.fromJson(Map<String, dynamic> json) => ApiLinks(
        baseUrl: _uri(json['baseUrl']),
        homepageUrl: _uri(json['homepageUrl']),
        documentationUrl: _uri(json['documentationUrl']),
        openApiUrl: _uri(json['openApiUrl']),
        statusPageUrl: _uri(json['statusPageUrl']),
        termsUrl: _uri(json['termsUrl']),
      );

  @override
  List<Object?> get props => [
        baseUrl?.toString(),
        homepageUrl?.toString(),
        documentationUrl?.toString(),
        openApiUrl?.toString(),
        statusPageUrl?.toString(),
        termsUrl?.toString(),
      ];
}

class ApiCapabilities extends Equatable {
  final bool? https;
  final CorsSupport cors;
  final ApiProtocol protocol;
  final List<String> responseFormats;
  final List<String> sdkLanguages;
  final bool? openApiAvailable;

  const ApiCapabilities({
    this.https,
    required this.cors,
    required this.protocol,
    this.responseFormats = const [],
    this.sdkLanguages = const [],
    this.openApiAvailable,
  });


  static CorsSupport _corsFromJson(String? raw) {
    if (raw == null || raw.isEmpty) return CorsSupport.unknown;
    for (final value in CorsSupport.values) {
      if (value.name == raw) return value;
    }
    return parseCorsSupport(raw);
  }

  Map<String, dynamic> toJson() => {
        'https': https,
        'cors': cors.name,
        'protocol': protocol.name,
        'responseFormats': responseFormats,
        'sdkLanguages': sdkLanguages,
        'openApiAvailable': openApiAvailable,
      };

  factory ApiCapabilities.fromJson(Map<String, dynamic> json) =>
      ApiCapabilities(
        https: json['https'] as bool?,
        cors: _corsFromJson(json['cors']?.toString()),
        protocol: parseProtocol(json['protocol']?.toString()),
        responseFormats: List<String>.from(json['responseFormats'] ?? const []),
        sdkLanguages: List<String>.from(json['sdkLanguages'] ?? const []),
        openApiAvailable: json['openApiAvailable'] as bool?,
      );

  @override
  List<Object?> get props => [
        https,
        cors,
        protocol,
        responseFormats,
        sdkLanguages,
        openApiAvailable,
      ];
}

class ApiHealthSummary extends Equatable {
  final ApiHealthStatus status;
  final int? statusCode;
  final int? responseTimeMs;
  final String? message;
  final String method;
  final DateTime? checkedAt;
  final double? uptime30d;
  final int observationCount;

  const ApiHealthSummary({
    required this.status,
    this.statusCode,
    this.responseTimeMs,
    this.message,
    this.method = 'Unknown',
    this.checkedAt,
    this.uptime30d,
    this.observationCount = 0,
  });

  bool get isFresh =>
      checkedAt != null &&
      DateTime.now().difference(checkedAt!).abs() < const Duration(hours: 1);

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'statusCode': statusCode,
        'responseTimeMs': responseTimeMs,
        'message': message,
        'method': method,
        'checkedAt': checkedAt?.toIso8601String(),
        'uptime30d': uptime30d,
        'observationCount': observationCount,
      };

  factory ApiHealthSummary.fromJson(Map<String, dynamic> json) =>
      ApiHealthSummary(
        status: parseHealthStatus(json['status']?.toString()),
        statusCode: (json['statusCode'] as num?)?.round(),
        responseTimeMs: (json['responseTimeMs'] as num?)?.round(),
        message: json['message']?.toString(),
        method: json['checkMethod']?.toString() ??
            json['method']?.toString() ??
            'Unknown',
        checkedAt: DateTime.tryParse(json['checkedAt']?.toString() ?? ''),
        uptime30d: (json['uptime30d'] as num?)?.toDouble(),
        observationCount: (json['observationCount'] as num?)?.round() ?? 0,
      );

  @override
  List<Object?> get props => [
        status,
        statusCode,
        responseTimeMs,
        message,
        method,
        checkedAt,
        uptime30d,
        observationCount,
      ];
}

class FieldVerification extends Equatable {
  final String label;
  final String source;
  final DateTime? verifiedAt;

  const FieldVerification({
    required this.label,
    required this.source,
    this.verifiedAt,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'source': source,
        'verifiedAt': verifiedAt?.toIso8601String(),
      };

  factory FieldVerification.fromJson(Map<String, dynamic> json) =>
      FieldVerification(
        label: json['label']?.toString() ?? '',
        // Older cache entries stored the source key ('automated_check');
        // newer ones store the display label verbatim. Keep labels as-is.
        source: _verificationSourceFromJson(json['source']?.toString()),
        verifiedAt: DateTime.tryParse(json['verifiedAt']?.toString() ?? ''),
      );


  static String _verificationSourceFromJson(String? raw) {
    final value = raw ?? '';
    if (value.contains('_')) return verificationSourceLabel(value);
    return value;
  }

  @override
  List<Object?> get props => [label, source, verifiedAt];
}

class ApiWarning extends Equatable {
  final String code;
  final String message;
  final String severity;
  final DateTime? verifiedAt;

  const ApiWarning(
    this.message, {
    this.code = '',
    this.severity = 'WARNING',
    this.verifiedAt,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'severity': severity,
        'verifiedAt': verifiedAt?.toIso8601String(),
      };

  factory ApiWarning.fromJson(Map<String, dynamic> json) => ApiWarning(
        json['message']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        severity: json['severity']?.toString() ?? 'WARNING',
        verifiedAt: DateTime.tryParse(json['verifiedAt']?.toString() ?? ''),
      );

  @override
  List<Object?> get props => [message];
}

class ApiAlternative extends Equatable {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String pricing;
  final String authentication;
  final String link;
  final String? imageUrl;

  const ApiAlternative({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.pricing,
    required this.authentication,
    required this.link,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'description': description,
        'pricing': pricing,
        'authentication': authentication,
        'link': link,
        'imageUrl': imageUrl,
      };

  factory ApiAlternative.fromJson(Map<String, dynamic> json) => ApiAlternative(
        id: json['id']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['shortDescription']?.toString() ??
            json['description']?.toString() ??
            '',
        pricing: pricingTypeLabel(
          parsePricingType(json['pricingType']?.toString()),
          json['pricing']?.toString(),
        ),
        authentication: authTypeLabel(
          parseAuthType(json['authType']?.toString()),
          json['authentication']?.toString() ?? '',
        ),
        link: json['baseUrl']?.toString() ?? json['link']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString(),
      );

  @override
  List<Object?> get props => [id, slug, name, link];
}

/// Trust breakdown served inline on the API detail payload
/// (`trustScore: {score, grade, summary, factors, computedAt}`).
/// Absent on seed objects built from list rows (see [ApiDetail.fromApi]).
class ApiTrustScore extends Equatable {
  final int? score;
  final String? grade;
  final String? summary;
  final Map<String, TrustFactor> factors;
  final DateTime? computedAt;

  const ApiTrustScore({
    this.score,
    this.grade,
    this.summary,
    this.factors = const {},
    this.computedAt,
  });

  factory ApiTrustScore.fromJson(Map<String, dynamic> json) => ApiTrustScore(
        score: json['score'] is num ? (json['score'] as num).round() : null,
        grade: json['grade']?.toString(),
        summary: json['summary']?.toString(),
        factors: TrustFactor.parseFactors(json['factors']),
        computedAt: DateTime.tryParse(json['computedAt']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'grade': grade,
        'summary': summary,
        'computedAt': computedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [score, grade, summary, factors, computedAt];
}

class ApiDetail extends Equatable {
  final String id;
  final String slug;
  final String name;
  final String shortDescription;
  final String? fullDescription;
  final String? imageUrl;
  final ApiCategory category;
  final ApiAccess access;
  final ApiLinks links;
  final ApiCapabilities capabilities;
  final ApiHealthSummary health;
  final ApiTrustScore? trustScore;
  final List<FieldVerification> verification;
  final List<ApiWarning> warnings;
  final List<ApiAlternative> alternatives;
  final DateTime updatedAt;
  final DateTime? metadataUpdatedAt;
  final DateTime? alternativesUpdatedAt;

  const ApiDetail({
    required this.id,
    required this.slug,
    required this.name,
    required this.shortDescription,
    this.fullDescription,
    this.imageUrl,
    required this.category,
    required this.access,
    required this.links,
    required this.capabilities,
    required this.health,
    this.trustScore,
    this.verification = const [],
    this.warnings = const [],
    this.alternatives = const [],
    required this.updatedAt,
    this.metadataUpdatedAt,
    this.alternativesUpdatedAt,
  });

  bool get isCoreFresh =>
      DateTime.now().difference(updatedAt).abs() < const Duration(hours: 24);

  bool get isMetadataFresh =>
      metadataUpdatedAt != null &&
      DateTime.now().difference(metadataUpdatedAt!).abs() <
          const Duration(days: 7);

  bool get areAlternativesFresh =>
      alternativesUpdatedAt != null &&
      DateTime.now().difference(alternativesUpdatedAt!).abs() <
          const Duration(hours: 24);

  ApiDetail copyWith({
    String? fullDescription,
    String? imageUrl,
    ApiHealthSummary? health,
    ApiTrustScore? trustScore,
    List<FieldVerification>? verification,
    List<ApiWarning>? warnings,
    List<ApiAlternative>? alternatives,
    DateTime? updatedAt,
    DateTime? metadataUpdatedAt,
    DateTime? alternativesUpdatedAt,
  }) {
    return ApiDetail(
      id: id,
      slug: slug,
      name: name,
      shortDescription: shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category,
      access: access,
      links: links,
      capabilities: capabilities,
      health: health ?? this.health,
      trustScore: trustScore ?? this.trustScore,
      verification: verification ?? this.verification,
      warnings: warnings ?? this.warnings,
      alternatives: alternatives ?? this.alternatives,
      updatedAt: updatedAt ?? this.updatedAt,
      metadataUpdatedAt: metadataUpdatedAt ?? this.metadataUpdatedAt,
      alternativesUpdatedAt:
          alternativesUpdatedAt ?? this.alternativesUpdatedAt,
    );
  }

  factory ApiDetail.fromApi(ApiItem api, {String? routeSlug, AppLocalizations? l10n}) {
    final slug = routeSlug?.trim().isNotEmpty == true
        ? routeSlug!
        : api.slug.isNotEmpty
            ? api.slug
            : slugifyApiName(api.name);
    final checkedAt = api.lastCheckedDateTime;
    final status = mapHealthStatus(
      isAlive: api.isAlive,
      statusCode: api.statusCode,
      responseTimeMs: api.responseTime,
      checkedAt: checkedAt,
    );
    final categorySlug = slugifyApiName(
        api.category.isNotEmpty ? api.category : (api.categoryId ?? ''));
    final categoryName = api.category.isNotEmpty
        ? api.category
        : (api.categoryId ?? l10n?.apiDetailUnknownValue ?? 'Unknown');
    final auth = parseAuthType(api.auth);
    final pricing = parsePricingType(api.pricing);
    final cors = parseCorsSupport(api.cors, supported: api.supportsCors);
    final baseUrl = _uri(api.link);

    return ApiDetail(
      id: api.id,
      slug: slug,
      name: api.name,
      shortDescription: api.description.isEmpty
          ? (l10n?.apiDetailNoDescription ?? 'No reviewed description is available.')
          : api.description,
      category: ApiCategory(
        id: categorySlug,
        name: categoryName,
        slug: categorySlug,
      ),
      access: ApiAccess(
        authType: auth,
        authLabel: authTypeLabel(auth, api.auth, l10n: l10n),
        pricingType: pricing,
        pricingLabel: pricingTypeLabel(pricing, api.pricing, l10n: l10n),
        rateLimit: _knownValue(api.rateLimit),
      ),
      links: ApiLinks(
        baseUrl: baseUrl,
        homepageUrl: _origin(baseUrl),
        documentationUrl: _uri(api.documentation),
      ),
      capabilities: ApiCapabilities(
        https: api.supportsHttps ? true : null,
        cors: cors,
        protocol: parseProtocol(api.apiType),
        responseFormats: const [],
      ),
      health: ApiHealthSummary(
        status: status,
        statusCode: api.statusCode,
        responseTimeMs: api.responseTime,
        checkedAt: checkedAt,
        method: l10n?.apiDetailAutomatedBackendCheck ?? 'Automated backend check',
      ),
      verification: [
        FieldVerification(
          label: l10n?.apiDetailHealth ?? 'Health',
          source: checkedAt == null
              ? (l10n?.apiDetailNotVerified ?? 'Not verified')
              : (l10n?.apiDetailAutomatedCheck ?? 'Automated check'),
          verifiedAt: checkedAt,
        ),
        FieldVerification(
          label: l10n?.apiDetailPricing ?? 'Pricing',
          source: l10n?.apiDetailImported ?? 'Imported',
        ),
        FieldVerification(
          label: l10n?.apiDetailAuthentication ?? 'Authentication',
          source: l10n?.apiDetailImported ?? 'Imported',
        ),
        FieldVerification(
          label: l10n?.apiDetailCors ?? 'CORS',
          source: l10n?.apiDetailImported ?? 'Imported',
        ),
      ],
      warnings: buildWarnings(
        authType: auth,
        pricingType: pricing,
        cors: cors,
        documentationUrl: _uri(api.documentation),
        healthStatus: status,
        l10n: l10n,
      ),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'shortDescription': shortDescription,
        'fullDescription': fullDescription,
        'imageUrl': imageUrl,
        'category': category.toJson(),
        'access': access.toJson(),
        'links': links.toJson(),
        'capabilities': capabilities.toJson(),
        'health': health.toJson(),
        'trustScore': trustScore?.toJson(),
        'verification': verification.map((item) => item.toJson()).toList(),
        'warnings': warnings.map((item) => item.toJson()).toList(),
        'alternatives': alternatives.map((item) => item.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
        'metadataUpdatedAt': metadataUpdatedAt?.toIso8601String(),
        'alternativesUpdatedAt': alternativesUpdatedAt?.toIso8601String(),
      };

  factory ApiDetail.fromJson(Map<String, dynamic> json) => ApiDetail(
        id: json['id']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        shortDescription: json['shortDescription']?.toString() ?? '',
        fullDescription: json['fullDescription']?.toString(),
        imageUrl: json['imageUrl']?.toString(),
        category: ApiCategory.fromJson(
          Map<String, dynamic>.from(json['category'] ?? const {}),
        ),
        access: ApiAccess.fromJson(
          Map<String, dynamic>.from(json['access'] ?? const {}),
        ),
        links: ApiLinks.fromJson(
          Map<String, dynamic>.from(json['links'] ?? const {}),
        ),
        capabilities: ApiCapabilities.fromJson(
          Map<String, dynamic>.from(json['capabilities'] ?? const {}),
        ),
        health: ApiHealthSummary.fromJson(
          Map<String, dynamic>.from(json['health'] ?? const {}),
        ),
        trustScore: json['trustScore'] is Map
            ? ApiTrustScore.fromJson(
                Map<String, dynamic>.from(json['trustScore'] as Map),
              )
            : null,
        verification: parseVerification(json['verification']),
        warnings: (json['warnings'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => ApiWarning.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        alternatives: (json['alternatives'] as List? ?? const [])
            .whereType<Map>()
            .map((item) =>
                ApiAlternative.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        metadataUpdatedAt:
            DateTime.tryParse(json['metadataUpdatedAt']?.toString() ?? ''),
        alternativesUpdatedAt:
            DateTime.tryParse(json['alternativesUpdatedAt']?.toString() ?? ''),
      );

  @override
  List<Object?> get props => [
        id,
        slug,
        name,
        shortDescription,
        fullDescription,
        imageUrl,
        category,
        access,
        links,
        capabilities,
        health,
        trustScore,
        verification,
        warnings,
        alternatives,
        updatedAt,
        metadataUpdatedAt,
        alternativesUpdatedAt,
      ];
}

ApiHealthStatus mapHealthStatus({
  required bool? isAlive,
  required int? statusCode,
  required int? responseTimeMs,
  required DateTime? checkedAt,
}) {
  if (checkedAt == null) return ApiHealthStatus.unknown;
  if (statusCode == 401 || statusCode == 403) {
    return ApiHealthStatus.authenticationRequired;
  }
  if (statusCode == 429) return ApiHealthStatus.rateLimited;
  if (isAlive == false || (statusCode != null && statusCode >= 500)) {
    return ApiHealthStatus.unavailable;
  }
  if (responseTimeMs != null && responseTimeMs >= 1000) {
    return ApiHealthStatus.degraded;
  }
  if (isAlive == true || (statusCode != null && statusCode < 500)) {
    return ApiHealthStatus.operational;
  }
  return ApiHealthStatus.unknown;
}

ApiHealthStatus parseHealthStatus(String? value) {
  final normalized = value?.trim().toLowerCase() ?? '';
  return switch (normalized) {
    'operational' => ApiHealthStatus.operational,
    'authentication_required' ||
    'authenticationrequired' =>
      ApiHealthStatus.authenticationRequired,
    'rate_limited' || 'ratelimited' => ApiHealthStatus.rateLimited,
    'degraded' => ApiHealthStatus.degraded,
    'unavailable' => ApiHealthStatus.unavailable,
    _ => ApiHealthStatus.unknown,
  };
}

List<ApiWarning> buildWarnings({
  required ApiAuthType authType,
  required ApiPricingType pricingType,
  required CorsSupport cors,
  required Uri? documentationUrl,
  required ApiHealthStatus healthStatus,
  AppLocalizations? l10n,
}) {
  return [
    if (authType != ApiAuthType.none && authType != ApiAuthType.unknown)
      ApiWarning(l10n?.apiDetailWarningAuthRequired(authTypeLabel(authType, '', l10n: l10n)) ?? '${authTypeLabel(authType, '')} required'),
    if (pricingType == ApiPricingType.paid)
      ApiWarning(l10n?.apiDetailWarningPaidAccess ?? 'Paid access reported'),
    if (documentationUrl == null)
      ApiWarning(l10n?.apiDetailWarningNoDocs ?? 'Documentation URL is not available'),
    if (cors == CorsSupport.unknown)
      ApiWarning(l10n?.apiDetailWarningCorsNotVerified ?? 'CORS support is not verified'),
    if (healthStatus == ApiHealthStatus.unknown)
      ApiWarning(l10n?.apiDetailWarningNoHealthResult ?? 'No recent platform health result is available'),
  ];
}

ApiAuthType parseAuthType(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll('_', ' ') ?? '';
  if (normalized.isEmpty || normalized == 'unknown') return ApiAuthType.unknown;
  if (normalized == 'none' || normalized == 'no') return ApiAuthType.none;
  if (normalized.contains('oauth')) return ApiAuthType.oauth2;
  if (normalized.contains('basic')) return ApiAuthType.basic;
  if (normalized.contains('key') || normalized.contains('token')) {
    return ApiAuthType.apiKey;
  }
  return ApiAuthType.unknown;
}

String authTypeLabel(ApiAuthType type, String raw, {AppLocalizations? l10n}) => switch (type) {
      ApiAuthType.none => l10n?.apiDetailNoAuthentication ?? 'No authentication',
      ApiAuthType.apiKey => 'API key',
      ApiAuthType.oauth2 => 'OAuth 2.0',
      ApiAuthType.basic => l10n?.apiDetailBasicAuthentication ?? 'Basic authentication',
      ApiAuthType.unknown => _knownValue(raw) ?? (l10n?.apiDetailUnknownValue ?? 'Unknown'),
    };

ApiPricingType parsePricingType(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll('_', ' ') ?? '';
  if (normalized == 'free') return ApiPricingType.free;
  if (normalized.contains('freemium') || normalized.contains('free tier')) {
    return ApiPricingType.freemium;
  }
  if (normalized == 'paid' || normalized.contains('subscription')) {
    return ApiPricingType.paid;
  }
  return ApiPricingType.unknown;
}

String pricingTypeLabel(ApiPricingType type, String? raw, {AppLocalizations? l10n}) => switch (type) {
      ApiPricingType.free => l10n?.apiDetailFree ?? 'Free',
      ApiPricingType.freemium => l10n?.apiDetailFreeTier ?? 'Free tier',
      ApiPricingType.paid => l10n?.apiDetailPaid ?? 'Paid',
      ApiPricingType.unknown => _knownValue(raw) ?? (l10n?.apiDetailUnknownValue ?? 'Unknown'),
    };

CorsSupport parseCorsSupport(String? value, {bool? supported}) {
  final normalized = value?.trim().toLowerCase() ?? '';
  if (supported == true || normalized == 'yes' || normalized == 'true') {
    return CorsSupport.supported;
  }
  if (normalized == 'no' || normalized == 'false') {
    return CorsSupport.unsupported;
  }
  return CorsSupport.unknown;
}

ApiProtocol parseProtocol(String? value) {
  final normalized = value?.trim().toLowerCase() ?? '';
  if (normalized == 'rest') return ApiProtocol.rest;
  if (normalized == 'graphql') return ApiProtocol.graphql;
  if (normalized == 'soap') return ApiProtocol.soap;
  if (normalized.contains('websocket')) return ApiProtocol.websocket;
  return ApiProtocol.unknown;
}

List<FieldVerification> parseVerification(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((item) =>
            FieldVerification.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  if (raw is Map) {
    return raw.entries.where((entry) => entry.value is Map).map((entry) {
      final json = Map<String, dynamic>.from(entry.value as Map);
      return FieldVerification.fromJson({
        ...json,
        'label': fieldLabel(entry.key.toString()),
      });
    }).toList();
  }
  return const [];
}

String fieldLabel(String value) {
  final words = value.replaceAll('_', ' ').split(RegExp(r'\s+|-+'));
  return words
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String verificationSourceLabel(String? value, {AppLocalizations? l10n}) {
  final normalized = value?.trim().toLowerCase() ?? '';
  return switch (normalized) {
    'provider' => l10n?.apiDetailSourceProvider ?? 'Provider',
    'automated_check' => l10n?.apiDetailAutomatedCheck ?? 'Automated check',
    'core_api_review' => l10n?.apiDetailSourceRegistryReview ?? 'Reqistry review',
    'community_report' => l10n?.apiDetailSourceCommunityReport ?? 'Community report',
    'imported' => l10n?.apiDetailImported ?? 'Imported',
    'not verified' => l10n?.apiDetailNotVerified ?? 'Not verified',
    _ => l10n?.apiDetailUnknownValue ?? 'Unknown',
  };
}

String slugifyApiName(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

String? _knownValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null ||
      trimmed.isEmpty ||
      trimmed.toLowerCase() == 'unknown') {
    return null;
  }
  return trimmed;
}

Uri? _uri(Object? value) {
  final parsed = Uri.tryParse(value?.toString() ?? '');
  return parsed != null && parsed.hasScheme && parsed.host.isNotEmpty
      ? parsed
      : null;
}

Uri? _origin(Uri? uri) {
  if (uri == null) return null;
  return uri.hasPort
      ? Uri(scheme: uri.scheme, host: uri.host, port: uri.port)
      : Uri(scheme: uri.scheme, host: uri.host);
}
