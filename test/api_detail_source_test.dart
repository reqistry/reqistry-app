import 'package:api_scout/app/services/api_detail/api_detail_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('report response exposes categorical deduplication outcome', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.path, '/v1/apis/api-1/reports');
        expect(options.data, {
          'reason': 'LINK_BROKEN',
          'note': 'private note',
        });
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: const {'deduplicated': true},
        ));
      },
    ));

    final result = await ApiDetailSource(authDio: dio).submitReport(
      apiId: 'api-1',
      reason: 'LINK_BROKEN',
      note: '  private note  ',
    );

    expect(result.reason, 'LINK_BROKEN');
    expect(result.status, 'deduplicated');
    expect(result.analyticsProperties, {
      'report_reason': 'LINK_BROKEN',
      'report_status': 'deduplicated',
    });
    expect(result.analyticsProperties.values, isNot(contains('private note')));
  });
}
