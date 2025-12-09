import 'package:get/get.dart';

import '../controllers/home_controller/home_categories_controller.dart';
import '../controllers/privacy_controller/privacy_controller.dart';

class HomeCategoriesPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeCategoriesController>(
        HomeCategoriesController(context: Get.context!));
    Get.put<PrivacyController>(PrivacyController(), permanent: true);
  }
}
