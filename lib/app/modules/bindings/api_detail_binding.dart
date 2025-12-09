import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/api_detail_controller/api_detail_controller.dart';

class ApiDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiDetailController());
  }
}
