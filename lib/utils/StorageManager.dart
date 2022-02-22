import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static bool storagePermissionCached = null;

  static Future<bool> checkPermission() async {
    if(storagePermissionCached == null) {
      storagePermissionCached = (await Permission.storage.request()).isGranted;
      return storagePermissionCached;
    }
    if(!storagePermissionCached) {
      Map<Permission, PermissionStatus> permissions = await [Permission.storage].request();
      storagePermissionCached = permissions[Permission.storage].isGranted;
      return storagePermissionCached;

    }
    return storagePermissionCached;
  }

  static Future<String> readValue(String key) async {
    await checkPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = await prefs.get(key);
    return value;
  }

  static void deleteValue(String key) async {
    await checkPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static void storeValue(String key, String value) async {
    await checkPermission();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<bool> readBoolValue(String key) async {
    await checkPermission();
    if(storagePermissionCached) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool value = await prefs.getBool(key);
      return value;
    }
  }

  static void storeBoolValue(String key, bool value) async {
    await checkPermission();
    if(storagePermissionCached){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    }
  }

  static Future<double> readDoubleValue(String key) async {
    await checkPermission();
    if(storagePermissionCached) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double value = await prefs.getDouble(key);
      return value;
    }
  }

  static void storeDoubleValue(String key, double value) async {
    await checkPermission();
    if(storagePermissionCached){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(key, value);
    }
  }
}