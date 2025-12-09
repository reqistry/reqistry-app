import 'dart:convert';

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
  final String name;
  final String description;
  final String auth;
  final bool https;
  final bool cors;
  final String link;
  final String categoryId;
  final String? pricing;
  final bool? alive;

  Api({
    required this.id,
    required this.name,
    required this.description,
    required this.auth,
    required this.https,
    required this.cors,
    required this.link,
    required this.categoryId,
    this.pricing,
    this.alive,
  });

  factory Api.fromJson(Map<String, dynamic> json) => Api(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        auth: json["auth"],
        https: json["https"] is bool ? json["https"] : json["https"] == "true",
        cors: json["cors"] is bool ? json["cors"] : json["cors"] == "true",
        link: json["link"],
        categoryId: json["categoryId"],
        pricing: json["pricing"],
        alive: json["alive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "auth": auth,
        "https": https,
        "cors": cors,
        "link": link,
        "categoryId": categoryId,
        if (pricing != null) "pricing": pricing,
        if (alive != null) "alive": alive,
      };
}
