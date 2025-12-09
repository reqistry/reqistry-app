import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/submit_api_controller/submit_api_controller.dart';

class SubmitApiBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SubmitApiController>(SubmitApiController());
  }
}
