import 'package:api_scout/app/services/ads/ads_controller.dart';
import 'package:api_scout/app/services/ads/consent_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGateway implements ConsentGateway {
  bool updateCalled = false;
  bool formCalled = false;
  bool privacyCalled = false;
  bool eligible;
  bool privacyRequired;
  bool throwOnUpdate;
  bool throwOnForm;
  int initCount = 0;

  FakeGateway({
    this.eligible = true,
    this.privacyRequired = false,
    this.throwOnUpdate = false,
    this.throwOnForm = false,
  });

  @override
  Future<void> requestUpdate() async {
    updateCalled = true;
    if (throwOnUpdate) throw StateError('no network');
  }

  @override
  Future<void> showFormIfRequired() async {
    formCalled = true;
    if (throwOnForm) throw StateError('form failed');
  }

  @override
  Future<bool> canRequestAds() async => eligible;

  @override
  Future<bool> privacyOptionsRequired() async => privacyRequired;

  @override
  Future<void> initializeAds() async {
    initCount++;
  }

  @override
  Future<void> showPrivacyOptions() async {
    privacyCalled = true;
  }
}

void main() {
  group('AdsController', () {
    test('ineligible state initializes nothing and shows no ads', () async {
      final gateway = FakeGateway(eligible: false);
      final controller = AdsController(gateway: gateway);
      await controller.ensureInitialized();
      expect(gateway.updateCalled, isTrue);
      expect(gateway.formCalled, isTrue);
      expect(gateway.initCount, 0);
      expect(controller.canShowAds, isFalse);
    });

    test('eligible state initializes ads exactly once', () async {
      final gateway = FakeGateway(eligible: true);
      final controller = AdsController(gateway: gateway);
      await controller.ensureInitialized();
      await controller.ensureInitialized();
      expect(gateway.initCount, 1);
      expect(controller.canShowAds, isTrue);
    });

    test('update failure leaves features usable with no ads', () async {
      final gateway = FakeGateway(throwOnUpdate: true);
      final controller = AdsController(gateway: gateway);
      await controller.ensureInitialized();
      expect(controller.canShowAds, isFalse);
      expect(gateway.initCount, 0);
    });

    test('form failure leaves features usable with no ads', () async {
      final gateway = FakeGateway(throwOnForm: true);
      final controller = AdsController(gateway: gateway);
      await controller.ensureInitialized();
      expect(controller.canShowAds, isFalse);
    });

    test('privacy options open re-checks eligibility', () async {
      final gateway = FakeGateway(eligible: false, privacyRequired: true);
      final controller = AdsController(gateway: gateway);
      await controller.ensureInitialized();
      expect(controller.privacyOptionsRequired, isTrue);
      gateway.eligible = true;
      await controller.openPrivacyOptions();
      expect(gateway.privacyCalled, isTrue);
      expect(controller.canShowAds, isTrue);
    });
  });
}
