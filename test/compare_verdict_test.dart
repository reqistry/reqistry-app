import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:flutter_test/flutter_test.dart';

CompareApi _api(
  String id, {
  int? trust,
  int? ms,
  num? uptime,
  String pricing = 'Free',
}) {
  return CompareApi(
    id: id,
    slug: id,
    name: 'API $id',
    category: 'Test',
    trustScore: trust,
    authType: 'Unknown',
    pricingType: pricing,
    rateLimit: 'Unknown',
    sdkLanguages: const [],
    responseTimeMs: ms,
    uptime30d: uptime,
    cors: 'Unknown',
    openApiAvailable: false,
  );
}

void main() {
  group('buildCompareVerdict', () {
    test('picks highest trust and contextual bests', () {
      final verdict = buildCompareVerdict([
        _api('a', trust: 70, ms: 900, uptime: 99),
        _api('b', trust: 92, ms: 200, uptime: 97),
      ])!;
      expect(verdict.topPick.id, 'b');
      expect(verdict.fastest!.id, 'b');
      expect(verdict.bestUptime!.id, 'a');
    });

    test('skips missing measurements', () {
      final verdict = buildCompareVerdict([
        _api('a'),
        _api('b', trust: 50),
      ])!;
      expect(verdict.topPick.id, 'b');
      expect(verdict.fastest, isNull);
      expect(verdict.bestUptime, isNull);
    });

    test('returns null for empty input', () {
      expect(buildCompareVerdict(const []), isNull);
    });
  });

  group('uniqueBestIndex', () {
    test('finds unique extremes and rejects ties', () {
      expect(uniqueBestIndex([70, 92, 80]), 1);
      expect(uniqueBestIndex([200, 900], lowerIsBetter: true), 0);
      expect(uniqueBestIndex([80, 80]), -1);
      expect(uniqueBestIndex(const []), -1);
    });
  });

  group('pricingRank', () {
    test('ranks cheapest first, unknown last', () {
      expect(pricingRank('Free'), 0);
      expect(pricingRank('Freemium'), 1);
      expect(pricingRank('Paid'), 2);
      expect(pricingRank('Unknown'), 3);
      expect(pricingRank('whatever'), 3);
    });
  });
}
