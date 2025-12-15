import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/data/models/category_apis.dart';
import 'package:public_apis_desktop_client/app/data/models/category.dart';
import 'package:public_apis_desktop_client/app/services/fetch_api/remote_service.dart';
import 'package:public_apis_desktop_client/app/services/fetch_api/failure.dart';

class CategoryApisController extends GetxController {
  late CategoryApis category;
  late String _categoryTitle;
  final RxList<ApiItem> apis = <ApiItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;

    // Support multiple argument types to avoid route data mismatch issues
    if (arg is CategoryApis) {
      category = arg;
      _categoryTitle = arg.title;
    } else if (arg is Category) {
      _categoryTitle = arg.name;
      category = CategoryApis(title: _categoryTitle, apis: const []);
    } else if (arg is String) {
      _categoryTitle = arg;
      category = CategoryApis(title: _categoryTitle, apis: const []);
    } else {
      errorMessage('Invalid navigation argument: ${arg.runtimeType}');
      return;
    }

    fetchApisByCategory();
  }

  Future<void> fetchApisByCategory() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await RemoteService.getData();

      // Try to find the matching category by title
      final match = response.getCategoryByTitle(_categoryTitle);

      if (match == null) {
        throw Failure(
          'Not found',
          'No APIs found for this category',
        );
      }

      apis.assignAll(match.apis);
    } on Failure catch (e) {
      errorMessage('${e.title}: ${e.content}');
    } catch (e) {
      errorMessage('An unexpected error occurred');
    } finally {
      isLoading(false);
    }
  }

  Future<void> retryFetch() async {
    await fetchApisByCategory();
  }
}
