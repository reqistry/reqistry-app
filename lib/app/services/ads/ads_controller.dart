import 'package:flutter/foundation.dart';

import 'ad_config.dart';
import 'consent_gateway.dart';
import 'ump_consent_gateway.dart';

/// Owns the consent-gated ads lifecycle for one launch.
///
/// Flow: request consent update → show form if required → re-check
/// [ConsentGateway.canRequestAds] → initialize the SDK at most once and
/// allow ad requests only when UMP permits. Any consent or SDK failure
/// degrades to "no ads, full features" — never an error UI, never a
/// blocked feature. The controller never equates a specific consent-form
/// choice with eligibility; UMP owns that decision.
class AdsController extends ChangeNotifier {
  AdsController({
    ConsentGateway? gateway,
    AdUnits? units,
  })  : _gateway = gateway ?? UmpConsentGateway(),
        _units = units ??
            const AdUnits(
              appId: AdConfig.testAppId,
              bannerUnitId: AdConfig.testBannerUnitId,
              nativeUnitId: AdConfig.testNativeUnitId,
            );

  final ConsentGateway _gateway;
  final AdUnits _units;

  bool _initialized = false;
  bool _canShowAds = false;
  bool _privacyOptionsRequired = false;

  /// Resolved unit IDs (test IDs unless the entrypoint passed release units).
  AdUnits get units => _units;

  /// Whether ad widgets may request and render ads right now.
  bool get canShowAds => _initialized && _canShowAds;

  /// Whether settings must show the "Privacy choices" action.
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Runs the UMP flow and initializes the SDK when permitted. Safe to
  /// call repeatedly; safe to call before configuration (no ads until
  /// both configuration and eligibility hold).
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await _gateway.requestUpdate();
      await _gateway.showFormIfRequired();
      final eligible = await _gateway.canRequestAds();
      if (eligible) {
        await _gateway.initializeAds();
        _canShowAds = true;
      } else {
        _canShowAds = false;
      }
      _privacyOptionsRequired = await _gateway.privacyOptionsRequired();
    } catch (_) {
      _canShowAds = false;
      _privacyOptionsRequired = false;
    }
    _initialized = true;
    notifyListeners();
  }

  /// Shows the privacy-options form, then re-checks eligibility. When UMP
  /// reports ineligible afterwards, ad widgets must drop loaded ads and
  /// stop requesting.
  Future<void> openPrivacyOptions() async {
    try {
      await _gateway.showPrivacyOptions();
      _canShowAds = await _gateway.canRequestAds();
    } catch (_) {
      _canShowAds = false;
    }
    notifyListeners();
  }

  /// Drops the render allowance (e.g. after eligibility flips to false).
  @visibleForTesting
  void testingSetCanShowAds(bool value) {
    _canShowAds = value;
    notifyListeners();
  }
}
