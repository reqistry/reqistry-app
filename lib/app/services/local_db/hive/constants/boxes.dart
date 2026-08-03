import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import '../../../../data/models/favoriteApi.dart';

abstract class BoxesConstants {
  static const String favorites = "favorites";
  static const String locals = "locals";
  static const String hiddenCategories = "hidden_categories";
  static const String authTokens = "auth_tokens";
  static const String privacyCache = "privacy_cache";
  BoxesConstants._();
}

class HiveBoxes {
  static Box<FavoriteApi> favoritesBox =
      Hive.box<FavoriteApi>(BoxesConstants.favorites);
  static Box localsBox = Hive.box(BoxesConstants.locals);
  static Box hiddenCategoriesBox = Hive.box(BoxesConstants.hiddenCategories);
  static Box authTokensBox = Hive.box(BoxesConstants.authTokens);
  static Box privacyCacheBox = Hive.box(BoxesConstants.privacyCache);
  HiveBoxes._();
}
