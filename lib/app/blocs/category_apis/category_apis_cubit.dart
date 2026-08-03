import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/fetch_api/failure.dart';

part 'category_apis_state.dart';

class CategoryApisCubit extends Cubit<CategoryApisState> {
  late String _categoryTitle;
  late String _categoryId;

  CategoryApisCubit({required Object argument})
      : super(const CategoryApisState()) {
    _resolveArgument(argument);
  }

  void _resolveArgument(Object arg) {
    if (arg is CategoryApis) {
      _categoryTitle = arg.title;
      _categoryId = _slug(arg.title);
      emit(state.copyWith(
        category: arg,
        categoryTitle: _categoryTitle,
      ));
    } else if (arg is Category) {
      _categoryTitle = arg.name;
      _categoryId = arg.id.isNotEmpty ? arg.id : _slug(arg.name);
      emit(state.copyWith(
        categoryTitle: _categoryTitle,
        categoryMeta: arg,
        category: CategoryApis(title: _categoryTitle, apis: const []),
      ));
    } else if (arg is String) {
      _categoryTitle = arg;
      _categoryId = _slug(arg);
      emit(state.copyWith(
        categoryTitle: _categoryTitle,
        category: CategoryApis(title: _categoryTitle, apis: const []),
      ));
    } else {
      emit(state.copyWith(
        errorMessage: 'Invalid navigation argument: ${arg.runtimeType}',
      ));
      return;
    }

    fetchApisByCategory();
  }

  Future<void> fetchApisByCategory() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      Category? meta = state.categoryMeta;
      try {
        final detail = await RemoteService.getCategory(_categoryId);
        meta = Category(
          id: detail.id,
          name: detail.name,
          description: detail.description,
          imageUrl: detail.imageUrl,
          apiCount: detail.apiCount,
          tags: detail.tags,
          hasTrendyBorder: detail.isTrending,
        );
        _categoryTitle = meta.name.isNotEmpty ? meta.name : _categoryTitle;
      } catch (_) {}

      final match =
          await RemoteService.getCategoryApis(categoryId: _categoryId);

      if (match.apis.isEmpty) {
        throw Failure('Not found', 'No APIs found for this category');
      }

      emit(state.copyWith(
        isLoading: false,
        apis: match.apis,
        category: match,
        categoryMeta: meta,
        categoryTitle: _categoryTitle,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: '${e.title}: ${e.content}',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> retryFetch() async {
    await fetchApisByCategory();
  }

  String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
