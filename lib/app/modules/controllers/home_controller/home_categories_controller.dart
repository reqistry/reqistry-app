import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/data/models/categories_response.dart';
import 'package:public_apis_desktop_client/app/data/models/category.dart';
import 'package:public_apis_desktop_client/app/services/fetch_api/failure.dart';
import 'package:public_apis_desktop_client/app/services/fetch_api/remote_service.dart';
import '../../../services/in_app_review/in_app_review.dart';
import '../../../services/local_db/hive/locals_box.dart';

class HomeCategoriesController extends GetxController {
  BuildContext? context;
  LocalsDB locals = LocalsDB.instance;

  final Rx<CategoriesResponse?> categoriesResponse =
      Rx<CategoriesResponse?>(null);
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Category> filteredCategories = <Category>[].obs;

  final TextEditingController searchController = TextEditingController();
  static BuildContext? _context;

  bool get isFirstTimeOpenedTheAppAfterUpdate =>
      locals.getWithKey("isFirstTimeOpenedTheAppAfterUpdate") ?? true;

  final _hiveService = InAppReview();

  HomeCategoriesController({this.context}) {
    _context = context ?? Get.context;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    searchController.addListener(filterCategories);
  }

  Future<void> fetchCategories() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await RemoteService.getCategories();
      categoriesResponse(response);

      // Fetch categories with remote trendy categories list
      final categoryList = await response.toCategories();
      final sortedCategories = _sortByTrendy(categoryList);
      categories.assignAll(sortedCategories);
      filteredCategories.assignAll(sortedCategories);
    } on Failure catch (e) {
      errorMessage('${e.title}: ${e.content}');
    } catch (e) {
      errorMessage('An unexpected error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  void filterCategories() {
    final query = searchController.text.toLowerCase();
    List<Category> filtered;

    if (query.isEmpty) {
      filtered = categories.toList();
    } else {
      filtered = categories
          .where((category) =>
              category.name.toLowerCase().contains(query) ||
              (category.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Apply trendy sorting to filtered results
    filteredCategories.assignAll(_sortByTrendy(filtered));
  }

  /// Sort categories by trendy status (trendy first, then alphabetically)
  List<Category> _sortByTrendy(List<Category> categoryList) {
    final sorted = List<Category>.from(categoryList);
    sorted.sort((a, b) {
      // Trendy categories come first
      if (a.hasTrendyBorder != b.hasTrendyBorder) {
        return a.hasTrendyBorder ? -1 : 1;
      }
      // Within same trendy status, sort alphabetically
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  Future<void> retryFetch() async {
    await fetchCategories();
  }

  void navigateToCategoryApis(Category category) {
    Get.toNamed('/category-apis', arguments: category);
  }

  @override
  void onReady() {
    if (isFirstTimeOpenedTheAppAfterUpdate) {
      showNewAppUpdateDialog(_context!);
    }
    _hiveService.handleShowingTheReviewRequest();
  }

  void showNewAppUpdateDialog(BuildContext context) {
    // Implementation for showing update dialog
    // This can be empty or show an actual dialog if needed
  }

  @override
  void onClose() {
    // searchController.dispose();
    super.onClose();
  }
}
