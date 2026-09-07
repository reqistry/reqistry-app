import 'dart:async';
import 'dart:io';

import 'package:api_scout/app/blocs/paywall/paywall_cubit.dart';
import 'package:api_scout/app/blocs/paywall/paywall_state.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/billing/billing_service.dart';
import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
        id: 'reqistry_pro_monthly', price: '\$4.99', isYearly: false);
    const yearly = StoreProduct(
        id: 'reqistry_pro_yearly', price: '\$39.99', isYearly: true);

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
      _denyVerification('email required');
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
          verificationRequests++;
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
      _respondToVerification(
        {'isPro': true, 'tier': 'pro'},
        onRequest: () => events.add('verify'),
      );
      final billing = _FakeBilling(onComplete: () => events.add('complete'));
      final cubit = PaywallCubit(billing: billing);
      await _settle();

      billing.add(_purchase(PurchaseStatus.purchased));
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
}

void _respondToVerification(
  Map<String, dynamic> data, {
  void Function()? onRequest,
}) {
  DioClient().dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      onRequest?.call();
      handler.resolve(Response(requestOptions: options, data: data));
    },
  ));
}

void _denyVerification(String error) {
  DioClient().dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 402,
          data: {'error': error},
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
  _FakeBilling({this.onComplete});

  final void Function()? onComplete;
  final completed = <PurchaseDetails>[];
  final _purchases = StreamController<List<PurchaseDetails>>.broadcast();

  void add(Object purchase) {
    _purchases.add(purchase is PurchaseDetails
        ? [purchase]
        : purchase as List<PurchaseDetails>);
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<ProductDetails>> queryProducts() async => [
        ProductDetails(
          id: BillingService.monthlyProductId,
          title: 'Monthly',
          description: 'Monthly Pro',
          price: r'$4.99',
          rawPrice: 4.99,
          currencyCode: 'USD',
        ),
      ];

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
