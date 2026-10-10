import 'package:equatable/equatable.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';

class FavoritesState extends Equatable {
  final List<BookmarkItem> bookmarks;
  final bool isLoading;
  final String errorMessage;
  final Set<String> pendingApiIds;

  const FavoritesState({
    this.bookmarks = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.pendingApiIds = const {},
  });

  FavoritesState copyWith({
    List<BookmarkItem>? bookmarks,
    bool? isLoading,
    String? errorMessage,
    Set<String>? pendingApiIds,
  }) {
    return FavoritesState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingApiIds: pendingApiIds ?? this.pendingApiIds,
    );
  }

  List<BookmarkItem> get favorites => bookmarks;

  @override
  List<Object> get props => [bookmarks, isLoading, errorMessage, pendingApiIds];
}
