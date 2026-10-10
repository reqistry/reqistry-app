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
  FavoritesCubit({
    Dio? dio,
    Future<List<BookmarkItem>> Function(AppLocalizations?)? loadBookmarks,
  })  : _loadBookmarks = loadBookmarks ??
            ((l10n) => RemoteService.getAllBookmarks(l10n: l10n)),
        _dio = dio ?? DioClient().dio,
        super(const FavoritesState());

  final Dio _dio;
  final Future<List<BookmarkItem>> Function(AppLocalizations?) _loadBookmarks;
  int _identityEpoch = 0;
  int _mutationRevision = 0;

  /// Fires whenever bookmarks are added or removed so other tabs (home stats,
  /// settings saved count) can refresh accordingly.
  final ValueNotifier<int> changed = ValueNotifier<int>(0);

  void _notifyChanged() => changed.value++;

  Future<void> loadBookmarks({AppLocalizations? l10n}) async {
    final epoch = _identityEpoch;
    final revision = _mutationRevision;
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final bookmarks = await _loadBookmarks(l10n);
      if (isClosed ||
          epoch != _identityEpoch ||
          revision != _mutationRevision) {
        return;
      }
      emit(state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
        errorMessage: '',
      ));
    } catch (_) {
      if (isClosed ||
          epoch != _identityEpoch ||
          revision != _mutationRevision) {
        return;
      }
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
    if (state.pendingApiIds.contains(apiId)) return false;
    if (state.bookmarks.any((item) => item.api.id == apiId)) return true;
    _mutationRevision++;
    final epoch = _identityEpoch;
    final optimisticId = 'pending:$apiId';
    emit(state.copyWith(
      isLoading: false,
      pendingApiIds: {...state.pendingApiIds, apiId},
      bookmarks: optimisticApi == null
          ? state.bookmarks
          : [
              ...state.bookmarks.where((item) => item.api.id != apiId),
              BookmarkItem(
                id: optimisticId,
                api: optimisticApi,
                createdAt: DateTime.now(),
              ),
            ],
    ));
    try {
      final response = await _dio.post(
        '/v1/bookmarks',
        data: {'apiId': apiId},
        options: Options(extra: const {
          'silentLoader': true,
          RequestErrorNotifierInterceptor.silentKey: true,
        }),
      );
      if (isClosed || epoch != _identityEpoch) return false;
      if (response.data is Map) {
        final bookmark = BookmarkItem.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        final withoutTemporary = state.bookmarks
            .where((item) => item.id != bookmark.id && item.api.id != apiId)
            .toList();
        emit(state.copyWith(bookmarks: [...withoutTemporary, bookmark]));
      } else {
        final serverBookmarks = await _loadBookmarks(l10n);
        if (isClosed || epoch != _identityEpoch) return false;
        BookmarkItem? bookmark;
        for (final item in serverBookmarks) {
          if (item.api.id == apiId) {
            bookmark = item;
            break;
          }
        }
        if (bookmark == null) throw StateError('Created bookmark not returned');
        emit(state.copyWith(bookmarks: [
          ...state.bookmarks.where((item) => item.api.id != apiId),
          bookmark,
        ]));
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
      if (isClosed || epoch != _identityEpoch) return false;
      emit(state.copyWith(
        bookmarks:
            state.bookmarks.where((item) => item.id != optimisticId).toList(),
      ));
      AppSnackBarHelper.show(
        title: l10n.snackbarBookmarkErrorTitle,
        message: l10n.snackbarFailedToBookmark,
        isError: true,
      );
      return false;
    } finally {
      if (!isClosed && epoch == _identityEpoch) {
        _mutationRevision++;
        emit(state.copyWith(
          isLoading: false,
          pendingApiIds: {...state.pendingApiIds}..remove(apiId),
        ));
      }
    }
  }

  Future<bool> removeBookmark(String bookmarkId,
      {required AppLocalizations l10n}) async {
    final bookmark = state.bookmarks.cast<BookmarkItem?>().firstWhere(
          (item) => item?.id == bookmarkId,
          orElse: () => null,
        );
    final apiId = bookmark?.api.id ?? '';
    if (apiId.isNotEmpty && state.pendingApiIds.contains(apiId)) return false;
    _mutationRevision++;
    final epoch = _identityEpoch;
    emit(state.copyWith(
      isLoading: false,
      pendingApiIds:
          apiId.isEmpty ? state.pendingApiIds : {...state.pendingApiIds, apiId},
      bookmarks: state.bookmarks.where((b) => b.id != bookmarkId).toList(),
    ));
    try {
      await _dio.delete(
        '/v1/bookmarks/$bookmarkId',
        options: Options(extra: const {
          'silentLoader': true,
          RequestErrorNotifierInterceptor.silentKey: true,
        }),
      );
      if (isClosed || epoch != _identityEpoch) return false;
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
      if (isClosed || epoch != _identityEpoch) return false;
      if (bookmark != null &&
          !state.bookmarks.any((item) => item.id == bookmarkId)) {
        emit(state.copyWith(bookmarks: [...state.bookmarks, bookmark]));
      }
      AppSnackBarHelper.show(
        title: l10n.snackbarBookmarkErrorTitle,
        message: l10n.snackbarFailedToRemoveBookmark,
        isError: true,
      );
      return false;
    } finally {
      if (!isClosed && epoch == _identityEpoch && apiId.isNotEmpty) {
        _mutationRevision++;
        emit(state.copyWith(
          isLoading: false,
          pendingApiIds: {...state.pendingApiIds}..remove(apiId),
        ));
      }
    }
  }

  /// Drops all user data on sign-out/account switch. Never fetches.
  void clear() {
    _identityEpoch++;
    _mutationRevision++;
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

  bool isPending(String apiId) => state.pendingApiIds.contains(apiId);

  int get favoriteCount => state.bookmarks.length;

  List<BookmarkItem> getFavoritesByCategory(String category) {
    return state.bookmarks
        .where((b) => b.api.categoryName == category)
        .toList();
  }

  void refresh() => loadBookmarks();
}
