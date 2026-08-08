import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final int limit = 20;

  SearchBloc() : super(const SearchState()) {
    on<SearchFilterToggled>(_onFilterToggled);
    on<SearchFiltersReset>(_onFiltersReset);
    on<SearchQuickFilterApplied>(_onQuickFilterApplied);
    on<SearchPerformed>(_onSearch);
    on<SearchLoadMore>(_onLoadMore);
    on<SearchCategoriesLoaded>(_onLoadCategories);
    on<SearchTokenSaved>(_onSaveToken);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSortChanged>(_onSortChanged);
  }

  bool get canSearch {
    final s = state;
    return s.query.isNotEmpty ||
        s.pricing.isNotEmpty ||
        s.auth.isNotEmpty ||
        s.apiType.isNotEmpty ||
        s.category.isNotEmpty ||
        s.cors != null ||
        s.https != null ||
        s.alive != null ||
        s.maxResponseTime != null;
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(query: event.query));
  }

  Future<void> _onSortChanged(
      SearchSortChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    ));
  }

  Future<void> _onFilterToggled(
      SearchFilterToggled event, Emitter<SearchState> emit) async {
    final currentState = state;

    switch (event.filterType) {
      case FilterType.pricing:
        final updatedList = List<String>.from(currentState.pricing);
        if (updatedList.contains(event.value)) {
          updatedList.remove(event.value);
        } else {
          updatedList.add(event.value);
        }
        emit(currentState.copyWith(pricing: updatedList));
        break;
      case FilterType.auth:
        final updatedList = List<String>.from(currentState.auth);
        if (updatedList.contains(event.value)) {
          updatedList.remove(event.value);
        } else {
          updatedList.add(event.value);
        }
        emit(currentState.copyWith(auth: updatedList));
        break;
      case FilterType.apiType:
        final updatedList = List<String>.from(currentState.apiType);
        if (updatedList.contains(event.value)) {
          updatedList.remove(event.value);
        } else {
          updatedList.add(event.value);
        }
        emit(currentState.copyWith(apiType: updatedList));
        break;
      case FilterType.category:
        final updatedList = List<String>.from(currentState.category);
        if (updatedList.contains(event.value)) {
          updatedList.remove(event.value);
        } else {
          updatedList.add(event.value);
        }
        emit(currentState.copyWith(category: updatedList));
        break;
      case FilterType.https:
        final value = event.value == 'null'
            ? null
            : (event.value == 'true' ? true : false);
        emit(currentState.copyWith(https: value));
        break;
      case FilterType.cors:
        final value = event.value == 'null' ? null : event.value;
        emit(currentState.copyWith(cors: value));
        break;
      case FilterType.alive:
        final value = event.value == 'null'
            ? null
            : (event.value == 'true' ? true : false);
        emit(currentState.copyWith(alive: value));
        break;
      case FilterType.maxResponseTime:
        final value = event.value == 'null' ? null : int.tryParse(event.value);
        emit(currentState.copyWith(maxResponseTime: value));
        break;
    }
  }

  void _onFiltersReset(SearchFiltersReset event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }

  void _onQuickFilterApplied(
      SearchQuickFilterApplied event, Emitter<SearchState> emit) {
    emit(const SearchState());

    switch (event.preset) {
      case 'free':
        emit(state.copyWith(
          pricing: ['Free'],
          alive: true,
          activeQuickFilter: 'free',
        ));
        break;
      case 'no-auth':
        emit(state.copyWith(
          auth: ['none'],
          alive: true,
          activeQuickFilter: 'no-auth',
        ));
        break;
      case 'fast':
        emit(state.copyWith(
          maxResponseTime: 500,
          alive: true,
          sortBy: 'responseTime',
          sortOrder: 'asc',
          activeQuickFilter: 'fast',
        ));
        break;
      case 'secure':
        emit(state.copyWith(
          https: true,
          alive: true,
          activeQuickFilter: 'secure',
        ));
        break;
      case 'cors':
        emit(state.copyWith(
          cors: 'yes',
          https: true,
          alive: true,
          activeQuickFilter: 'cors',
        ));
        break;
      default:
        emit(state.copyWith(activeQuickFilter: null));
    }
  }

  Map<String, dynamic> _buildRequestParams(SearchState s) {
    return {
      'q': s.query.isNotEmpty ? s.query : null,
      'pricing': s.pricing.isNotEmpty ? List<String>.from(s.pricing) : null,
      'auth': s.auth.isNotEmpty ? List<String>.from(s.auth) : null,
      'apiType': s.apiType.isNotEmpty ? List<String>.from(s.apiType) : null,
      'category': s.category.isNotEmpty ? List<String>.from(s.category) : null,
      'cors': s.cors,
      'https': s.https,
      'alive': s.alive,
      'maxResponseTime': s.maxResponseTime,
      'sortBy': s.sortBy,
      'sortOrder': s.sortOrder,
      'page': s.currentPage,
      'limit': limit,
    };
  }

  Future<void> _onSearch(
      SearchPerformed event, Emitter<SearchState> emit) async {
    if (!canSearch) return;

    final reset = event.reset;

    if (reset) {
      emit(state.copyWith(currentPage: 1, searchResults: []));
    }

    emit(state.copyWith(isSearching: true, errorMessage: ''));

    try {
      final requestParams = _buildRequestParams(state);
      String debugOutput = '';
      if (kDebugMode) {
        debugOutput = const JsonEncoder.withIndent('  ').convert(requestParams);
      }

      final response = await RemoteService.searchApis(
        q: requestParams['q'] as String?,
        pricing: requestParams['pricing'] as List<String>?,
        auth: requestParams['auth'] as List<String>?,
        apiType: requestParams['apiType'] as List<String>?,
        category: requestParams['category'] as List<String>?,
        cors: requestParams['cors'] as String?,
        https: requestParams['https'] as bool?,
        alive: requestParams['alive'] as bool?,
        maxResponseTime: requestParams['maxResponseTime'] as int?,
        sortBy: requestParams['sortBy'] as String? ?? 'name',
        sortOrder: requestParams['sortOrder'] as String? ?? 'asc',
        page: requestParams['page'] as int? ?? state.currentPage,
        limit: requestParams['limit'] as int? ?? limit,
        l10n: event.l10n,
      );

      if (response.success) {
        final apis = response.data;
        final List<ApiItem> updatedResults;
        if (reset) {
          updatedResults = apis;
        } else {
          updatedResults = [...state.searchResults, ...apis];
        }

        final sortedResults = _applyLocalSort(
          updatedResults,
          state.sortBy,
          state.sortOrder,
        );

        emit(state.copyWith(
          isSearching: false,
          searchResults: sortedResults,
          totalResults: response.pagination.total,
          totalPages: response.pagination.totalPages,
          hasMore: response.pagination.hasMore,
          lastRequestDebug: debugOutput,
        ));
      } else {
        throw Exception(response.message ?? 'Search failed');
      }
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        errorMessage: e.toString(),
      ));
      if (event.l10n != null) {
        AppSnackBarHelper.show(
          title: event.l10n!.snackbarSearchErrorTitle,
          message: e.toString(),
          isError: true,
        );
      }
    }
  }

  Future<void> _onLoadMore(
      SearchLoadMore event, Emitter<SearchState> emit) async {
    final s = state;
    if (s.isLoadingMore || !s.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, currentPage: s.currentPage + 1));

    try {
      await _onSearch(SearchPerformed(reset: false, l10n: event.l10n), emit);
    } catch (e) {
      emit(state.copyWith(currentPage: s.currentPage));
    } finally {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onLoadCategories(
      SearchCategoriesLoaded event, Emitter<SearchState> emit) async {
    emit(state.copyWith(isLoadingCategories: true));
    try {
      final response = await RemoteService.getCategories(l10n: event.l10n);
      final categories = response.toCategories();
      emit(state.copyWith(
        isLoadingCategories: false,
        availableCategories: categories.map((c) => c.name).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingCategories: false));
    }
  }

  Future<void> _onSaveToken(
      SearchTokenSaved event, Emitter<SearchState> emit) async {
    try {
      await LocalsDB.instance.putWithKey('searchToken', event.token);
      emit(state.copyWith(searchToken: event.token));
      AppSnackBarHelper.show(title: event.l10n.snackbarSavedTitle, message: event.l10n.snackbarSearchTokenSaved);
    } catch (e) {
      AppSnackBarHelper.show(
        title: event.l10n.snackbarSaveErrorTitle,
        message: event.l10n.snackbarCouldNotSaveToken,
        isError: true,
      );
    }
  }

  List<ApiItem> _applyLocalSort(
      List<ApiItem> list, String sortBy, String sortOrder) {
    final sorted = List<ApiItem>.from(list);
    int mod = sortOrder.toLowerCase() == 'desc' ? -1 : 1;

    sorted.sort((a, b) {
      int cmp;
      switch (sortBy) {
        case 'category':
          cmp = a.category.toLowerCase().compareTo(b.category.toLowerCase());
          break;
        case 'responseTime':
          cmp = a.responseTime.compareTo(b.responseTime);
          break;
        case 'name':
        default:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return cmp * mod;
    });

    return sorted;
  }
}
