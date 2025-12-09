import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/main_shell_controller.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/share_app_controller/share_app_controller.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/privacy_controller/privacy_controller.dart';

class MainShellBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(MainShellController());
    Get.put<ShareAppController>(ShareAppController());
    Get.put<PrivacyController>(PrivacyController());
  }
}
