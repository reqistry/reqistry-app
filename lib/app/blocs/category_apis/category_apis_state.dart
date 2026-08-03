part of 'category_apis_cubit.dart';

class CategoryApisState extends Equatable {
  final CategoryApis? category;
  final Category? categoryMeta;
  final String categoryTitle;
  final List<ApiItem> apis;
  final bool isLoading;
  final String errorMessage;

  const CategoryApisState({
    this.category,
    this.categoryMeta,
    this.categoryTitle = '',
    this.apis = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  CategoryApisState copyWith({
    CategoryApis? category,
    Category? categoryMeta,
    String? categoryTitle,
    List<ApiItem>? apis,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryApisState(
      category: category ?? this.category,
      categoryMeta: categoryMeta ?? this.categoryMeta,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      apis: apis ?? this.apis,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        category,
        categoryMeta,
        categoryTitle,
        apis,
        isLoading,
        errorMessage,
      ];
}
