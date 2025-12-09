import 'package:get/get.dart';

import '../controllers/favorites_controller/favorites_controller.dart';
import '../controllers/firestore_favorites_controller.dart';

class FavoritesViewBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<FavoritesController>(FavoritesController());
    Get.put<FirestoreFavoritesController>(FirestoreFavoritesController());
  }
}
