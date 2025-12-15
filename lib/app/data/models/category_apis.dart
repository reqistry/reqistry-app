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
  final String name;
  final String description;
  final String auth;
  final String https;
  final String cors;
  final String link;
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
    required this.name,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    required this.link,
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
    return ApiItem(
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      auth: json["auth"] ?? "None",
      https: json["https"] ?? "Unknown",
      cors: json["cors"] ?? "Unknown",
      link: json["link"] ?? "",
      category: json["category"] ?? "",
      apiType: json["apiType"] ?? "REST",
      pricing: json["pricing"] ?? "Unknown",
      rateLimit: json["rateLimit"] ?? "Unknown",
      documentation: json["documentation"] ?? "",
      isAlive: json["isAlive"] ?? false,
      responseTime: json["responseTime"] ?? 0,
      statusCode: json["statusCode"],
      lastChecked: json["lastChecked"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
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
  bool get supportsHttps => https.toLowerCase() == "true";

  /// Check if API supports CORS
  bool get supportsCors => cors.toLowerCase() == "yes";

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
