import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';
import 'package:api_scout/app/services/local_db/hive/hidden_categories_db.dart';

import '../../../data/models/favoriteApi.dart';
import 'favorites_db.dart';
import 'locals_box.dart';

class LocalDatabase {
  static final _instance = LocalDatabase._();
  static LocalDatabase get instance => _instance;
  LocalDatabase._();

  static const String localFavorites = 'local_favorites';
  static const String fcmCache = 'fcm_cache';
  static const String apiDetailCache = 'api_detail_cache';

  Future<void> initDatabases() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FavoriteApiAdapter());
    await Future.wait(
      <Future>[
        Hive.openBox<FavoriteApi>(BoxesConstants.favorites),
        Hive.openBox(BoxesConstants.locals),
        Hive.openBox(BoxesConstants.hiddenCategories),
        Hive.openBox<Map<String, dynamic>>(localFavorites),
        Hive.openBox(BoxesConstants.authTokens),
        Hive.openBox(fcmCache),
        Hive.openBox(apiDetailCache),
        Hive.openBox(BoxesConstants.privacyCache),
      ],
    );
  }

  Future<void> clearAllLocalData() async {
    final counts = await Future.wait<int>([
      FavoritesDB.instance.clear(),
      LocalsDB.instance.clear(),
      HiddenCategoriesDB.instance.clear(),
      HiveBoxes.authTokensBox.clear(),
      Hive.box<Map<String, dynamic>>(localFavorites).clear(),
      Hive.box(fcmCache).clear(),
      Hive.box(apiDetailCache).clear(),
    ]);
    debugPrint('Cleared local data: ${counts.join(', ')}');
  }
}
