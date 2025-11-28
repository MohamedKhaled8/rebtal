import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  //! Initialize the cache.
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  String? getDataString({required String key}) {
    return sharedPreferences.getString(key);
  }

  //! Method to save data in local database using key
  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    }
    if (value is String) {
      return await sharedPreferences.setString(key, value);
    }
    if (value is int) {
      return await sharedPreferences.setInt(key, value);
    }
    return await sharedPreferences.setDouble(key, value);
  }

  //! Method to get data already saved in local database
  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  //! Remove data using specific key
  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  //! Check if local database contains {key}
  bool containsKey({required String key}) {
    return sharedPreferences.containsKey(key);
  }

  //! Clear all data
  Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}
