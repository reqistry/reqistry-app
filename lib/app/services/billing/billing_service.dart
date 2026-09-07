import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

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
    final found = {for (final p in response.productDetails) p.id: p};
    // Stable order: monthly first, yearly second; drop unknown ids.
    return [
      for (final id in [monthlyProductId, yearlyProductId])
        if (found.containsKey(id)) found[id]!,
    ];
  }

  /// Starts the native purchase sheet. Result arrives on [purchaseStream].
  Future<bool> buy(ProductDetails product) {
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
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
