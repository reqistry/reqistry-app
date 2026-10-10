import 'dart:async';

import 'package:api_scout/app/blocs/category_apis/category_apis_cubit.dart';
import 'package:api_scout/app/data/models/categories_response.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('late category response is ignored after close', () async {
    final detail = Completer<CategoryDetail>();
    var apisRequested = false;
    final cubit = CategoryApisCubit(
      argument: 'ai',
      getCategory: (_, __) => detail.future,
      getCategoryApis: (_, __) async {
        apisRequested = true;
        return CategoryApis(title: 'AI', apis: const []);
      },
    );

    await cubit.close();
    detail.complete(CategoryDetail(id: 'ai', name: 'AI'));
    await Future<void>.delayed(Duration.zero);

    expect(apisRequested, isFalse);
  });

  test('late category failure is ignored after close', () async {
    final detail = Completer<CategoryDetail>();
    final cubit = CategoryApisCubit(
      argument: 'ai',
      getCategory: (_, __) => detail.future,
      getCategoryApis: (_, __) async =>
          CategoryApis(title: 'AI', apis: const []),
    );

    await cubit.close();
    detail.completeError(StateError('offline'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.isClosed, isTrue);
  });

  test('refresh keeps existing APIs while loading and after failure', () async {
    final refresh = Completer<CategoryApis>();
    var calls = 0;
    final existing = _api('existing');
    final cubit = CategoryApisCubit(
      argument: 'ai',
      getCategory: (_, __) async => CategoryDetail(id: 'ai', name: 'AI'),
      getCategoryApis: (_, __) {
        calls++;
        if (calls == 1) {
          return Future.value(CategoryApis(title: 'AI', apis: [existing]));
        }
        return refresh.future;
      },
    );
    addTearDown(cubit.close);
    if (cubit.state.apis.isEmpty) {
      await cubit.stream
          .firstWhere((state) => !state.isLoading && state.apis.isNotEmpty);
    }

    final loading = cubit.stream.firstWhere((state) => state.isLoading);
    final retry = cubit.retryFetch();
    await loading;
    expect(cubit.state.apis, [existing]);

    refresh.completeError(StateError('offline'));
    await retry;
    expect(cubit.state.apis, [existing]);
    expect(cubit.state.errorMessage, isNotEmpty);
  });
}

ApiItem _api(String id) => ApiItem(
      id: id,
      name: 'Existing API',
      description: '',
      auth: 'None',
      https: 'true',
      cors: 'Yes',
      link: 'https://example.com/$id',
      category: 'AI',
      apiType: 'REST',
      pricing: 'Free',
      rateLimit: 'Unknown',
      documentation: '',
      isAlive: true,
      responseTime: 100,
      lastChecked: '',
    );
