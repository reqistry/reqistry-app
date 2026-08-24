import 'package:flutter_test/flutter_test.dart';
import 'package:api_scout/app/data/models/intelligence.dart';

void main() {
  group('CompareApi.fromJson', () {
    test('parses full compareApiItem payload from /v1/apis/compare', () {
      final api = CompareApi.fromJson({
        'id': 'id-1',
        'slug': 'livekit-server-api',
        'name': 'LiveKit Server API',
        'category': 'Video',
        'trustScore': {
          'score': 97,
          'grade': 'A',
          'summary': 'Excellent production-readiness signals.',
          'factors': {},
          'computedAt': '2026-08-23T23:09:03.306Z',
        },
        'authType': 'API Key',
        'pricingType': 'Freemium',
        'rateLimit': null,
        'sdkLanguages': ['JavaScript', 'Python'],
        'responseTimeMs': 218,
        'uptime30d': 100,
        'cors': 'Yes',
        'https': true,
        'openApiAvailable': false,
        'documentationUrl': 'https://docs.livekit.io/reference/',
        'lastVerifiedAt': '2026-08-23T23:09:03.293Z',
      });

      expect(api.id, 'id-1');
      expect(api.slug, 'livekit-server-api');
      expect(api.trustScore, 97);
      expect(api.trustGrade, 'A');
      expect(api.pricingType, 'Freemium');
      expect(api.rateLimit, 'Unknown'); // null server value
      expect(api.sdkLanguages, ['JavaScript', 'Python']);
      expect(api.responseTimeMs, 218);
      expect(api.uptime30d, 100);
      expect(api.https, isTrue);
      expect(api.openApiAvailable, isFalse);
    });

    test('survives missing optional fields', () {
      final api = CompareApi.fromJson({'id': 'x'});

      expect(api.id, 'x');
      expect(api.name, '');
      expect(api.category, 'Uncategorized');
      expect(api.trustScore, isNull);
      expect(api.trustGrade, isNull);
      expect(api.authType, 'Unknown');
      expect(api.rateLimit, 'Unknown');
      expect(api.sdkLanguages, isEmpty);
      expect(api.responseTimeMs, isNull);
      expect(api.uptime30d, isNull);
      expect(api.cors, 'Unknown');
      expect(api.https, isNull);
      expect(api.openApiAvailable, isFalse);
    });
  });

  group('ChangeFeedEvent.fromJson', () {
    test('parses trust_score_changed event with api link', () {
      final event = ChangeFeedEvent.fromJson({
        'id': 'evt-1',
        'eventType': 'trust_score_changed',
        'title': 'Alpaca API trust score changed',
        'details': {'score': 93, 'grade': 'A'},
        'createdAt': '2026-08-23T20:08:19.997Z',
        'api': {'id': 'api-1', 'slug': 'alpaca-api', 'name': 'Alpaca API'},
      });

      expect(event.eventType, 'trust_score_changed');
      expect(event.title, 'Alpaca API trust score changed');
      expect(event.apiSlug, 'alpaca-api');
      expect(event.createdAt.year, 2026);
    });

    test('survives missing api and malformed date', () {
      final event = ChangeFeedEvent.fromJson({
        'id': 'evt-2',
        'eventType': 'unknown_event',
        'title': '',
        'createdAt': 'not-a-date',
      });

      expect(event.apiSlug, isNull);
      expect(event.apiName, isNull);
      expect(event.createdAt, isA<DateTime>());
    });
  });
}
