import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isFirstRun {
    return _prefs.getBool('isFirstRun') ?? true;
  }

  static Future<void> setFirstRunDone() async {
    await _prefs.setBool('isFirstRun', false);
  }

  static bool get notificationsEnabled {
    return _prefs.getBool('notificationsEnabled') ?? false;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool('notificationsEnabled', value);
  }
}











