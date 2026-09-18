import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/favorites/favorites_state.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';
import 'package:api_scout/app/services/auth/dio_client.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/in_app_review/in_app_review.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:dio/dio.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({Dio? dio})
      : _dio = dio ?? DioClient().dio,
        super(const FavoritesState());

  final Dio _dio;

  /// Fires whenever bookmarks are added or removed so other tabs (home stats,
  /// settings saved count) can refresh accordingly.
  final ValueNotifier<int> changed = ValueNotifier<int>(0);

  void _notifyChanged() => changed.value++;

  Future<void> loadBookmarks({AppLocalizations? l10n}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final bookmarks = await RemoteService.getAllBookmarks(l10n: l10n);
      emit(state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
        errorMessage: '',
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: l10n?.stateSomethingWentWrong ?? 'Something went wrong',
      ));
    }
  }

  Future<bool> addBookmark({
    required String apiId,
    String? apiName,
    BookmarkApi? optimisticApi,
    required AppLocalizations l10n,
  }) async {
    if (apiId.trim().isEmpty) {
      AppSnackBarHelper.show(
        title: l10n.snackbarBookmarkErrorTitle,
        message: l10n.snackbarBookmarkErrorMessage,
        isError: true,
      );
      return false;
    }
    try {
      final response = await _dio.post(
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
            .where((item) => item.id != bookmark.id && item.api.id != apiId)
            .toList();
        emit(state.copyWith(bookmarks: [...withoutTemporary, bookmark]));
      } else {
        await loadBookmarks(l10n: l10n);
      }
      _notifyChanged();
      AppSnackBarHelper.show(
        title: l10n.snackbarBookmarkedTitle,
        message: l10n.snackbarAddedToBookmarks(apiName ?? ''),
      );
      // Best-effort review prompt; never blocks the save flow.
      unawaited(InAppReview().recordWinAndMaybePrompt());
      return true;
    } catch (e) {
      AppSnackBarHelper.show(
        title: l10n.snackbarBookmarkErrorTitle,
        message: l10n.snackbarFailedToBookmark,
        isError: true,
      );
      return false;
    }
  }

  Future<bool> removeBookmark(String bookmarkId,
      {required AppLocalizations l10n}) async {
    try {
      await _dio.delete(
        '/v1/bookmarks/$bookmarkId',
        options: Options(extra: const {
          'silentLoader': true,
          RequestErrorNotifierInterceptor.silentKey: true,
        }),
      );
      emit(state.copyWith(
        bookmarks: state.bookmarks.where((b) => b.id != bookmarkId).toList(),
      ));
      _notifyChanged();
      AppSnackBarHelper.show(
        title: l10n.snackbarRemovedTitle,
        message: l10n.snackbarBookmarkRemoved,
      );
      return true;
    } catch (e) {
      AppSnackBarHelper.show(
        title: l10n.snackbarBookmarkErrorTitle,
        message: l10n.snackbarFailedToRemoveBookmark,
        isError: true,
      );
      return false;
    }
  }

  /// Drops all user data on sign-out/account switch. Never fetches.
  void clear() {
    if (!isClosed) emit(const FavoritesState());
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
