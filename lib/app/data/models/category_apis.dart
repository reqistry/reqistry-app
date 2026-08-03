class CategoryApis {
  final String title;
  final List<ApiItem> apis;

  CategoryApis({
    required this.title,
    required this.apis,
  });

  factory CategoryApis.fromJson(Map<String, dynamic> json) {
    return CategoryApis(
      title: json["title"] ?? "",
      apis: List<ApiItem>.from(
        (json["apis"] as List<dynamic>? ?? [])
            .map((x) => ApiItem.fromJson(x as Map<String, dynamic>)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "apis": List<dynamic>.from(apis.map((x) => x.toJson())),
      };
}

class ApiItem {
  final String id;
  final String name;
  final String description;
  final String auth;
  final String https;
  final String cors;
  final String link;
  final String? imageUrl;
  final String category;
  final String apiType;
  final String pricing;
  final String rateLimit;
  final String documentation;
  final bool isAlive;
  final int responseTime;
  final int? statusCode;
  final String lastChecked;

  ApiItem({
    this.id = '',
    required this.name,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    required this.link,
    this.imageUrl,
    required this.category,
    required this.apiType,
    required this.pricing,
    required this.rateLimit,
    required this.documentation,
    required this.isAlive,
    required this.responseTime,
    this.statusCode,
    required this.lastChecked,
  });

  factory ApiItem.fromJson(Map<String, dynamic> json) {
    final category = json["category"];
    final authType = json["authType"];
    final apiType = json["apiType"];
    final pricingType = json["pricingType"];
    final health = json["currentHealth"];

    return ApiItem(
      id: json["id"]?.toString() ?? json["apiId"]?.toString() ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      auth: json["auth"]?.toString() ??
          (authType is Map ? authType["name"]?.toString() : null) ??
          "None",
      https: json["https"]?.toString() ??
          json["httpsSupport"]?.toString() ??
          "Unknown",
      cors: json["cors"]?.toString() ?? "Unknown",
      link: json["link"] ?? "",
      imageUrl: json["imageUrl"]?.toString(),
      category: category is Map
          ? category["name"]?.toString() ?? ""
          : category?.toString() ?? "",
      apiType: json["apiType"] is String
          ? json["apiType"]
          : apiType is Map
              ? apiType["name"]?.toString() ?? "REST"
              : "REST",
      pricing: json["pricing"]?.toString() ??
          (pricingType is Map ? pricingType["name"]?.toString() : null) ??
          "Unknown",
      rateLimit: json["rateLimit"]?.toString() ?? "Unknown",
      documentation: json["documentation"]?.toString() ??
          json["documentationUrl"]?.toString() ??
          "",
      isAlive: json["isAlive"] == true ||
          json["alive"] == true ||
          (health is Map && health["isAlive"] == true) ||
          json["isAlive"]?.toString().toLowerCase() == "true",
      responseTime: (json["responseTime"] is num)
          ? (json["responseTime"] as num).round()
          : (health is Map && health["responseTimeMs"] is num)
              ? (health["responseTimeMs"] as num).round()
              : int.tryParse('${json["responseTime"] ?? 0}') ?? 0,
      statusCode: json["statusCode"] is num
          ? (json["statusCode"] as num).round()
          : (health is Map && health["statusCode"] is num)
              ? (health["statusCode"] as num).round()
              : null,
      lastChecked: json["lastChecked"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) "id": id,
        "name": name,
        "description": description,
        "auth": auth,
        "https": https,
        "cors": cors,
        "link": link,
        "category": category,
        "apiType": apiType,
        "pricing": pricing,
        "rateLimit": rateLimit,
        "documentation": documentation,
        "isAlive": isAlive,
        "responseTime": responseTime,
        if (statusCode != null) "statusCode": statusCode,
        "lastChecked": lastChecked,
      };

  /// Check if API requires authentication
  bool get requiresAuth => auth.toLowerCase() != "none";

  /// Check if API supports HTTPS
  bool get supportsHttps {
    final value = https.toLowerCase();
    return value == "true" || value == "yes";
  }

  /// Check if API supports CORS
  bool get supportsCors {
    final value = cors.toLowerCase();
    return value == "true" || value == "yes";
  }

  /// Get status code description
  String get statusDescription {
    if (statusCode == null) return "Unknown";
    if (statusCode! < 300) return "Success";
    if (statusCode! < 400) return "Redirect";
    if (statusCode! < 500) return "Client Error";
    return "Server Error";
  }

  /// Get health status
  String get healthStatus => isAlive ? "Alive" : "Dead";

  /// Get response time in readable format
  String get responseTimeFormatted {
    if (responseTime < 1000) return "${responseTime}ms";
    return "${(responseTime / 1000).toStringAsFixed(2)}s";
  }

  /// Get last checked time as DateTime
  DateTime? get lastCheckedDateTime {
    try {
      return DateTime.parse(lastChecked);
    } catch (e) {
      return null;
    }
  }

  /// Check if the API information is fresh (checked within last 24 hours)
  bool get isFresh {
    final checked = lastCheckedDateTime;
    if (checked == null) return false;
    return DateTime.now().difference(checked).inHours < 24;
  }
}
