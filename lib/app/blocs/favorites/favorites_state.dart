import 'package:equatable/equatable.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';

class FavoritesState extends Equatable {
  final List<BookmarkItem> bookmarks;
  final bool isLoading;

  const FavoritesState({
    this.bookmarks = const [],
    this.isLoading = false,
  });

  FavoritesState copyWith({
    List<BookmarkItem>? bookmarks,
    bool? isLoading,
  }) {
    return FavoritesState(
      bookmarks: bookmarks ?? this.bookmarks,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<BookmarkItem> get favorites => bookmarks;

  @override
  List<Object> get props => [bookmarks, isLoading];
}
