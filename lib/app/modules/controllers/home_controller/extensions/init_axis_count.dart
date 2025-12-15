import '../home_controller.dart';

extension InitCrossAxisCountExtension on HomeController {
  void initGridCrossAxisCount() {
    crossAxisCount = locals.getWithKey("crossAxisCount") ?? 2;
  }
}
