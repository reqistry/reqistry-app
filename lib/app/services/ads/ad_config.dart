/// Resolved AdMob identifiers for one launch.
class AdUnits {
  const AdUnits({
    required this.appId,
    required this.bannerUnitId,
    required this.nativeUnitId,
  });

  final String appId;
  final String bannerUnitId;
  final String nativeUnitId;
}

/// AdMob identifier policy.
///
/// Debug, profile, and widget tests always use the official Google sample
/// IDs so no real inventory is ever touched outside release builds.
/// Release builds fail fast when production IDs are missing or still set
/// to the sample values.
class AdConfig {
  AdConfig._();

  static const testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const testBannerUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const testNativeUnitId = 'ca-app-pub-3940256099942544/2247696110';

  static bool _isTestId(String value) =>
      value == testAppId ||
      value == testBannerUnitId ||
      value == testNativeUnitId;

  static AdUnits resolve({
    required bool isRelease,
    required String appId,
    required String bannerUnitId,
    required String nativeUnitId,
  }) {
    if (!isRelease) {
      return const AdUnits(
        appId: testAppId,
        bannerUnitId: testBannerUnitId,
        nativeUnitId: testNativeUnitId,
      );
    }
    for (final value in [appId, bannerUnitId, nativeUnitId]) {
      if (value.trim().isEmpty) {
        throw StateError('Missing production AdMob ID');
      }
      if (_isTestId(value.trim())) {
        throw StateError('Sample AdMob ID in release build');
      }
    }
    return AdUnits(
      appId: appId.trim(),
      bannerUnitId: bannerUnitId.trim(),
      nativeUnitId: nativeUnitId.trim(),
    );
  }
}
