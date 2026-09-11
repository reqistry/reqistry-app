import 'package:api_scout/app/data/models/pro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entitlements.fromJson', () {
    test('parses pro envelope with limits', () {
      final entitlements = Entitlements.fromJson({
        'data': {
          'tier': 'pro',
          'isPro': true,
          'proExpiresAt': '2026-10-06T00:00:00.000Z',
          'trialUsed': true,
          'emailLinked': true,
          'limits': {'compareMax': 8, 'watchlistsMax': 10, 'agentKeysMax': 5},
        },
      });
      expect(entitlements.isPro, isTrue);
      expect(entitlements.compareMax, 8);
      expect(entitlements.watchlistsMax, 10);
      expect(entitlements.agentKeysMax, 5);
      expect(entitlements.emailLinked, isTrue);
    });

    test('defaults to free on missing payload', () {
      final entitlements = Entitlements.fromJson({});
      expect(entitlements.isPro, isFalse);
      expect(entitlements.tier, 'free');
      expect(entitlements.compareMax, 4);
    });

    test('parses opaque billing account and purchases gate', () {
      final entitlements = Entitlements.fromJson({
        'data': {
          'tier': 'pro',
          'isPro': true,
          'billingAccountId': 'uuid-123',
          'purchasesEnabled': true,
        },
      });
      expect(entitlements.billingAccountId, 'uuid-123');
      expect(entitlements.purchasesEnabled, isTrue);
    });

    test('defaults billing account empty and purchases disabled', () {
      final entitlements = Entitlements.fromJson({});
      expect(entitlements.billingAccountId, isEmpty);
      expect(entitlements.purchasesEnabled, isFalse);
    });
  });

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
