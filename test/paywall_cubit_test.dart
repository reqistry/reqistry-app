import 'dart:async';
import 'dart:io';

import 'package:api_scout/app/blocs/paywall/paywall_cubit.dart';
import 'package:api_scout/app/blocs/paywall/paywall_state.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/billing/billing_service.dart';
import 'package:api_scout/app/services/fetch_api/failure.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'billing_service_test.dart' show playRows, TestStore;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('paywall_test_');
    Hive.init(hiveDirectory.path);
    HiveBoxes.localsBox = await Hive.openBox(BoxesConstants.locals);
  });

  setUp(() async {
    await HiveBoxes.localsBox.clear();
    DioClient().dio.interceptors.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  group('PaywallState.selected', () {
    const monthly = StoreProduct(
        id: 'reqistry_pro_monthly',
        price: '\$4.99',
        isYearly: false,
        basePlanId: 'monthly');
    const yearly = StoreProduct(
        id: 'reqistry_pro_yearly',
        price: '\$39.99',
        isYearly: true,
        basePlanId: 'yearly');

    test('falls back to first product without selection', () {
      const state = PaywallState(
        status: PaywallStatus.ready,
        products: [monthly, yearly],
      );
      expect(state.selected, monthly);
    });

    test('returns null without products', () {
      const state = PaywallState(status: PaywallStatus.ready);
      expect(state.selected, isNull);
    });

    test('copyWith keeps products on status change', () {
      const state = PaywallState(
        status: PaywallStatus.ready,
        products: [monthly, yearly],
        selectedId: 'reqistry_pro_yearly',
      );
      final next = state.copyWith(status: PaywallStatus.purchasing);
      expect(next.selected, yearly);
      expect(next.status, PaywallStatus.purchasing);
    });
  });

  group('PaywallCubit.isUserCancel', () {
    test('null error is a silent cancel', () {
      expect(PaywallCubit.isUserCancel(null), isTrue);
    });

    test('cancel codes stay silent', () {
      for (final code in ['user-cancelled', 'USER_CANCELED', '1']) {
        expect(
          PaywallCubit.isUserCancel(
            IAPError(source: 'billing', code: code, message: '', details: null),
          ),
          isTrue,
        );
      }
    });

    test('real errors surface', () {
      expect(
        PaywallCubit.isUserCancel(
          IAPError(
            source: 'billing',
            code: 'billing-unavailable',
            message: 'Store unreachable',
            details: null,
          ),
        ),
        isFalse,
      );
    });
  });

  group('server-authoritative purchases', () {
    test('inactive server entitlement never grants or completes Pro', () async {
      _respondToVerification({'isPro': false, 'tier': 'free'});
      final billing = _FakeBilling();
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add(_purchase(PurchaseStatus.purchased));
      await _settle();

      expect(cubit.state.isPro, isFalse);
      expect(HiveBoxes.localsBox.get(PaywallCubit.proActiveKey), isNot(true));
      expect(billing.completed, isEmpty);
      await cubit.close();
    });

    test('email-required server denial stays free and does not complete',
        () async {
      _denyVerification('email required', code: FailureCode.emailRequired);
      final billing = _FakeBilling();
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add(_purchase(PurchaseStatus.purchased));
      await _settle();

      expect(cubit.state.isPro, isFalse);
      expect(cubit.state.verifyEmailRequired, isTrue);
      expect(billing.completed, isEmpty);
      await cubit.close();
    });

    test('verification failure never grants or completes Pro', () async {
      _denyVerification('verification unavailable');
      final billing = _FakeBilling();
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add(_purchase(PurchaseStatus.purchased));
      await _settle();

      expect(cubit.state.isPro, isFalse);
      expect(cubit.state.verifyEmailRequired, isFalse);
      expect(billing.completed, isEmpty);
      await cubit.close();
    });

    test('pending and cancelled purchases never verify, grant, or complete',
        () async {
      var verificationRequests = 0;
      DioClient().dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/v1/billing/verify')) {
            verificationRequests++;
          }
          handler.resolve(Response(
            requestOptions: options,
            data: {'isPro': true, 'tier': 'pro'},
          ));
        },
      ));
      final billing = _FakeBilling();
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add([
        _purchase(PurchaseStatus.pending),
        _purchase(PurchaseStatus.canceled),
      ]);
      await _settle();

      expect(cubit.state.isPro, isFalse);
      expect(verificationRequests, 0);
      expect(billing.completed, isEmpty);
      await cubit.close();
    });

    test('pending transaction completes only after active server response',
        () async {
      final events = <String>[];
      final completion = Completer<void>();
      _respondToVerification(
        {'isPro': true, 'tier': 'pro'},
        onRequest: () => events.add('verify'),
      );
      final billing = _FakeBilling(
        onComplete: () {
          events.add('complete');
          completion.complete();
        },
      );
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add(_purchase(PurchaseStatus.purchased));
      await completion.future.timeout(const Duration(seconds: 1));
      await _settle();

      expect(events, ['verify', 'complete']);
      expect(cubit.state.isPro, isTrue);
      expect(billing.completed, hasLength(1));
      await cubit.close();
    });
  });

  test('cached metadata never grants before inactive server entitlement',
      () async {
    await HiveBoxes.localsBox.put(PaywallCubit.proActiveKey, true);
    _respondToVerification({'isPro': false, 'tier': 'free'});
    final cubit = PaywallCubit(billing: _FakeBilling());

    expect(cubit.state.isPro, isFalse);
    await cubit.syncEntitlement();
    expect(cubit.state.isPro, isFalse);
    await cubit.close();
  });

  test('account clearing removes all Pro metadata before returning', () async {
    await HiveBoxes.localsBox.put(PaywallCubit.proActiveKey, true);
    await HiveBoxes.localsBox
        .put(PaywallCubit.proProductKey, BillingService.monthlyProductId);
    await HiveBoxes.localsBox
        .put(PaywallCubit.proSinceKey, '2026-09-06T00:00:00Z');

    await PaywallCubit.clearLocalEntitlement();

    expect(HiveBoxes.localsBox.get(PaywallCubit.proActiveKey), isNull);
    expect(HiveBoxes.localsBox.get(PaywallCubit.proProductKey), isNull);
    expect(HiveBoxes.localsBox.get(PaywallCubit.proSinceKey), isNull);
  });

  group('purchases gate and fresh entitlement refresh', () {
    test('buy refreshes entitlements immediately before launching', () async {
      final events = <String>[];
      DioClient().dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/v1/billing/entitlements')) {
            events.add('entitlements');
            handler.resolve(Response(requestOptions: options, data: {
              'data': {
                'isPro': false,
                'tier': 'free',
                'purchasesEnabled': true
                , 'billingAccountId': events.where((event) => event == 'entitlements').length == 1 ? 'old-fixture-id' : 'fresh-fixture-id'
              },
            }));
            return;
          }
          handler.resolve(Response(
              requestOptions: options, data: {'isPro': false, 'tier': 'free'}));
        },
      ));
      final billing = _FakeBilling(
        onBuy: () => events.add('buy'),
        onQuery: () => events.add('products'),
      );
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      expect(events, ['entitlements', 'products']);

      await cubit.buy();
      await _settle();

      expect(events,
          ['entitlements', 'products', 'products', 'entitlements', 'buy']);
      expect(billing.launched, hasLength(1));
      expect(billing.accountIds.single == 'fresh-fixture-id', isTrue);
      await cubit.close();
    });

    test('selected state exposes actual base-plan evidence and store prices', () async {
      _respondToVerification({'purchasesEnabled': true});
      final cubit = PaywallCubit(billing: _FakeBilling());
      await _settle();
      expect(cubit.state.selected?.basePlanId, 'monthly');
      expect(cubit.state.selected?.price, '7,49 EUR');
      await cubit.close();
    });

    for (final accountId in [null, '', '   ']) {
      test('fresh missing or blank account blocks buy (${accountId?.length})', () async {
        _respondToVerification({'purchasesEnabled': true, 'billingAccountId': accountId});
        final billing = _FakeBilling();
        final cubit = PaywallCubit(billing: billing);
        await _settle();
        await cubit.buy();
        expect(billing.launched, isEmpty);
        expect(cubit.state.status, PaywallStatus.ready);
        await cubit.close();
      });
    }

    test('duplicate plugin rows surface load error', () async {
      _respondToVerification({'purchasesEnabled': true});
      final service = BillingService(store: TestStore([
        ...playRows(BillingService.monthlyProductId, 'monthly', count: 2),
        ...playRows(BillingService.yearlyProductId, 'yearly'),
      ]));
      final cubit = PaywallCubit(billing: _FakeBilling(onQuery: () {}, query: service.queryProducts));
      await _settle();
      expect(cubit.state.status, PaywallStatus.loadError);
      await cubit.close();
    });

    test('buy is blocked when purchasesEnabled is false', () async {
      var entitlementsFetches = 0;
      DioClient().dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/v1/billing/entitlements')) {
            entitlementsFetches++;
            handler.resolve(Response(requestOptions: options, data: {
              'data': {
                'isPro': false,
                'tier': 'free',
                'purchasesEnabled': false,
              },
            }));
            return;
          }
          handler.resolve(Response(
              requestOptions: options, data: {'isPro': false, 'tier': 'free'}));
        },
      ));
      final billing = _FakeBilling();
      final cubit = PaywallCubit(billing: billing);
      await _settle();
      expect(entitlementsFetches, 1);

      await cubit.buy();
      await _settle();

      expect(entitlementsFetches, 2);
      expect(billing.launched, isEmpty);
      expect(cubit.state.status, PaywallStatus.ready);
      expect(cubit.state.purchasesEnabled, isFalse);
      await cubit.close();
    });

    test('verify surfaces typed upgrade_required failure code', () async {
      DioClient().dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 402,
              data: {
                'error': 'Update required before purchasing',
                'code': 'upgrade_required',
              },
            ),
            type: DioExceptionType.badResponse,
          ));
        },
      ));

      await expectLater(
        RemoteService.verifyPlayPurchase(purchaseToken: 'token'),
        throwsA(isA<Failure>()
            .having((f) => f.code, 'code', FailureCode.upgradeRequired)),
      );
    });

    test('upgrade_required is not mistaken for email_required', () async {
      DioClient().dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 402,
              data: {'error': 'Update required', 'code': 'upgrade_required'},
            ),
            type: DioExceptionType.badResponse,
          ));
        },
      ));
      final billing = _FakeBilling();
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add(_purchase(PurchaseStatus.purchased));
      await _settle();

      expect(cubit.state.isPro, isFalse);
      expect(cubit.state.verifyEmailRequired, isFalse);
      expect(billing.completed, isEmpty);
      await cubit.close();
    });
  });
}

void _respondToVerification(
  Map<String, dynamic> data, {
  void Function()? onRequest,
}) {
  DioClient().dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path.contains('/v1/billing/verify')) {
        onRequest?.call();
      }
      handler.resolve(Response(requestOptions: options, data: data));
    },
  ));
}

void _denyVerification(String error, {String? code}) {
  DioClient().dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 402,
          data: {'error': error, if (code != null) 'code': code},
        ),
        type: DioExceptionType.badResponse,
      ));
    },
  ));
}

PurchaseDetails _purchase(PurchaseStatus status) {
  final purchase = PurchaseDetails(
    productID: BillingService.monthlyProductId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local-token',
      serverVerificationData: 'server-token',
      source: 'test',
    ),
    transactionDate: '1',
    status: status,
  );
  purchase.pendingCompletePurchase = true;
  return purchase;
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

class _FakeBilling extends BillingService {
  _FakeBilling({this.onComplete, this.onBuy, this.onQuery, this.query});

  final Future<List<ProductDetails>> Function()? query;
  final accountIds = <String>[];

  final void Function()? onComplete;
  final void Function()? onBuy;
  final void Function()? onQuery;
  final completed = <PurchaseDetails>[];
  final launched = <ProductDetails>[];
  final _purchases = StreamController<List<PurchaseDetails>>.broadcast();

  void add(Object purchase) {
    _purchases.add(purchase is PurchaseDetails
        ? [purchase]
        : purchase as List<PurchaseDetails>);
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<ProductDetails>> queryProducts() async {
    onQuery?.call();
    if (query != null) return query!();
    return playRows(BillingService.monthlyProductId, 'monthly');
  }

  @override
  Future<bool> buy(ProductDetails product, {String billingAccountId = ''}) async {
    accountIds.add(billingAccountId);
    onBuy?.call();
    launched.add(product);
    return true;
  }

  @override
  StreamSubscription<List<PurchaseDetails>> listen(
    void Function(List<PurchaseDetails>) onData,
  ) =>
      _purchases.stream.listen(onData);

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    onComplete?.call();
    completed.add(purchase);
  }

  @override
  Future<void> restore() async {}

  @override
  Future<void> dispose() => _purchases.close();
}
