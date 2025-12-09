import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/data/models/category.dart';
import 'package:public_apis_desktop_client/app/data/models/api.dart'
    as api_model;
import 'package:public_apis_desktop_client/app/services/fetch_api/remote_service.dart';
import 'package:public_apis_desktop_client/app/services/fetch_api/failure.dart';
import 'package:public_apis_desktop_client/app/data/models/AllApis.dart'
    as legacy;

class CategoryApisController extends GetxController {
  late Category category;
  final RxList<api_model.Api> apis = <api_model.Api>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    category = Get.arguments;
    fetchApisByCategory();
  }

  Future<void> fetchApisByCategory() async {
    try {
      isLoading(true);
      errorMessage('');
      final legacyData = await RemoteService.getData();

      // Try to find the matching category by title
      final match = legacyData.firstWhere(
        (item) => item.title == category.name,
        orElse: () => legacy.CategoryApis(title: '', apis: []),
      );

      if (match.title.isEmpty) {
        throw Failure(
          'Not found',
          'No APIs found for this category',
        );
      }

      final mapped = match.apis
          .map((a) => api_model.Api(
                id: '${category.id}-${a.name}',
                name: a.name,
                description: a.description,
                auth: a.auth,
                https: _toBool(a.https),
                cors: _toBool(a.cors),
                link: a.link,
                categoryId: category.id,
              ))
          .toList();

      apis.assignAll(mapped);
    } on Failure catch (e) {
      errorMessage('${e.title}: ${e.content}');
    } catch (e) {
      errorMessage('An unexpected error occurred');
    } finally {
      isLoading(false);
    }
  }

  bool _toBool(String value) {
    final v = value.toLowerCase();
    return v == 'true' || v == 'yes' || v == 'y' || v == '1';
  }

  Future<void> retryFetch() async {
    await fetchApisByCategory();
  }
}
