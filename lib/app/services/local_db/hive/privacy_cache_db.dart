import 'package:api_scout/app/services/local_db/hive/constants/boxes.dart';

class PrivacyCacheDB {
  static final PrivacyCacheDB _instance = PrivacyCacheDB._();
  static PrivacyCacheDB get instance => _instance;

  PrivacyCacheDB._();

  static const String _contentKey = 'content';

  String? get content => HiveBoxes.privacyCacheBox.get(_contentKey) as String?;

  Future<void> saveContent(String content) async {
    return HiveBoxes.privacyCacheBox.put(_contentKey, content);
  }
}
