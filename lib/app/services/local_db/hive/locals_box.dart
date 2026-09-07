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

  Future<void> deleteWithKey(String key) async {
    return HiveBoxes.localsBox.delete(key);
  }

  Future<int> clear() async {
    return HiveBoxes.localsBox.clear();
  }
}
