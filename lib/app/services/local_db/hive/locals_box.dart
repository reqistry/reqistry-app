import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';

class LocalsDB {
  static final LocalsDB _instance = LocalsDB._();
  static LocalsDB get instance => _instance;

  LocalsDB._();

  dynamic getWithKey(String key) {
    return HiveBoxes.localsBox.get(key);
  }

  Future<void> putWithKey(String key, value) async {
    return HiveBoxes.localsBox.put(key, value);
  }

  Future<int> clear() async {
    return HiveBoxes.localsBox.clear();
  }
}
