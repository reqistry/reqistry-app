abstract class AppRoutes {
  AppRoutes._();

  static const auth = '/auth';
  static const home = '/';
  static const apiDetail = '/apis/:slug';
  static const categoryApis = '/category-apis';
  static const allProjects = '/projects';
  static const projectApis = '/projects/:id';
  static const latestApis = '/latest-apis';
  static const recommendedApis = '/recommended-apis';
  static const submitApi = '/submit-api';
  static const agentConsole = '/agent';
  static const submissions = '/submissions';
  static const watchlists = '/watchlists';
  static const privacy = '/privacy';
  static const contact = '/contact';
  static const accountSettings = '/account-settings';
  static const appSettings = '/app-settings';
  static const notifications = '/notifications';
  static const compare = '/compare';
  static const changeFeed = '/change-feed';
  static const search = '/search';

  static String apiDetailPath(String slug, {String? source}) {
    final path = '/apis/${Uri.encodeComponent(slug)}';
    return source == null
        ? path
        : '$path?source=${Uri.encodeQueryComponent(source)}';
  }

  static String projectPath(String id) =>
      '/projects/${Uri.encodeComponent(id)}';

  static String comparePath(List<String> apiIds) => Uri(
        path: compare,
        queryParameters: {'ids': apiIds.join(',')},
      ).toString();

  static List<String> compareIds(Uri uri) =>
      uri.queryParameters['ids']
          ?.split(',')
          .where((id) => id.isNotEmpty)
          .toList() ??
      const [];

  // Tab indices (not GoRouter routes)
  static const int tabIndexHome = 0;
  static const int tabIndexSearch = 1;
  static const int tabIndexIntelligence = 2;
  static const int tabIndexFavorites = 3;
  static const int tabIndexSettings = 4;
}
