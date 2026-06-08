import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  static Future<void> checkForUpdate() async {
    // InAppUpdate is only supported on Android.
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // بدء تحديث مرن مع فرض الإكمال
        await _forceFlexibleUpdate();
      }
    } catch (e) {
      // يمكن إضافة معالجة الأخطاء هنا
      debugPrint('InAppUpdate checkForUpdate error: $e');
    }
  }

  static Future<void> _forceFlexibleUpdate() async {
    try {
      // بدء التحديث المرن
      await InAppUpdate.startFlexibleUpdate();
      // تطبيق التحديث بمجرد اكتماله
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      // If it fails (e.g. Shorebird patch installed but Play Store mismatch),
      // we gracefully ignore so the app is NOT stuck endlessly!
      debugPrint('InAppUpdate error: $e');
    }
  }
}
