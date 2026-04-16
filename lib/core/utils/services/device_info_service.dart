import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Returns a formatted string like "Samsung Galaxy S24" or "Apple iPhone 15 Pro"
  static Future<String> getDeviceType() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return 'Web - ${webInfo.browserName.name}';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final brand = androidInfo.brand; // e.g. "Samsung"
        final model = androidInfo.model; // e.g. "SM-S921B"
        final sdkInt = androidInfo.version.sdkInt; // e.g. 34
        final release = androidInfo.version.release; // e.g. "14"
        return '${_capitalize(brand)} $model (Android $release, SDK $sdkInt)';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final model = iosInfo.model; // e.g. "iPhone"
        final systemName = iosInfo.systemName; // e.g. "iOS"
        final systemVersion = iosInfo.systemVersion; // e.g. "17.4"
        final utsname = iosInfo.utsname.machine; // e.g. "iPhone16,1"
        return '$model ($utsname) - $systemName $systemVersion';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return 'Windows Desktop - ${windowsInfo.computerName}';
      }
      return '${Platform.operatingSystem} ${Platform.localHostname}';
    } catch (e) {
      debugPrint('⚠️ Failed to get device info: $e');
      // Fallback using Dart's built-in platform info if the plugin fails 
      // (which happens if cold restart is needed after adding the package)
      return '${Platform.operatingSystem} (${Platform.operatingSystemVersion})';
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
