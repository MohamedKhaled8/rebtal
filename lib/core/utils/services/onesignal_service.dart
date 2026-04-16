import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OneSignal: يقرأ من `.env` إن وُجد؛ وإلا يستخدم القيم الافتراضية لمشروعك
/// (للتشغيل الفوري). للإنتاج الأفضل: إرسال Push من السيرفر فقط.
class OneSignalService {
  static const String _defaultAppId = '4f2b6648-33f3-4d34-a324-81347e1fb020';

  /// لا تُضمّن REST API Key داخل التطبيق (يُعتبر سر). استخدم `.env` محلياً فقط،
  /// وفي الإنتاج أرسل الإشعارات من السيرفر/Cloud Functions.
  static const String _defaultRestApiKey = '';

  static String get _appId {
    final e = dotenv.env['ONESIGNAL_APP_ID']?.trim();
    if (e != null && e.isNotEmpty && !e.startsWith('YOUR_')) return e;
    return _defaultAppId;
  }

  static String get _restApiKey {
    final k = dotenv.env['ONESIGNAL_REST_API_KEY']?.trim();
    if (k != null && k.isNotEmpty && !k.startsWith('YOUR_')) return k;
    return _defaultRestApiKey;
  }

  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  Future<void> initialize() async {
    try {
      if (_appId == 'YOUR_ONESIGNAL_APP_ID') {
        return;
      }

      OneSignal.initialize(_appId);
      await OneSignal.Notifications.requestPermission(true);
    } catch (e) {}
  }

  Future<void> login(String userId) async {
    try {
      OneSignal.login(userId);
    } catch (e) {}
  }

  Future<void> logout() async {
    try {
      OneSignal.logout();
    } catch (e) {}
  }

  /// يرسل عبر OneSignal REST (مفتاح من `.env` أو الافتراضي في الكود).
  Future<bool> sendNotification({
    required String title,
    required String body,
    required String targetUserId,
    Map<String, dynamic>? data,
  }) async {
    final key = _restApiKey;
    if (key.isEmpty) {
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $key',
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
          'android_channel_id': 'rebtal_channel',
          'priority': 10,
          'android_visibility': 1,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
