// ignore: depend_on_referenced_packages
import 'package:api_scout/app/services/billing/billing_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

List<GooglePlayProductDetails> playRows(String id, String basePlan,
    {int count = 1, String? offerId, String price = '7,49 EUR'}) {
  return GooglePlayProductDetails.fromProductDetails(ProductDetailsWrapper(
    description: 'Test subscription',
    name: 'Test subscription',
    productId: id,
    productType: ProductType.subs,
    title: 'Test subscription',
    subscriptionOfferDetails: [
      for (var index = 0; index < count; index++)
        SubscriptionOfferDetailsWrapper(
          basePlanId: basePlan,
          offerId: offerId,
          offerTags: const [],
          offerIdToken: 'fixture-$basePlan-$index',
          pricingPhases: [
            PricingPhaseWrapper(
              billingCycleCount: 0,
              billingPeriod: basePlan == 'monthly' ? 'P1M' : 'P1Y',
              formattedPrice: price,
              priceAmountMicros: 7490000,
              priceCurrencyCode: 'EUR',
              recurrenceMode: RecurrenceMode.infiniteRecurring,
            ),
          ],
        ),
    ],
  ));
}

class TestStore implements InAppPurchase {
  TestStore(this.rows);
  final List<ProductDetails> rows;
  final launched = <PurchaseParam>[];

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async =>
      ProductDetailsResponse(productDetails: rows, notFoundIDs: const []);

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    launched.add(purchaseParam);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError('Unexpected store call');
}

void main() {
  final monthly = playRows(BillingService.monthlyProductId, 'monthly').single;
  final yearly = playRows(BillingService.yearlyProductId, 'yearly', price: '69,99 EUR').single;

  test('exact regular rows keep localized prices and purchase offer token', () async {
    final store = TestStore([yearly, monthly]);
    final service = BillingService(store: store);
    final products = await service.queryProducts();
    expect(identical(products[0], monthly), isTrue);
    expect(identical(products[1], yearly), isTrue);
    expect(products.map((row) => row.price), ['7,49 EUR', '69,99 EUR']);
    for (final row in products) {
      await service.buy(row, billingAccountId: 'fixture-server-opaque-id');
      final param = store.launched.last;
      expect(param, isA<GooglePlayPurchaseParam>());
      expect(identical(param.productDetails, row), isTrue);
      expect(param.applicationUserName == 'fixture-server-opaque-id', isTrue);
      expect((param as GooglePlayPurchaseParam).offerToken == (row as GooglePlayProductDetails).offerToken, isTrue);
    }
  });

  for (final id in ['', '   ']) {
    test('empty account never launches billing (${id.length})', () async {
      final store = TestStore([monthly, yearly]);
      final service = BillingService(store: store);
      expect(await service.buy(monthly, billingAccountId: id), isFalse);
      expect(store.launched, isEmpty);
    });
  }

  final invalid = <String, List<ProductDetails>>{
    'missing monthly': [yearly],
    'missing yearly': [monthly],
    'monthly cross-pair': [...playRows(BillingService.monthlyProductId, 'yearly'), yearly],
    'yearly cross-pair': [monthly, ...playRows(BillingService.yearlyProductId, 'monthly')],
    'duplicate monthly regular rows': [...playRows(BillingService.monthlyProductId, 'monthly', count: 2), yearly],
    'duplicate yearly regular rows': [monthly, ...playRows(BillingService.yearlyProductId, 'yearly', count: 2)],
    'extra promotional row': [monthly, yearly, ...playRows(BillingService.monthlyProductId, 'monthly', offerId: 'promo')],
    'promotional row only': [...playRows(BillingService.monthlyProductId, 'monthly', offerId: 'promo'), yearly],
    'extra base plan': [monthly, yearly, ...playRows(BillingService.monthlyProductId, 'other')],
  };
  for (final entry in invalid.entries) {
    test('rejects ${entry.key}', () async {
      final service = BillingService(store: TestStore(entry.value));
      await expectLater(service.queryProducts(), throwsStateError);
    });
  }
}
