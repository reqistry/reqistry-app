import 'dart:async';

import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/search/search_bloc.dart';
import 'package:api_scout/app/data/models/apis_search_response.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations_en.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('filtered search skips empty server pages', () async {
    final requestedPages = <int>[];
    final trackedCounts = <int>[];
    final bloc = SearchBloc(
      search: (params, _) async {
        final page = params['page'] as int;
        requestedPages.add(page);
        return SearchResponse(
          count: 1,
          pagination: SearchPagination(
            page: page,
            limit: 1,
            total: 2,
            totalPages: 2,
          ),
          data: [api(type: page == 1 ? 'REST' : 'GraphQL', id: '$page')],
        );
      },
      trackSearch: (
          {required query, required hasFilters, required resultCount}) {
        trackedCounts.add(resultCount);
      },
    );
    addTearDown(bloc.close);

    bloc.add(const SearchFilterToggled(
      filterType: FilterType.apiType,
      value: 'GraphQL',
    ));
    await bloc.stream.firstWhere((state) => state.apiType.isNotEmpty);
    bloc.add(const SearchPerformed());
    final state = await bloc.stream.firstWhere(
      (state) => !state.isSearching && state.searchResults.isNotEmpty,
    );

    expect(requestedPages, [1, 2]);
    expect(state.searchResults.single.apiType, 'GraphQL');
    expect(state.currentPage, 2);
    expect(state.totalResults, 1);
    expect(trackedCounts, [1]);
  });

  test('identical search submit while loading starts one logical search',
      () async {
    final release = Completer<SearchResponse>();
    var calls = 0;
    var tracked = 0;
    final bloc = SearchBloc(
      search: (_, __) {
        calls++;
        return release.future;
      },
      trackSearch: (
          {required query, required hasFilters, required resultCount}) {
        tracked++;
      },
    );
    addTearDown(bloc.close);

    bloc.add(const SearchPerformed(query: 'weather'));
    await bloc.stream.firstWhere((state) => state.isSearching);
    bloc.add(const SearchPerformed(query: 'weather'));
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);

    release.complete(SearchResponse(
      count: 1,
      pagination: SearchPagination(
        page: 1,
        limit: 20,
        total: 1,
        totalPages: 1,
      ),
      data: [api(type: 'REST', id: 'weather')],
    ));
    await bloc.stream.firstWhere((state) => !state.isSearching);

    expect(calls, 1);
    expect(tracked, 1);
  });

  test('new query supersedes an active search and only it is tracked',
      () async {
    final first = Completer<SearchResponse>();
    final second = Completer<SearchResponse>();
    final tracked = <String?>[];
    final bloc = SearchBloc(
      search: (params, _) =>
          params['q'] == 'first' ? first.future : second.future,
      trackSearch: (
          {required query, required hasFilters, required resultCount}) {
        tracked.add(query);
      },
    );
    addTearDown(bloc.close);

    bloc.add(const SearchPerformed(query: 'first'));
    await bloc.stream.firstWhere((state) => state.isSearching);
    bloc.add(const SearchPerformed(query: 'second'));
    await Future<void>.delayed(Duration.zero);

    first.complete(SearchResponse(
      count: 1,
      pagination: SearchPagination(
        page: 1,
        limit: 20,
        total: 1,
        totalPages: 1,
      ),
      data: [api(type: 'REST', id: 'first')],
    ));
    second.complete(SearchResponse(
      count: 1,
      pagination: SearchPagination(
        page: 1,
        limit: 20,
        total: 1,
        totalPages: 1,
      ),
      data: [api(type: 'REST', id: 'second')],
    ));
    final state = await bloc.stream.firstWhere(
      (state) => !state.isSearching && state.searchResults.isNotEmpty,
    );

    expect(state.query, 'second');
    expect(state.searchResults.single.id, 'second');
    expect(tracked, ['second']);
  });

  test('project and compare paths retain reconstructible identifiers', () {
    final projectPath = AppRoutes.projectPath('project / one');
    final comparePath = AppRoutes.comparePath(['api-1', 'api/2']);

    expect(projectPath, '/projects/project%20%2F%20one');
    expect(AppRoutes.compareIds(Uri.parse(comparePath)), ['api-1', 'api/2']);
  });

  test('concurrent refresh callers share one operation and result', () async {
    final release = Completer<String?>();
    final singleFlight = RefreshSingleFlight();
    var calls = 0;

    Future<String?> refresh() {
      calls++;
      return release.future;
    }

    final first = singleFlight.run(refresh);
    final second = singleFlight.run(refresh);
    release.complete('access-token');

    expect(
        await Future.wait([first, second]), ['access-token', 'access-token']);
    expect(calls, 1);
  });

  test('failed bookmark request does not erase concurrent success', () async {
    final releaseFailure = Completer<void>();
    final dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final apiId = (options.data as Map)['apiId'] as String;
      if (apiId == 'api-a') {
        await releaseFailure.future;
        handler.reject(DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ));
        return;
      }
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: bookmarkJson('bookmark-b', 'api-b'),
      ));
    }));
    final cubit = FavoritesCubit(dio: dio);
    addTearDown(cubit.close);

    final first = cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );
    await Future<void>.delayed(Duration.zero);
    final second = cubit.addBookmark(
      apiId: 'api-b',
      optimisticApi: bookmarkApi('api-b'),
      l10n: l10n,
    );
    expect(await second, isTrue);
    releaseFailure.complete();
    expect(await first, isFalse);

    expect(cubit.state.bookmarks.map((item) => item.id), ['bookmark-b']);
  });

  test('duplicate bookmark taps share one pending mutation', () async {
    final release = Completer<void>();
    final dio = Dio();
    var calls = 0;
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        calls++;
        await release.future;
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: bookmarkJson('bookmark-a', 'api-a'),
        ));
      },
    ));
    final cubit = FavoritesCubit(dio: dio);
    addTearDown(cubit.close);

    final first = cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );
    await Future<void>.delayed(Duration.zero);
    final second = cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );

    expect(await second, isFalse);
    expect(cubit.isPending('api-a'), isTrue);
    expect(cubit.state.bookmarks.single.api.id, 'api-a');

    release.complete();
    expect(await first, isTrue);
    expect(calls, 1);
    expect(cubit.isPending('api-a'), isFalse);
    expect(cubit.state.bookmarks.single.id, 'bookmark-a');
  });

  test('failed optimistic bookmark rolls back only that API', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ),
      ),
    ));
    final cubit = FavoritesCubit(dio: dio);
    addTearDown(cubit.close);

    expect(
      await cubit.addBookmark(
        apiId: 'api-a',
        optimisticApi: bookmarkApi('api-a'),
        l10n: l10n,
      ),
      isFalse,
    );
    expect(cubit.state.bookmarks, isEmpty);
    expect(cubit.isPending('api-a'), isFalse);
  });

  test('account clear blocks stale bookmark rollback and lock cleanup',
      () async {
    final deleteStarted = Completer<void>();
    final releaseDelete = Completer<void>();
    final releaseNewAdd = Completer<void>();
    var postCount = 0;
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.method == 'DELETE') {
          deleteStarted.complete();
          await releaseDelete.future;
          handler.reject(DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          ));
          return;
        }
        postCount++;
        if (postCount > 1) await releaseNewAdd.future;
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: bookmarkJson('bookmark-a', 'api-a'),
        ));
      },
    ));
    final cubit = FavoritesCubit(dio: dio);
    addTearDown(cubit.close);
    await cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );

    final staleRemove = cubit.removeBookmark('bookmark-a', l10n: l10n);
    await deleteStarted.future;
    cubit.clear();
    final newAccountAdd = cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.isPending('api-a'), isTrue);

    releaseDelete.complete();
    expect(await staleRemove, isFalse);
    expect(cubit.isPending('api-a'), isTrue);

    releaseNewAdd.complete();
    expect(await newAccountAdd, isTrue);
    expect(cubit.state.bookmarks.single.id, 'bookmark-a');
  });

  test('successful remove wins over a stale bookmark refresh', () async {
    final deleteStarted = Completer<void>();
    final releaseDelete = Completer<void>();
    final saved = BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a'));
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.method == 'DELETE') {
          deleteStarted.complete();
          await releaseDelete.future;
          handler.resolve(Response(requestOptions: options, statusCode: 204));
          return;
        }
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: bookmarkJson('bookmark-a', 'api-a'),
        ));
      },
    ));
    final cubit = FavoritesCubit(
      dio: dio,
      loadBookmarks: (_) async => [saved],
    );
    addTearDown(cubit.close);
    await cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );

    final remove = cubit.removeBookmark('bookmark-a', l10n: l10n);
    await deleteStarted.future;
    await cubit.loadBookmarks(l10n: l10n);
    expect(cubit.state.bookmarks.single.id, 'bookmark-a');

    releaseDelete.complete();
    expect(await remove, isTrue);
    expect(cubit.state.bookmarks, isEmpty);
  });

  test('failed remove restores at most one bookmark after stale refresh',
      () async {
    final deleteStarted = Completer<void>();
    final releaseDelete = Completer<void>();
    final saved = BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a'));
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        deleteStarted.complete();
        await releaseDelete.future;
        handler.reject(DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ));
      },
    ));
    final cubit = FavoritesCubit(
      dio: dio,
      loadBookmarks: (_) async => [saved],
    );
    addTearDown(cubit.close);
    await cubit.loadBookmarks(l10n: l10n);

    final remove = cubit.removeBookmark('bookmark-a', l10n: l10n);
    await deleteStarted.future;
    await cubit.loadBookmarks(l10n: l10n);
    releaseDelete.complete();

    expect(await remove, isFalse);
    expect(cubit.state.bookmarks.single.id, 'bookmark-a');
  });

  test('account clear discards an older bookmark load', () async {
    final release = Completer<List<BookmarkItem>>();
    final cubit = FavoritesCubit(
      dio: Dio(),
      loadBookmarks: (_) => release.future,
    );
    addTearDown(cubit.close);

    final load = cubit.loadBookmarks(l10n: l10n);
    cubit.clear();
    release.complete([
      BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a')),
    ]);
    await load;

    expect(cubit.state.bookmarks, isEmpty);
    expect(cubit.state.isLoading, isFalse);
  });

  test('refresh started before remove cannot restore the deleted bookmark',
      () async {
    final releaseRefresh = Completer<List<BookmarkItem>>();
    final saved = BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a'));
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(Response(
        requestOptions: options,
        statusCode: options.method == 'DELETE' ? 204 : 201,
        data: options.method == 'DELETE'
            ? null
            : bookmarkJson('bookmark-a', 'api-a'),
      )),
    ));
    final cubit = FavoritesCubit(
      dio: dio,
      loadBookmarks: (_) => releaseRefresh.future,
    );
    addTearDown(cubit.close);
    await cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );

    final refresh = cubit.loadBookmarks(l10n: l10n);
    expect(await cubit.removeBookmark('bookmark-a', l10n: l10n), isTrue);
    releaseRefresh.complete([saved]);
    await refresh;

    expect(cubit.state.bookmarks, isEmpty);
  });

  test('refresh started during remove cannot restore the deleted bookmark',
      () async {
    final deleteStarted = Completer<void>();
    final releaseDelete = Completer<void>();
    final releaseRefresh = Completer<List<BookmarkItem>>();
    final saved = BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a'));
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.method == 'DELETE') {
          deleteStarted.complete();
          await releaseDelete.future;
          handler.resolve(Response(requestOptions: options, statusCode: 204));
          return;
        }
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: bookmarkJson('bookmark-a', 'api-a'),
        ));
      },
    ));
    final cubit = FavoritesCubit(
      dio: dio,
      loadBookmarks: (_) => releaseRefresh.future,
    );
    addTearDown(cubit.close);
    await cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );

    final remove = cubit.removeBookmark('bookmark-a', l10n: l10n);
    await deleteStarted.future;
    final refresh = cubit.loadBookmarks(l10n: l10n);
    releaseDelete.complete();
    expect(await remove, isTrue);
    releaseRefresh.complete([saved]);
    await refresh;

    expect(cubit.state.bookmarks, isEmpty);
    expect(cubit.state.isLoading, isFalse);
  });

  test('non-map add fallback cannot restore a cleared account', () async {
    final loadStarted = Completer<void>();
    final releaseLoad = Completer<List<BookmarkItem>>();
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: null,
      )),
    ));
    final cubit = FavoritesCubit(
      dio: dio,
      loadBookmarks: (_) {
        loadStarted.complete();
        return releaseLoad.future;
      },
    );
    addTearDown(cubit.close);

    final add = cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );
    await loadStarted.future;
    cubit.clear();
    releaseLoad.complete([
      BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a')),
    ]);

    expect(await add, isFalse);
    expect(cubit.state.bookmarks, isEmpty);
  });

  test('non-map add fallback merges its API across a concurrent add', () async {
    final loadStarted = Completer<void>();
    final releaseLoad = Completer<List<BookmarkItem>>();
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final apiId = (options.data as Map)['apiId'] as String;
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: apiId == 'api-a' ? null : bookmarkJson('bookmark-b', 'api-b'),
        ));
      },
    ));
    final cubit = FavoritesCubit(
      dio: dio,
      loadBookmarks: (_) {
        loadStarted.complete();
        return releaseLoad.future;
      },
    );
    addTearDown(cubit.close);

    final first = cubit.addBookmark(
      apiId: 'api-a',
      optimisticApi: bookmarkApi('api-a'),
      l10n: l10n,
    );
    await loadStarted.future;
    expect(
      await cubit.addBookmark(
        apiId: 'api-b',
        optimisticApi: bookmarkApi('api-b'),
        l10n: l10n,
      ),
      isTrue,
    );
    releaseLoad.complete([
      BookmarkItem.fromJson(bookmarkJson('bookmark-a', 'api-a')),
      BookmarkItem.fromJson(bookmarkJson('bookmark-b', 'api-b')),
    ]);

    expect(await first, isTrue);
    expect(
      cubit.state.bookmarks.map((item) => item.id).toSet(),
      {'bookmark-a', 'bookmark-b'},
    );
    expect(
      cubit.state.bookmarks.any((item) => item.id.startsWith('pending:')),
      isFalse,
    );
  });

  test('failed project add does not erase concurrent success', () async {
    final releaseFailure = Completer<void>();
    final dio = Dio();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      if (options.method == 'GET') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'folders': [projectJson()],
          },
        ));
        return;
      }
      final apiId = (options.data as Map)['apiId'] as String;
      if (apiId == 'api-a') {
        await releaseFailure.future;
        handler.reject(DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        ));
        return;
      }
      handler.resolve(Response(requestOptions: options, statusCode: 201));
    }));
    final cubit = ProjectsCubit(dio: dio);
    addTearDown(cubit.close);
    await cubit.loadProjects(l10n: l10n);

    final first = cubit.addApiToProject(
      'project-1',
      apiId: 'api-a',
      apiLink: 'https://a.example',
      l10n: l10n,
    );
    await Future<void>.delayed(Duration.zero);
    final second = cubit.addApiToProject(
      'project-1',
      apiId: 'api-b',
      apiLink: 'https://b.example',
      l10n: l10n,
    );
    expect(await second, isTrue);
    releaseFailure.complete();
    expect(await first, isFalse);

    expect(cubit.state.projects.single.apiLinks, ['https://b.example']);
  });
}

ApiItem api({required String type, required String id}) => ApiItem(
      id: id,
      name: id,
      description: 'description',
      auth: 'None',
      https: 'true',
      cors: 'Yes',
      link: 'https://$id.example',
      category: 'Development',
      apiType: type,
      pricing: 'Free',
      rateLimit: 'Unknown',
      documentation: '',
      isAlive: true,
      responseTime: 100,
      lastChecked: '',
    );

BookmarkApi bookmarkApi(String id) => BookmarkApi(
      id: id,
      name: id,
      description: 'description',
      link: 'https://$id.example',
    );

Map<String, dynamic> bookmarkJson(String bookmarkId, String apiId) => {
      'id': bookmarkId,
      'createdAt': '2026-09-06T00:00:00Z',
      'api': {
        'id': apiId,
        'name': apiId,
        'description': 'description',
        'link': 'https://$apiId.example',
      },
    };

Map<String, dynamic> projectJson() => {
      'id': 'project-1',
      'title': 'Project',
      'iconCodePoint': 0,
      'apiLinks': <String>[],
      'apiCount': 0,
      'createdAt': '2026-09-06T00:00:00Z',
    };
