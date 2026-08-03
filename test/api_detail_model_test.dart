import 'package:api_scout/app/data/models/api.dart' as legacy;
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API detail facts', () {
    test('unknown legacy booleans are not presented as confirmed false', () {
      final detail = ApiDetail.fromApi(
        legacy.Api(
          id: 'api-1',
          name: 'Example API',
          description: 'Example data',
          auth: '',
          https: false,
          cors: false,
          link: 'https://example.com/v1',
          categoryId: 'Development',
        ),
      );

      expect(detail.capabilities.https, isNull);
      expect(detail.capabilities.cors, CorsSupport.unknown);
      expect(detail.access.authType, ApiAuthType.unknown);
      expect(detail.health.status, ApiHealthStatus.unknown);
    });

    test('health mapping is based on transparent observations', () {
      final checkedAt = DateTime.now();

      expect(
        mapHealthStatus(
          isAlive: true,
          statusCode: 401,
          responseTimeMs: 120,
          checkedAt: checkedAt,
        ),
        ApiHealthStatus.authenticationRequired,
      );
      expect(
        mapHealthStatus(
          isAlive: true,
          statusCode: 429,
          responseTimeMs: 120,
          checkedAt: checkedAt,
        ),
        ApiHealthStatus.rateLimited,
      );
      expect(
        mapHealthStatus(
          isAlive: true,
          statusCode: 200,
          responseTimeMs: 1482,
          checkedAt: checkedAt,
        ),
        ApiHealthStatus.degraded,
      );
      expect(
        mapHealthStatus(
          isAlive: false,
          statusCode: 503,
          responseTimeMs: null,
          checkedAt: checkedAt,
        ),
        ApiHealthStatus.unavailable,
      );
    });

    test('cache JSON preserves nullable and verification fields', () {
      final original = ApiDetail.fromApi(
        legacy.Api(
          id: 'api-1',
          slug: 'example-api',
          name: 'Example API',
          description: 'Example data',
          auth: 'None',
          https: true,
          cors: false,
          corsStatus: 'Unknown',
          link: 'https://example.com/v1',
          categoryId: 'Development',
          pricing: 'Free',
        ),
      );

      final restored = ApiDetail.fromJson(original.toJson());

      expect(restored, original);
      expect(restored.verification.length, 4);
    });
  });
}
