part of 'home_categories_cubit.dart';

class HomeCategoriesState extends Equatable {
  final CategoriesResponse? categoriesResponse;
  final List<Category> categories;
  final List<Category> filteredCategories;
  final bool isLoading;
  final String errorMessage;

  const HomeCategoriesState({
    this.categoriesResponse,
    this.categories = const [],
    this.filteredCategories = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  HomeCategoriesState copyWith({
    CategoriesResponse? categoriesResponse,
    List<Category>? categories,
    List<Category>? filteredCategories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeCategoriesState(
      categoriesResponse: categoriesResponse ?? this.categoriesResponse,
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        categoriesResponse,
        categories,
        filteredCategories,
        isLoading,
        errorMessage,
      ];
}
