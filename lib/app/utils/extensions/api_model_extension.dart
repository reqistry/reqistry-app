import '../../data/models/category_apis.dart';

extension ApiBoolExtension on ApiItem {
  bool hasAuth() {
    return auth.toLowerCase() != "none";
  }

  bool isHttps() {
    return https.toLowerCase() == "true";
  }

  bool isHttp() {
    return !isHttps();
  }

  bool hasCors() {
    return cors.toLowerCase() == "yes";
  }

  bool hasUnknownCors() {
    return cors.toLowerCase() == "unknown";
  }

  bool hasAuthWithApiKey() {
    return auth.toLowerCase() == "apikey";
  }

  bool isOpenSource() {
    return link.toLowerCase().contains("github");
  }
}
