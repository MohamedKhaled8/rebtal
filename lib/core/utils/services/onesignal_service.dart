import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class OneSignalService {
  // ⚠️ تم تحديث القيم ببياناتك الصحيحة
  static const String _appId = "4f2b6648-33f3-4d34-a324-81347e1fb020";
  static const String _restApiKey =
      "os_v2_app_j4vwmsbt6ngtjizeqe2h4h5qedr5qmflcm2uysnscrv6eazqjlyfckpwuolqtalw7bqeahtsimvtfr4apqrjffqfiojks7y4pqyqzky";

  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  /// تهيئة OneSignal (Updated for v5.0+)
  Future<void> initialize() async {
    try {
      if (_appId == "YOUR_ONESIGNAL_APP_ID") {
        debugPrint("⚠️ OneSignal App ID is missing!");
        return;
      }

      // 1. Set Log Level (Optional)
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // 2. Initialize
      // Note: In v5, initialize is synchronous-like but sets up the SDK
      OneSignal.initialize(_appId);

      // 3. Request Permission
      // The user will be prompted to allow notifications
      await OneSignal.Notifications.requestPermission(true);

      debugPrint("✅ OneSignal initialized successfully");
    } catch (e) {
      debugPrint("❌ Error initializing OneSignal: $e");
    }
  }

  /// تسجيل المستخدم الحالي (لربطه بـ user_id الخاص بنا)
  Future<void> login(String userId) async {
    try {
      // In v5: login replaces setExternalUserId
      OneSignal.login(userId);
      debugPrint("✅ OneSignal login: $userId");
    } catch (e) {
      debugPrint("❌ Error logging in to OneSignal: $e");
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      // In v5: logout replaces removeExternalUserId
      OneSignal.logout();
      debugPrint("✅ OneSignal logout");
    } catch (e) {
      debugPrint("❌ Error logging out from OneSignal: $e");
    }
  }

  /// إرسال إشعار لمستخدم محدد (client-side using REST API)
  Future<bool> sendNotification({
    required String title,
    required String body,
    required String targetUserId,
    Map<String, dynamic>? data,
  }) async {
    if (_restApiKey.startsWith("YOUR_")) {
      debugPrint("⚠️ OneSignal REST API Key is missing!");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'headings': {'en': title, 'ar': title},
          'contents': {'en': body, 'ar': body},
          'include_aliases': {
            'external_id': [targetUserId],
          },
          'target_channel': 'push',
          'data': data,
          // Omit large_icon: wrong URL or CDN issues show a bad image; OS uses app icon.
          // Android specific settings for sound and priority
          'android_channel_id': 'rebtal_channel_id',
          'priority': 10,
          'android_visibility': 1, // Public visibility
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Notification sent successfully to $targetUserId");
        return true;
      } else {
        debugPrint("❌ Failed to send notification: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error sending notification: $e");
      return false;
    }
  }
}
