import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StorageAdapter {
  static const String _key = 'SurveySparrowUUID';

  Future<void> saveData(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }

  Future<String?> loadData({bool isUuid = false}) async {
    if (isUuid) return const Uuid().v4();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
