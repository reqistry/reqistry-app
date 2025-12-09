import 'package:get/get.dart';

class MainShellController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  void selectTab(int index) {
    selectedTabIndex(index);
  }

  void navigateToSearch() {
    selectedTabIndex(1);
  }
}
