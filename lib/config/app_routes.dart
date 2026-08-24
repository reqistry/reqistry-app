abstract class AppRoutes {
  AppRoutes._();

  static const auth = '/auth';
  static const home = '/';
  static const apiDetail = '/apis/:slug';
  static const categoryApis = '/category-apis';
  static const projectApis = '/project-apis';
  static const latestApis = '/latest-apis';
  static const recommendedApis = '/recommended-apis';
  static const submitApi = '/submit-api';
  static const privacy = '/privacy';
  static const contact = '/contact';
  static const accountSettings = '/account-settings';
  static const appSettings = '/app-settings';
  static const notifications = '/notifications';
  static const compare = '/compare';
  static const search = '/search';

  static String apiDetailPath(String slug, {String? source}) {
    final path = '/apis/${Uri.encodeComponent(slug)}';
    return source == null
        ? path
        : '$path?source=${Uri.encodeQueryComponent(source)}';
  }

  // Tab indices (not GoRouter routes)
  static const int tabIndexHome = 0;
  static const int tabIndexSearch = 1;
  static const int tabIndexIntelligence = 2;
  static const int tabIndexFavorites = 3;
  static const int tabIndexSettings = 4;
}
