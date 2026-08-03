part of 'search_bloc.dart';

class SearchState extends Equatable {
  final String query;
  final List<String> pricing;
  final List<String> auth;
  final List<String> apiType;
  final List<String> category;
  final String? cors;
  final bool? https;
  final bool? alive;
  final int? maxResponseTime;
  final String sortBy;
  final String sortOrder;
  final List<ApiItem> searchResults;
  final bool isSearching;
  final bool isLoadingMore;
  final String errorMessage;
  final int currentPage;
  final int totalResults;
  final int totalPages;
  final bool hasMore;
  final String? activeQuickFilter;
  final String searchToken;
  final String lastRequestDebug;
  final List<String> availableCategories;
  final bool isLoadingCategories;

  const SearchState({
    this.query = '',
    this.pricing = const [],
    this.auth = const [],
    this.apiType = const [],
    this.category = const [],
    this.cors,
    this.https,
    this.alive,
    this.maxResponseTime,
    this.sortBy = 'name',
    this.sortOrder = 'asc',
    this.searchResults = const [],
    this.isSearching = false,
    this.isLoadingMore = false,
    this.errorMessage = '',
    this.currentPage = 1,
    this.totalResults = 0,
    this.totalPages = 0,
    this.hasMore = false,
    this.activeQuickFilter,
    this.searchToken = '',
    this.lastRequestDebug = '',
    this.availableCategories = const [],
    this.isLoadingCategories = false,
  });

  SearchState copyWith({
    String? query,
    List<String>? pricing,
    List<String>? auth,
    List<String>? apiType,
    List<String>? category,
    String? cors,
    bool? https,
    bool? alive,
    int? maxResponseTime,
    String? sortBy,
    String? sortOrder,
    List<ApiItem>? searchResults,
    bool? isSearching,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    int? totalResults,
    int? totalPages,
    bool? hasMore,
    String? activeQuickFilter,
    String? searchToken,
    String? lastRequestDebug,
    List<String>? availableCategories,
    bool? isLoadingCategories,
  }) {
    return SearchState(
      query: query ?? this.query,
      pricing: pricing ?? this.pricing,
      auth: auth ?? this.auth,
      apiType: apiType ?? this.apiType,
      category: category ?? this.category,
      cors: cors ?? this.cors,
      https: https ?? this.https,
      alive: alive ?? this.alive,
      maxResponseTime: maxResponseTime ?? this.maxResponseTime,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalResults: totalResults ?? this.totalResults,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      activeQuickFilter: activeQuickFilter ?? this.activeQuickFilter,
      searchToken: searchToken ?? this.searchToken,
      lastRequestDebug: lastRequestDebug ?? this.lastRequestDebug,
      availableCategories: availableCategories ?? this.availableCategories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
    );
  }

  @override
  List<Object?> get props => [
        query,
        pricing,
        auth,
        apiType,
        category,
        cors,
        https,
        alive,
        maxResponseTime,
        sortBy,
        sortOrder,
        searchResults,
        isSearching,
        isLoadingMore,
        errorMessage,
        currentPage,
        totalResults,
        totalPages,
        hasMore,
        activeQuickFilter,
        searchToken,
        lastRequestDebug,
        availableCategories,
        isLoadingCategories,
      ];
}
