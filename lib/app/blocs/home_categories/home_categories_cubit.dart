import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/data/models/categories_response.dart';
import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/services/fetch_api/failure.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/in_app_review/in_app_review.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

part 'home_categories_state.dart';

class HomeCategoriesCubit extends Cubit<HomeCategoriesState> {
  final LocalsDB _locals = LocalsDB.instance;
  final InAppReview _inAppReview = InAppReview();
  List<Category> _allCategories = [];

  HomeCategoriesCubit() : super(const HomeCategoriesState()) {
    fetchCategories();
  }

  bool get isFirstTimeOpenedTheAppAfterUpdate =>
      _locals.getWithKey("isFirstTimeOpenedTheAppAfterUpdate") ?? true;

  Future<void> fetchCategories() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      final response = await RemoteService.getCategories();
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
        errorMessage: 'An unexpected error occurred: $e',
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

  Future<void> retryFetch() async {
    await fetchCategories();
  }

  void onReady() {
    if (isFirstTimeOpenedTheAppAfterUpdate) {
      // showNewAppUpdateDialog can be triggered here
    }
    _inAppReview.handleShowingTheReviewRequest();
  }
}
