import 'package:api_scout/app/data/models/intelligence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrustFactor.parseFactors', () {
    test('orders known factors by backend weight order', () {
      final factors = TrustFactor.parseFactors({
        'cors': {'score': 55, 'weight': 10, 'label': 'CORS'},
        'uptime': {'score': 95, 'weight': 25, 'label': '30 day uptime'},
        'openApi': {'score': 35, 'weight': 5, 'label': 'OpenAPI availability'},
      });
      expect(
        factors.keys.toList(),
        ['uptime', 'cors', 'openApi'],
      );
    });

    test('appends unknown future dimensions alphabetically', () {
      final factors = TrustFactor.parseFactors({
        'zeta': {'score': 10, 'weight': 1, 'label': 'Zeta'},
        'uptime': {'score': 95, 'weight': 25, 'label': '30 day uptime'},
        'alpha': {'score': 20, 'weight': 1, 'label': 'Alpha'},
      });
      expect(
        factors.keys.toList(),
        ['uptime', 'alpha', 'zeta'],
      );
    });

    test('skips malformed entries and clamps scores', () {
      final factors = TrustFactor.parseFactors({
        'uptime': {'score': 140, 'weight': 25, 'label': 'Uptime'},
        'broken': 'not-a-map',
        'freshness': {'score': -5, 'weight': 10},
      });
      expect(factors['uptime']!.score, 100);
      expect(factors.containsKey('broken'), isFalse);
      expect(factors['freshness']!.score, 0);
      expect(factors['freshness']!.label, 'freshness');
    });

    test('returns empty for non-map input', () {
      expect(TrustFactor.parseFactors(null), isEmpty);
      expect(TrustFactor.parseFactors([]), isEmpty);
    });
  });
}
