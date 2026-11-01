import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceConstant {
  static String cachedUser = 'cachedUser';
  static String viewMode = 'viewMode';
}

class SharedPreferenceController {
  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> setString({required String key, required String value}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> getString({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> remove({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(key);
  }
}
