import 'dart:async';

import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('build header options derive from the integer build number', () {
    expect(DioClient.buildHeadersFor(42), {'X-Reqistry-App-Build': '42'});
  });

  test('both Dio clients carry the build header on every request', () async {
    final platformReply = Completer<Map<String, Object>>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/package_info'),
            (_) => platformReply.future);
    final client = DioClient();
    final buildReady = client.resolveBuildNumber();
    for (final dio in [client.dio, client.unauthDio]) {
      dio.interceptors.removeRange(1, dio.interceptors.length);
    }

    final seen = <String?>[];
    void capture(RequestOptions options) =>
        seen.add(options.headers[DioClient.buildHeader]);

    client.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        capture(options);
        handler.resolve(Response(requestOptions: options, data: {}));
      },
    ));
    client.unauthDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        capture(options);
        handler.resolve(Response(requestOptions: options, data: {}));
      },
    ));

    platformReply.complete({
      'appName': 'Test',
      'packageName': 'test.app',
      'version': '1.0',
      'buildNumber': '99',
      'buildSignature': '',
    });
    await buildReady;
    final requests = Future.wait([
      client.dio.get('/build-check-auth'),
      client.unauthDio.get('/build-check-public'),
    ]);
    await requests;

    expect(seen, ['99', '99']);
    expect(client.dio.options.headers[DioClient.buildHeader], '99');
    expect(client.unauthDio.options.headers[DioClient.buildHeader], '99');
  });
}
