import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/favorites/favorites_state.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:dio/dio.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  /// Fires whenever bookmarks are added or removed so other tabs (home stats,
  /// settings saved count) can refresh accordingly.
  final ValueNotifier<int> changed = ValueNotifier<int>(0);

  void _notifyChanged() => changed.value++;

  Future<void> loadBookmarks({int page = 1, int limit = 50}) async {
    try {
      emit(state.copyWith(isLoading: true));
      final response = await DioClient().dio.get(
        '/v1/bookmarks',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      final bookmarks = (data['bookmarks'] as List)
          .whereType<Map<String, dynamic>>()
          .map((b) => BookmarkItem.fromJson(b))
          .toList();
      emit(state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<bool> addBookmark({
    required String apiId,
    String? apiName,
    BookmarkApi? optimisticApi,
  }) async {
    final previous = state.bookmarks;
    final temporaryId = 'optimistic-$apiId';
    if (optimisticApi != null &&
        !state.bookmarks.any((item) => item.api.id == apiId)) {
      emit(state.copyWith(bookmarks: [
        ...state.bookmarks,
        BookmarkItem(
          id: temporaryId,
          api: optimisticApi,
          createdAt: DateTime.now(),
        ),
      ]));
    }
    if (apiId.trim().isEmpty) {
      emit(state.copyWith(bookmarks: previous));
      AppSnackBarHelper.show(
        title: 'Error',
        message: 'This API cannot be bookmarked yet.',
        isError: true,
      );
      return false;
    }
    try {
      final response = await DioClient().dio.post(
            '/v1/bookmarks',
            data: {'apiId': apiId},
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
      if (response.data is Map) {
        final bookmark = BookmarkItem.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        final withoutTemporary = state.bookmarks
            .where((item) => item.id != temporaryId && item.id != bookmark.id)
            .toList();
        emit(state.copyWith(bookmarks: [...withoutTemporary, bookmark]));
      } else {
        await loadBookmarks();
      }
      _notifyChanged();
      AppSnackBarHelper.show(
        title: 'Bookmarked',
        message: '$apiName added to bookmarks',
      );
      return true;
    } catch (e) {
      emit(state.copyWith(bookmarks: previous));
      AppSnackBarHelper.show(
        title: 'Error',
        message: 'Failed to bookmark API',
        isError: true,
      );
      return false;
    }
  }

  Future<bool> removeBookmark(String bookmarkId) async {
    final previous = state.bookmarks;
    emit(state.copyWith(
      bookmarks: state.bookmarks.where((b) => b.id != bookmarkId).toList(),
    ));
    try {
      await DioClient().dio.delete(
            '/v1/bookmarks/$bookmarkId',
            options: Options(extra: const {
              'silentLoader': true,
              RequestErrorNotifierInterceptor.silentKey: true,
            }),
          );
      _notifyChanged();
      AppSnackBarHelper.show(
        title: 'Removed',
        message: 'Bookmark removed',
      );
      return true;
    } catch (e) {
      emit(state.copyWith(bookmarks: previous));
      AppSnackBarHelper.show(
        title: 'Error',
        message: 'Failed to remove bookmark',
        isError: true,
      );
      return false;
    }
  }

  bool isFavorited(String apiLink) {
    return state.bookmarks.any((b) => b.api.link == apiLink);
  }

  String? getBookmarkId(String apiLink) {
    try {
      return state.bookmarks.firstWhere((b) => b.api.link == apiLink).id;
    } catch (_) {
      return null;
    }
  }

  int get favoriteCount => state.bookmarks.length;

  List<BookmarkItem> getFavoritesByCategory(String category) {
    return state.bookmarks
        .where((b) => b.api.categoryName == category)
        .toList();
  }

  void refresh() => loadBookmarks();
}
