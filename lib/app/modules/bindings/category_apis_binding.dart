import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/category_apis_controller/category_apis_controller.dart';

class CategoryApisBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CategoryApisController>(CategoryApisController());
  }
}
