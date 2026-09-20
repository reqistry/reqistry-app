import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';
import 'locals_box.dart';

class LocalDatabase {
  static final _instance = LocalDatabase._();
  static LocalDatabase get instance => _instance;
  LocalDatabase._();

  static const String fcmCache = 'fcm_cache';
  static const String apiDetailCache = 'api_detail_cache';

  Future<void> initDatabases() async {
    await Hive.initFlutter();
    await Future.wait(
      <Future>[
        Hive.openBox(BoxesConstants.locals),
        Hive.openBox(fcmCache),
        Hive.openBox(apiDetailCache),
        Hive.openBox(BoxesConstants.privacyCache),
      ],
    );
  }

  Future<void> clearAllLocalData() async {
    final counts = await Future.wait<int>([
      LocalsDB.instance.clear(),
      HiveBoxes.authTokensBox.clear(),
      Hive.box(fcmCache).clear(),
      Hive.box(apiDetailCache).clear(),
    ]);
    debugPrint('Cleared local data: ${counts.join(', ')}');
  }
}
