import 'package:flutter_test/flutter_test.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/data/models/category_apis.dart';

void main() {
  group('SearchState.copyWith nullable clearing', () {
    test('clears nullable filters when null is passed explicitly', () {
      const base = SearchState(
        cors: 'yes',
        https: true,
        alive: true,
        maxResponseTime: 500,
        activeQuickFilter: 'fast',
        hasSearched: true,
      );
      final cleared = base.copyWith(
        cors: null,
        https: null,
        alive: null,
        maxResponseTime: null,
        activeQuickFilter: null,
      );
      expect(cleared.cors, isNull);
      expect(cleared.https, isNull);
      expect(cleared.alive, isNull);
      expect(cleared.maxResponseTime, isNull);
      expect(cleared.activeQuickFilter, isNull);
      expect(cleared.hasSearched, isTrue);
    });

    test('keeps nullable filters when omitted', () {
      const base = SearchState(cors: 'yes', https: true);
      final kept = base.copyWith(query: 'payments');
      expect(kept.cors, 'yes');
      expect(kept.https, isTrue);
      expect(kept.query, 'payments');
    });
  });

  group('SearchBloc.applyClientFilters', () {
    ApiItem item(String type, int ms) => ApiItem(
          name: 'n',
          description: 'd',
          auth: 'None',
          https: 'true',
          cors: 'Yes',
          link: 'https://example.com',
          category: 'c',
          apiType: type,
          pricing: 'Free',
          rateLimit: 'Unknown',
          documentation: '',
          isAlive: true,
          responseTime: ms,
          lastChecked: '',
        );

    test('filters by type case-insensitively', () {
      final apis = [item('REST', 100), item('GraphQL', 100)];
      final out =
          SearchBloc.applyClientFilters(apis, {'graphql'}, null);
      expect(out.map((e) => e.apiType), ['GraphQL']);
    });

    test('max time drops slow and unknown-latency rows', () {
      final apis = [item('REST', 100), item('REST', 900), item('REST', 0)];
      final out = SearchBloc.applyClientFilters(apis, {}, 500);
      expect(out.map((e) => e.responseTime), [100]);
    });

    test('no filters passes everything through', () {
      final apis = [item('REST', 0), item('SOAP', 5)];
      expect(SearchBloc.applyClientFilters(apis, {}, null), hasLength(2));
    });
  });
}
