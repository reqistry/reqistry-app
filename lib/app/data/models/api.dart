import 'dart:convert';

import 'bookmark_item.dart';
import 'category_apis.dart';

List<Api> apisFromJson(String str) => List<Api>.from(
      json.decode(str).map(
            (x) => Api.fromJson(x),
          ),
    );

String apisToJson(List<Api> data) => json.encode(
      List<dynamic>.from(
        data.map(
          (x) => x.toJson(),
        ),
      ),
    );

class Api {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String auth;
  final bool https;
  final bool cors;
  final String link;
  final String? imageUrl;
  final String categoryId;
  final String? pricing;
  final bool? alive;
  final String? documentationUrl;
  final String? apiType;
  final String? rateLimit;
  final String? corsStatus;
  final int? responseTimeMs;
  final int? statusCode;
  final DateTime? lastCheckedAt;

  Api({
    required this.id,
    this.slug = '',
    required this.name,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    required this.link,
    this.imageUrl,
    required this.categoryId,
    this.pricing,
    this.alive,
    this.documentationUrl,
    this.apiType,
    this.rateLimit,
    this.corsStatus,
    this.responseTimeMs,
    this.statusCode,
    this.lastCheckedAt,
  });

  factory Api.fromJson(Map<String, dynamic> json) {
    final category = json["category"];
    final authType = json["authType"];
    final pricingType = json["pricingType"];
    final health = json["currentHealth"];

    return Api(
      id: json["id"]?.toString() ?? json["apiId"]?.toString() ?? "",
      slug: json["slug"]?.toString() ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      auth: json["auth"]?.toString() ??
          (authType is Map ? authType["name"]?.toString() : null) ??
          "",
      https: json["https"] is bool
          ? json["https"]
          : json["httpsSupport"] == true ||
              json["https"]?.toString().toLowerCase() == "true" ||
              json["https"]?.toString().toLowerCase() == "yes",
      cors: json["cors"] is bool
          ? json["cors"]
          : json["cors"]?.toString().toLowerCase() == "true" ||
              json["cors"]?.toString().toLowerCase() == "yes",
      link: json["link"] ?? "",
      imageUrl: json["imageUrl"]?.toString(),
      categoryId: json["categoryId"]?.toString() ??
          (category is Map ? category["name"]?.toString() : null) ??
          category?.toString() ??
          "",
      pricing: json["pricing"]?.toString() ??
          (pricingType is Map ? pricingType["name"]?.toString() : null),
      alive: json["alive"] is bool
          ? json["alive"]
          : json["isAlive"] is bool
              ? json["isAlive"]
              : health is Map && health["isAlive"] is bool
                  ? health["isAlive"]
                  : null,
      documentationUrl: json["documentationUrl"]?.toString() ??
          json["documentation"]?.toString(),
      apiType: json["apiType"] is Map
          ? json["apiType"]["name"]?.toString()
          : json["apiType"]?.toString(),
      rateLimit: json["rateLimit"]?.toString(),
      corsStatus: json["corsStatus"]?.toString() ?? json["cors"]?.toString(),
      responseTimeMs: health is Map && health["responseTimeMs"] is num
          ? (health["responseTimeMs"] as num).round()
          : json["responseTime"] is num
              ? (json["responseTime"] as num).round()
              : null,
      statusCode: health is Map && health["statusCode"] is num
          ? (health["statusCode"] as num).round()
          : json["statusCode"] is num
              ? (json["statusCode"] as num).round()
              : null,
      lastCheckedAt: DateTime.tryParse(
        json["lastChecked"]?.toString() ??
            (health is Map ? health["checkedAt"]?.toString() ?? "" : ""),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        if (slug.isNotEmpty) "slug": slug,
        "name": name,
        "description": description,
        "auth": auth,
        "https": https,
        "cors": cors,
        "link": link,
        if (imageUrl != null) "imageUrl": imageUrl,
        "categoryId": categoryId,
        if (pricing != null) "pricing": pricing,
        if (alive != null) "alive": alive,
        if (documentationUrl != null) "documentationUrl": documentationUrl,
        if (apiType != null) "apiType": apiType,
        if (rateLimit != null) "rateLimit": rateLimit,
        if (corsStatus != null) "corsStatus": corsStatus,
        if (responseTimeMs != null) "responseTime": responseTimeMs,
        if (statusCode != null) "statusCode": statusCode,
        if (lastCheckedAt != null)
          "lastChecked": lastCheckedAt!.toIso8601String(),
      };
}

extension BookmarkApiModel on BookmarkApi {
  Api toApi() => Api(
        id: id,
        slug: slug,
        name: name,
        description: description,
        auth: authTypeName,
        https: httpsSupport,
        cors: false,
        link: link,
        imageUrl: imageUrl,
        categoryId: categoryName,
        pricing: pricingTypeName,
        alive: currentHealth?.isAlive,
        documentationUrl: documentationUrl,
        apiType: apiTypeName,
        corsStatus: corsStatus,
        responseTimeMs: currentHealth?.responseTimeMs,
        statusCode: currentHealth?.statusCode,
      );

  ApiItem toApiItem() => ApiItem(
        id: id,
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
