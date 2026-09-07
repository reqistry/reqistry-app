import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/data/models/categories_response.dart';
import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/services/fetch_api/failure.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/l10n/app_localizations.dart';

part 'home_categories_state.dart';

class HomeCategoriesCubit extends Cubit<HomeCategoriesState> {
  List<Category> _allCategories = [];

  HomeCategoriesCubit() : super(const HomeCategoriesState()) {
    fetchCategories();
  }

  Future<void> fetchCategories({AppLocalizations? l10n}) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final response = await RemoteService.getCategories(l10n: l10n);
      final categoryList = response.toCategories();
      final sortedCategories = _sortByTrendy(categoryList);
      _allCategories = sortedCategories;
      emit(state.copyWith(
        isLoading: false,
        categories: sortedCategories,
        filteredCategories: sortedCategories,
        categoriesResponse: response,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: '${e.title}: ${e.content}',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: l10n?.unexpectedErrorOccurred(e.toString()) ?? 'An unexpected error occurred: $e',
      ));
    }
  }

  void filterCategories(String query) {
    final q = query.toLowerCase();
    List<Category> filtered;

    if (q.isEmpty) {
      filtered = _allCategories.toList();
    } else {
      filtered = _allCategories
          .where((category) =>
              category.name.toLowerCase().contains(q) ||
              (category.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    emit(state.copyWith(
      filteredCategories: _sortByTrendy(filtered),
    ));
  }

  List<Category> _sortByTrendy(List<Category> categoryList) {
    final sorted = List<Category>.from(categoryList);
    sorted.sort((a, b) {
      if (a.hasTrendyBorder != b.hasTrendyBorder) {
        return a.hasTrendyBorder ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  Future<void> retryFetch({AppLocalizations? l10n}) async {
    await fetchCategories(l10n: l10n);
  }
}
