import 'package:get/get.dart';
import 'package:public_apis_desktop_client/app/modules/controllers/app_settings_controller/app_settings_controller.dart';

class AppSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppSettingsController>(AppSettingsController());
  }
}
