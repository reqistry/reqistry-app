import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// Thin wrapper over the Play/App Store billing SDK.
///
/// Only file allowed to touch `in_app_purchase`. Everything else talks to
/// [PaywallCubit]. Prices always come from the store, never hardcoded.
class BillingService {
  BillingService({InAppPurchase? store}) : _providedStore = store;

  static const monthlyProductId = 'reqistry_pro_monthly';
  static const yearlyProductId = 'reqistry_pro_yearly';

  static const productIds = {monthlyProductId, yearlyProductId};

  final InAppPurchase? _providedStore;
  InAppPurchase get _store => _providedStore ?? InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<bool> isAvailable() {
    try {
      return _store.isAvailable();
    } catch (_) {
      return Future.value(false);
    }
  }

  Future<List<ProductDetails>> queryProducts() async {
    final response = await _store.queryProductDetails(productIds);
    final rows = response.productDetails;
    // Strict one-regular-offer-per-product policy: exactly one GooglePlay
    // row per product where basePlan matches expectation and offerId == null.
    // Any missing, duplicate, cross-pair, or promo offer fails closed.
    final selected = <String, ProductDetails>{};
    for (final product in rows) {
      final expBasePlan = _expectedBasePlan(product.id);
      if (expBasePlan == null) {
        // Unknown product id - fail closed if any unexpected product present.
        throw StateError('unexpected product ${product.id}');
      }
      final details = _basePlanAndOffer(product);
      if (details == null) {
        // Non-GooglePlay or missing offer details - treat as invalid for subs.
        throw StateError('missing offer details for ${product.id}');
      }
      if (details.offerId != null) {
        throw StateError('promotional offer not allowed for ${product.id}');
      }
      if (details.basePlanId != expBasePlan) {
        throw StateError(
            'basePlan mismatch for ${product.id}: ${details.basePlanId}');
      }
      if (selected.containsKey(product.id)) {
        throw StateError('duplicate regular offer for ${product.id}');
      }
      selected[product.id] = product;
    }
    if (selected.length != productIds.length) {
      throw StateError(
          'missing product: expected $productIds got ${selected.keys}');
    }
    // Stable order monthly first.
    return [selected[monthlyProductId]!, selected[yearlyProductId]!];
  }

  /// Starts the native purchase sheet. Result arrives on [purchaseStream].
  Future<bool> buy(ProductDetails product, {String billingAccountId = ''}) {
    final trimmed = billingAccountId.trim();
    if (trimmed.isEmpty) return Future.value(false);
    final offerToken =
        product is GooglePlayProductDetails ? product.offerToken : null;
    final param = GooglePlayPurchaseParam(
      productDetails: product,
      applicationUserName: trimmed,
      offerToken: offerToken,
    );
    return _store.buyNonConsumable(purchaseParam: param);
  }

  static String? _expectedBasePlan(String productId) {
    if (productId == monthlyProductId) return 'monthly';
    if (productId == yearlyProductId) return 'yearly';
    return null;
  }

  static SubscriptionOfferDetailsWrapper? basePlanDetails(
          ProductDetails product) =>
      _basePlanAndOffer(product);

  static SubscriptionOfferDetailsWrapper? _basePlanAndOffer(
      ProductDetails product) {
    if (product is GooglePlayProductDetails) {
      final idx = product.subscriptionIndex;
      final wrapper = product.productDetails;
      if (idx == null || wrapper.subscriptionOfferDetails == null) {
        return null;
      }
      if (idx < 0 || idx >= wrapper.subscriptionOfferDetails!.length) {
        return null;
      }
      return wrapper.subscriptionOfferDetails![idx];
    }
    return null;
  }

  /// Replays past purchases onto [purchaseStream] (reinstalls, new devices).
  Future<void> restore() => _store.restorePurchases();

  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _store.completePurchase(purchase);

  /// Listens for purchases; returns the subscription to cancel on close.
  StreamSubscription<List<PurchaseDetails>> listen(
    void Function(List<PurchaseDetails>) onData,
  ) {
    _subscription?.cancel();
    _subscription = purchaseStream.listen(onData);
    return _subscription!;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
