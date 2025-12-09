import 'package:get/get.dart';

import '../controllers/firestore_favorites_controller.dart';

class FirestoreFavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FirestoreFavoritesController>(
      FirestoreFavoritesController(),
    );
  }
}
