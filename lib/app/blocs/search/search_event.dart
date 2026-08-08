part of 'search_bloc.dart';

enum FilterType {
  pricing,
  auth,
  apiType,
  category,
  https,
  cors,
  alive,
  maxResponseTime
}

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchFilterToggled extends SearchEvent {
  final FilterType filterType;
  final String value;

  const SearchFilterToggled({required this.filterType, required this.value});

  @override
  List<Object?> get props => [filterType, value];
}

class SearchFiltersReset extends SearchEvent {
  const SearchFiltersReset();
}

class SearchQuickFilterApplied extends SearchEvent {
  final String? preset;

  const SearchQuickFilterApplied({this.preset});

  @override
  List<Object?> get props => [preset];
}

class SearchPerformed extends SearchEvent {
  final bool reset;
  final AppLocalizations? l10n;

  const SearchPerformed({this.reset = true, this.l10n});

  @override
  List<Object?> get props => [reset];
}

class SearchLoadMore extends SearchEvent {
  final AppLocalizations? l10n;
  const SearchLoadMore({this.l10n});
}

class SearchCategoriesLoaded extends SearchEvent {
  final AppLocalizations? l10n;
  const SearchCategoriesLoaded({this.l10n});
}

class SearchTokenSaved extends SearchEvent {
  final String token;
  final AppLocalizations l10n;

  const SearchTokenSaved({required this.token, required this.l10n});

  @override
  List<Object?> get props => [token];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchSortChanged extends SearchEvent {
  final String sortBy;
  final String sortOrder;

  const SearchSortChanged({required this.sortBy, required this.sortOrder});

  @override
  List<Object?> get props => [sortBy, sortOrder];
}
