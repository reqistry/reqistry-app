/// Minimal consent + SDK-initialization surface. The production
/// implementation delegates to UMP and Mobile Ads; tests inject fakes.
abstract class ConsentGateway {
  /// Requests fresh consent info (every launch).
  Future<void> requestUpdate();

  /// Shows the consent form when the SDK requires it.
  Future<void> showFormIfRequired();

  /// UMP's verdict: only true may trigger ad requests.
  Future<bool> canRequestAds();

  /// Whether the settings "Privacy choices" entry point is required.
  Future<bool> privacyOptionsRequired();

  /// Initializes the Mobile Ads SDK (at most once per launch).
  Future<void> initializeAds();

  /// Shows the privacy-options form.
  Future<void> showPrivacyOptions();
}
