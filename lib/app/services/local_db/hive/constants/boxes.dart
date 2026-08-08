import 'package:hive_flutter/hive_flutter.dart';

abstract class BoxesConstants {
  static const String locals = "locals";
  static const String authTokens = "auth_tokens";
  static const String privacyCache = "privacy_cache";
  BoxesConstants._();
}

class HiveBoxes {
  static Box localsBox = Hive.box(BoxesConstants.locals);
  static Box authTokensBox = Hive.box(BoxesConstants.authTokens);
  static Box privacyCacheBox = Hive.box(BoxesConstants.privacyCache);
  HiveBoxes._();
}
