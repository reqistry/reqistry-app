import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:api_scout/app/blocs/paywall/paywall_state.dart';
import 'package:api_scout/app/data/models/pro.dart';
import 'package:api_scout/app/services/billing/billing_service.dart';
import 'package:api_scout/app/services/fetch_api/failure.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Paywall + server-authoritative Pro entitlement.
typedef PurchaseVerifier = Future<Entitlements> Function({
  required String purchaseToken,
  String? productId,
});

class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit({
    BillingService? billing,
    LocalsDB? locals,
    PurchaseVerifier? verifyPurchase,
  })  : _billing = billing ?? BillingService(),
        _locals = locals ?? LocalsDB.instance,
        _verifyPurchase = verifyPurchase ?? RemoteService.verifyPlayPurchase,
        super(const PaywallState()) {
    _purchaseSub = _billing.listen(_onPurchases);
    loadProducts();
  }

  static const proActiveKey = 'proActive';
  static const proProductKey = 'proProductId';
  static const proSinceKey = 'proSince';

  final BillingService _billing;
  final LocalsDB _locals;
  final PurchaseVerifier _verifyPurchase;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSub;
  Timer? _restoreTimer;
  Future<void> _identityReset = Future.value();

  bool get isPro => state.isPro;

  /// Drops the local Pro grant on sign-out/account switch. Server remains
  /// source of truth; the next sync re-adopts it for the new identity.
  static Future<void> clearLocalEntitlement() async {
    await _clearEntitlement(LocalsDB.instance);
  }

  Future<void> clearEntitlement() {
    if (!isClosed) {
      emit(state.copyWith(
        status: state.products.isEmpty
            ? PaywallStatus.initial
            : PaywallStatus.ready,
        isPro: false,
        verifyEmailRequired: false,
        purchasesEnabled: false,
      ));
    }
    return _identityReset = _clearEntitlement(_locals);
  }

  static Future<void> _clearEntitlement(LocalsDB locals) async {
    await Future.wait([
      locals.deleteWithKey(proActiveKey),
      locals.deleteWithKey(proProductKey),
      locals.deleteWithKey(proSinceKey),
    ]);
  }

  Future<void> loadProducts({AppLocalizations? l10n}) async {
    emit(state.copyWith(status: PaywallStatus.loading, errorMessage: ''));
    try {
      await _refreshEntitlements();
      if (isClosed) return;
      if (!await _billing.isAvailable()) {
        emit(state.copyWith(status: PaywallStatus.unavailable));
        return;
      }
      final found = await _billing.queryProducts();
      if (isClosed) return;
      if (found.isEmpty) {
        emit(state.copyWith(
          status: PaywallStatus.loadError,
          errorMessage: l10n?.paywallLoadError ?? 'Could not load plans.',
        ));
        return;
      }
      final products = [
        for (final product in found)
          StoreProduct(
            id: product.id,
            price: product.price,
            isYearly: product.id == BillingService.yearlyProductId,
            basePlanId: BillingService.basePlanDetails(product)?.basePlanId ??
                (product.id == BillingService.yearlyProductId
                    ? 'yearly'
                    : 'monthly'),
          ),
      ];
      final yearly = products.where((p) => p.isYearly);
      emit(state.copyWith(
        status: PaywallStatus.ready,
        products: products,
        selectedId: yearly.isNotEmpty ? yearly.first.id : products.first.id,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: PaywallStatus.loadError,
        errorMessage: l10n?.paywallLoadError ?? 'Could not load plans.',
      ));
    }
  }

  void selectPlan(String id) {
    if (state.status != PaywallStatus.ready) return;
    emit(state.copyWith(selectedId: id));
  }

  /// Starts the native purchase sheet. Outcome arrives on the purchase
  /// stream; user cancellation returns silently to ready.
  Future<void> buy({AppLocalizations? l10n}) async {
    final product = state.selected;
    if (product == null || state.status != PaywallStatus.ready) return;
    emit(state.copyWith(status: PaywallStatus.purchasing, errorMessage: ''));
    try {
      final details = await _billingDetails(product.id);
      if (details == null) {
        throw StateError('product missing');
      }
      final entitlements = await _refreshEntitlements();
      if (isClosed) return;
      if (!(entitlements?.purchasesEnabled ?? false)) {
        emit(state.copyWith(status: PaywallStatus.ready));
        return;
      }
      final accountId = entitlements?.billingAccountId.trim() ?? '';
      if (accountId.isEmpty) {
        emit(state.copyWith(status: PaywallStatus.ready));
        return;
      }
      final launched = await _billing.buy(details, billingAccountId: accountId);
      if (!launched && !isClosed) {
        emit(state.copyWith(status: PaywallStatus.ready));
        AppSnackBarHelper.show(
          title: l10n?.stateError ?? 'Error',
          message: l10n?.stateSomethingWentWrong ?? 'Something went wrong',
          isError: true,
        );
      }
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(status: PaywallStatus.ready));
      AppSnackBarHelper.show(
        title: l10n?.stateError ?? 'Error',
        message: l10n?.stateSomethingWentWrong ?? 'Something went wrong',
        isError: true,
      );
    }
  }

  Future<void> restore(
      {AppLocalizations? l10n, bool notifyEmpty = true}) async {
    if (state.isRestoring) return;
    emit(state.copyWith(isRestoring: true));
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 8), () {
      if (isClosed || !state.isRestoring || state.isPro) return;
      emit(state.copyWith(isRestoring: false));
      if (!notifyEmpty) return;
      AppSnackBarHelper.show(
        title: l10n?.paywallRestore ?? 'Restore purchases',
        message: l10n?.paywallRestoreEmpty ?? 'No purchases found.',
      );
    });
    try {
      await _billing.restore();
    } catch (_) {
      _restoreTimer?.cancel();
      if (isClosed) return;
      emit(state.copyWith(isRestoring: false));
      AppSnackBarHelper.show(
        title: l10n?.stateError ?? 'Error',
        message: l10n?.paywallLoadError ?? 'Could not load plans.',
        isError: true,
      );
    }
  }

  /// Refreshes server truth, then silently replays store-side changes.
  Future<void> syncEntitlement() async {
    final entitlements = await _refreshEntitlements();
    if (isClosed) return;
    if (entitlements != null) {
      try {
        await _locals.putWithKey(proActiveKey, entitlements.isPro);
        if (entitlements.isPro != state.isPro ||
            (entitlements.isPro && state.verifyEmailRequired)) {
          emit(state.copyWith(
            isPro: entitlements.isPro,
            verifyEmailRequired: false,
          ));
        }
      } catch (_) {}
    }
    try {
      await _billing.restore();
    } catch (_) {}
  }

  /// Fetches current entitlements and mirrors the server purchases gate.
  Future<Entitlements?> _refreshEntitlements() async {
    try {
      await _identityReset;
      if (isClosed) return null;
      final entitlements = await RemoteService.getEntitlements();
      if (isClosed) return null;
      emit(state.copyWith(
          purchasesEnabled: entitlements?.purchasesEnabled ?? false));
      return entitlements;
    } catch (_) {
      if (!isClosed) emit(state.copyWith(purchasesEnabled: false));
      return null;
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPro(purchase);
        case PurchaseStatus.error:
          // A cancelled native sheet must always land back on ready —
          // otherwise the spinner sticks with Close disabled and traps
          // the user. Real errors surface the error state instead.
          if (isClosed) break;
          _restoreTimer?.cancel();
          if (isUserCancel(purchase.error)) {
            if (state.status == PaywallStatus.purchasing) {
              emit(state.copyWith(
                  status: PaywallStatus.ready, isRestoring: false));
            }
          } else {
            emit(state.copyWith(
              status: state.products.isEmpty
                  ? PaywallStatus.loadError
                  : PaywallStatus.ready,
              isRestoring: false,
            ));
          }
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          if (!isClosed && state.status == PaywallStatus.purchasing) {
            emit(state.copyWith(status: PaywallStatus.ready));
          }
      }
    }
  }

  Future<void> _grantPro(PurchaseDetails purchase) async {
    if (!BillingService.productIds.contains(purchase.productID)) return;
    final purchaseToken =
        purchase.verificationData.serverVerificationData.trim();
    if (purchaseToken.isEmpty) return;
    Entitlements entitlements;
    try {
      entitlements = await _verifyPurchase(
        purchaseToken: purchaseToken,
        productId: purchase.productID,
      );
    } catch (e) {
      if (isClosed) return;
      _restoreTimer?.cancel();
      emit(state.copyWith(
        status: PaywallStatus.ready,
        isRestoring: false,
        verifyEmailRequired:
            e is Failure && e.code == FailureCode.emailRequired,
      ));
      return;
    }
    if (!entitlements.isPro) {
      await _clearEntitlement(_locals);
      if (!isClosed) {
        _restoreTimer?.cancel();
        emit(state.copyWith(
          status: PaywallStatus.ready,
          isPro: false,
          isRestoring: false,
          verifyEmailRequired: false,
        ));
      }
      return;
    }
    await _locals.putWithKey(proActiveKey, true);
    await _locals.putWithKey(proProductKey, purchase.productID);
    await _locals.putWithKey(proSinceKey, DateTime.now().toIso8601String());
    if (purchase.pendingCompletePurchase) {
      try {
        await _billing.completePurchase(purchase);
      } catch (_) {}
    }
    if (isClosed) return;
    _restoreTimer?.cancel();
    emit(state.copyWith(
      status: PaywallStatus.success,
      isPro: true,
      isRestoring: false,
      errorMessage: '',
      verifyEmailRequired: false,
    ));
  }

  Future<ProductDetails?> _billingDetails(String id) async {
    final found = await _billing.queryProducts();
    for (final product in found) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// Store-cancelled purchases return to ready silently (docs: quota-gated
  /// prompts must never error-shame a cancel).
  @visibleForTesting
  static bool isUserCancel(IAPError? error) {
    if (error == null) return true;
    final code = error.code.toLowerCase();
    final message = error.message.toLowerCase();
    return code.contains('cancel') || code == '1' || message.contains('cancel');
  }

  @override
  Future<void> close() {
    _restoreTimer?.cancel();
    _purchaseSub.cancel();
    _billing.dispose();
    return super.close();
  }
}
