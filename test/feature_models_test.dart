import 'package:api_scout/app/data/models/feature_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShipCheckReport.fromJson', () {
    test('parses verdict, checks and factors', () {
      final report = ShipCheckReport.fromJson({
        'data': {
          'apiId': 'uuid-1',
          'slug': 'resend',
          'name': 'Resend',
          'verdict': 'caution',
          'score': 64,
          'grade': 'C',
          'checks': {'health': 'pass', 'https': 'fail'},
          'factors': {'uptime': {'score': 90}},
        },
      });
      expect(report.ships, isFalse);
      expect(report.avoid, isFalse);
      expect(report.checks['https'], 'fail');
      expect(report.factors['uptime'], isNotNull);
    });

    test('survives empty payload', () {
      final report = ShipCheckReport.fromJson({});
      expect(report.verdict, 'caution');
      expect(report.name, 'Unknown');
      expect(report.checks, isEmpty);
    });
  });

  group('WatchItem / AgentKeyItem / StackHistoryItem', () {
    test('parse defensively', () {
      final watch = WatchItem.fromJson({'id': 'w1'});
      expect(watch.kind, 'keyword');
      expect(watch.value, isEmpty);

      final key = AgentKeyItem.fromJson({'id': 'k1', 'prefix': 'req_abcd'});
      expect(key.isActive, isTrue);
      expect(key.key, isNull);

      final snapshot = StackHistoryItem.fromJson({});
      expect(snapshot.downCount, 0);
      expect(snapshot.avgTrust, isNull);
    });
  });
}
