import 'package:api_scout/config/routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

List<String> _routePaths(List<RouteBase> routes) => [
      for (final route in routes)
        if (route is GoRoute) ...[
          route.path,
          ..._routePaths(route.routes),
        ],
    ];

void main() {
  test('router has no subscription paywall route', () {
    final paths = _routePaths(AppRouter.router.configuration.routes);
    expect(paths, isNot(contains('/pro')));
  });
}
