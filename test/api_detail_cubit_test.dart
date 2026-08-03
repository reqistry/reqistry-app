import 'package:api_scout/app/blocs/api_detail/api_detail_cubit.dart';
import 'package:api_scout/app/data/models/api.dart' as legacy;
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/services/api_detail/api_detail_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('health refresh preserves the detail while updating only health',
      () async {
    final detail = ApiDetail.fromApi(
      legacy.Api(
        id: 'api-1',
        slug: 'example-api',
        name: 'Example API',
        description: 'Example data',
        auth: 'None',
        https: true,
        cors: true,
        link: 'https://example.com/v1',
        categoryId: 'Development',
        alive: true,
        statusCode: 200,
        responseTimeMs: 120,
        lastCheckedAt: DateTime.now(),
      ),
    );
    final refreshed = ApiHealthSummary(
      status: ApiHealthStatus.degraded,
      statusCode: 200,
      responseTimeMs: 1400,
      checkedAt: DateTime.now(),
    );
    final repository = _FakeRepository(detail, refreshed);
    final cubit = ApiDetailCubit(
      slug: detail.slug,
      repository: repository,
    );
    await Future<void>.delayed(Duration.zero);

    await cubit.refreshHealth();

    expect(cubit.state.detail?.name, detail.name);
    expect(cubit.state.detail?.health, refreshed);
    expect(cubit.state.isRefreshingHealth, isFalse);
    expect(cubit.state.transientMessage, isNotNull);
    await cubit.close();
  });
}

class _FakeRepository implements ApiDetailRepository {
  _FakeRepository(this.detail, this.refreshedHealth);

  final ApiDetail detail;
  final ApiHealthSummary refreshedHealth;

  @override
  ApiDetail? readCached(String slug) => detail;

  @override
  Future<ApiDetail> load({
    required String slug,
    legacy.Api? seed,
    bool forceRefresh = false,
  }) async =>
      detail;

  @override
  Future<ApiDetail> loadAlternatives(ApiDetail detail) async => detail;

  @override
  Future<ApiHealthSummary> refreshHealth(ApiDetail detail) async =>
      refreshedHealth;

  @override
  Future<void> submitReport({
    required String apiId,
    required String slug,
    required String reason,
    String? note,
  }) async {}
}
