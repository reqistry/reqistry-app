import 'dart:async';

import 'package:api_scout/app/services/ads/ads_controller.dart';
import 'package:api_scout/app/services/ads/consent_gateway.dart';
import 'package:api_scout/shared/widgets/ads/ad_banner_slot.dart';
import 'package:api_scout/shared/widgets/ads/catalog_native_ad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class _DeniedGateway implements ConsentGateway {
  @override
  Future<void> requestUpdate() async {}

  @override
  Future<void> showFormIfRequired() async {}

  @override
  Future<bool> canRequestAds() async => false;

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> initializeAds() async {}

  @override
  Future<void> showPrivacyOptions() async {}
}

class _DelayedDeniedGateway extends _DeniedGateway {
  final ready = Completer<void>();

  @override
  Future<void> requestUpdate() => ready.future;
}

Future<AdsController> _deniedController() async {
  final controller = AdsController(gateway: _DeniedGateway());
  await controller.ensureInitialized();
  assert(!controller.canShowAds);
  return controller;
}

void main() {
  group('AdBannerSlot', () {
    testWidgets('collapses when ads are not allowed', (tester) async {
      final controller = await _deniedController();
      await tester.pumpWidget(
        MaterialApp(home: AdBannerSlot(controller: controller)),
      );
      await tester.pump();
      expect(find.byType(AdWidget), findsNothing);
      final slot = tester.widget<AdBannerSlot>(find.byType(AdBannerSlot));
      expect(slot, isNotNull);
    });

    testWidgets('disposes cleanly', (tester) async {
      final controller = await _deniedController();
      await tester.pumpWidget(
        MaterialApp(home: AdBannerSlot(controller: controller)),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });
  });

  group('CatalogNativeAdCard', () {
    testWidgets('waits for consent initialization before reporting unavailable',
        (tester) async {
      final gateway = _DelayedDeniedGateway();
      final controller = AdsController(gateway: gateway);
      final initialization = controller.ensureInitialized();
      var reported = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CatalogNativeAdCard(
            controller: controller,
            onUnavailable: () => reported = true,
          ),
        ),
      );
      expect(reported, isFalse);

      gateway.ready.complete();
      await initialization;
      await tester.pump();
      expect(reported, isTrue);
    });

    testWidgets('collapses and reports when ads are not allowed',
        (tester) async {
      final controller = await _deniedController();
      var reported = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CatalogNativeAdCard(
            controller: controller,
            onUnavailable: () => reported = true,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AdWidget), findsNothing);
      expect(reported, isTrue);
    });

    testWidgets('disposes cleanly', (tester) async {
      final controller = await _deniedController();
      await tester.pumpWidget(
        MaterialApp(home: CatalogNativeAdCard(controller: controller)),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });
  });
}
