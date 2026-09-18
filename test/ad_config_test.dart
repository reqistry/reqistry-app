import 'package:api_scout/app/services/ads/ad_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdConfig.resolve', () {
    test('non-release always uses official test IDs', () {
      final units = AdConfig.resolve(
        isRelease: false,
        appId: 'ca-app-pub-123~prod',
        bannerUnitId: 'ca-app-pub-123/prod-banner',
        nativeUnitId: 'ca-app-pub-123/prod-native',
      );
      expect(units.appId, AdConfig.testAppId);
      expect(units.bannerUnitId, AdConfig.testBannerUnitId);
      expect(units.nativeUnitId, AdConfig.testNativeUnitId);
    });

    test('non-release with missing values still uses test IDs', () {
      final units = AdConfig.resolve(
        isRelease: false,
        appId: '',
        bannerUnitId: '',
        nativeUnitId: '',
      );
      expect(units.appId, AdConfig.testAppId);
    });

    test('release accepts real production IDs', () {
      final units = AdConfig.resolve(
        isRelease: true,
        appId: 'ca-app-pub-123~456',
        bannerUnitId: 'ca-app-pub-123/789',
        nativeUnitId: 'ca-app-pub-123/012',
      );
      expect(units.appId, 'ca-app-pub-123~456');
    });

    test('release rejects missing IDs', () {
      expect(
        () => AdConfig.resolve(
          isRelease: true,
          appId: '',
          bannerUnitId: 'ca-app-pub-123/789',
          nativeUnitId: 'ca-app-pub-123/012',
        ),
        throwsStateError,
      );
    });

    test('release rejects test IDs', () {
      expect(
        () => AdConfig.resolve(
          isRelease: true,
          appId: AdConfig.testAppId,
          bannerUnitId: AdConfig.testBannerUnitId,
          nativeUnitId: AdConfig.testNativeUnitId,
        ),
        throwsStateError,
      );
    });
  });
}
