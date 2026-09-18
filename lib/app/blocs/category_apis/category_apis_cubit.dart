import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/category.dart';
import 'package:api_scout/app/data/models/api_detail.dart' show slugifyApiName;
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/services/fetch_api/failure.dart';
import 'package:api_scout/l10n/app_localizations.dart';

part 'category_apis_state.dart';

class CategoryApisCubit extends Cubit<CategoryApisState> {
  late String _categoryTitle;
  late String _categoryId;
  AppLocalizations? _l10n;

  CategoryApisCubit({required Object argument, AppLocalizations? l10n})
      : super(const CategoryApisState()) {
    _l10n = l10n;
    _resolveArgument(argument);
  }

  void _resolveArgument(Object arg) {
    if (arg is CategoryApis) {
      _categoryTitle = arg.title;
      _categoryId = slugifyApiName(arg.title);
      emit(state.copyWith(
        category: arg,
        categoryTitle: _categoryTitle,
      ));
    } else if (arg is Category) {
      _categoryTitle = arg.name;
      _categoryId = arg.id.isNotEmpty ? arg.id : slugifyApiName(arg.name);
      emit(state.copyWith(
        categoryTitle: _categoryTitle,
        categoryMeta: arg,
        category: CategoryApis(title: _categoryTitle, apis: const []),
      ));
    } else if (arg is String) {
      _categoryTitle = arg;
      _categoryId = slugifyApiName(arg);
      emit(state.copyWith(
        categoryTitle: _categoryTitle,
        category: CategoryApis(title: _categoryTitle, apis: const []),
      ));
    } else {
      emit(state.copyWith(
        errorMessage: _l10n?.categoryApisInvalidArgument(arg.runtimeType.toString()) ?? 'Invalid navigation argument: ${arg.runtimeType}',
      ));
      return;
    }

    fetchApisByCategory();
  }

  Future<void> fetchApisByCategory({AppLocalizations? l10n}) async {
    final loc = l10n ?? _l10n;
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
      Category? meta = state.categoryMeta;
      try {
        final detail = await RemoteService.getCategory(_categoryId, l10n: loc);
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
          await RemoteService.getCategoryApis(categoryId: _categoryId, l10n: loc);

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
        errorMessage: loc?.categoryApisUnexpectedError ?? 'An unexpected error occurred',
      ));
    }
  }

  Future<void> retryFetch({AppLocalizations? l10n}) async {
    await fetchApisByCategory(l10n: l10n);
  }
}
