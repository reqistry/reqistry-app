import 'package:equatable/equatable.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';

class FavoritesState extends Equatable {
  final List<BookmarkItem> bookmarks;
  final bool isLoading;
  final String errorMessage;

  const FavoritesState({
    this.bookmarks = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  FavoritesState copyWith({
    List<BookmarkItem>? bookmarks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<BookmarkItem> get favorites => bookmarks;

  @override
  List<Object> get props => [bookmarks, isLoading, errorMessage];
}
