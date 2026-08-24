import 'package:api_scout/app/blocs/api_detail/api_detail_cubit.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/services/api_detail/api_detail_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('health refresh preserves the detail while updating only health',
      () async {
    final detail = ApiDetail.fromApi(
      ApiItem(
        id: 'api-1',
        slug: 'example-api',
        name: 'Example API',
        description: 'Example data',
        auth: 'None',
        https: 'true',
        cors: 'Yes',
        link: 'https://example.com/v1',
        category: 'Development',
        apiType: 'REST',
        pricing: 'Unknown',
        rateLimit: 'Unknown',
        documentation: '',
        isAlive: true,
        statusCode: 200,
        responseTime: 120,
        lastChecked: DateTime.now().toIso8601String(),
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
    ApiItem? seed,
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
