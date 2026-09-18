import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_gateway.dart';

/// UMP + Mobile Ads implementation of [ConsentGateway].
class UmpConsentGateway implements ConsentGateway {
  @override
  Future<void> requestUpdate() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        if (!completer.isCompleted) {
          completer.completeError(
              StateError('UMP ${error.errorCode}: ${error.message}'));
        }
      },
    );
    return completer.future;
  }

  @override
  Future<void> showFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired(
      (formError) {
        if (formError != null) {
          if (!completer.isCompleted) {
            completer.completeError(StateError(
                'UMP form ${formError.errorCode}: ${formError.message}'));
          }
          return;
        }
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<bool> privacyOptionsRequired() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> initializeAds() async {
    await MobileAds.instance.initialize();
  }

  @override
  Future<void> showPrivacyOptions() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm(
      (formError) {
        if (formError != null) {
          if (!completer.isCompleted) {
            completer.completeError(StateError(
                'UMP form ${formError.errorCode}: ${formError.message}'));
          }
          return;
        }
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }
}
