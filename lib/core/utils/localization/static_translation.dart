import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads the same JSON as [AppLocalizations] without [BuildContext], for
/// services (notifications, background) that must resolve keys to real text.
class StaticTranslation {
  StaticTranslation._();

  static Map<String, String>? _ar;
  static Map<String, String>? _en;
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final arRaw = await rootBundle.loadString('assets/localization/ar.json');
    final enRaw = await rootBundle.loadString('assets/localization/en.json');
    _ar = _parseMap(arRaw);
    _en = _parseMap(enRaw);
    _loaded = true;
  }

  static Map<String, String> _parseMap(String raw) {
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Same key as [AppCubit._localeKey].
  static Future<String> currentLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale') ?? 'ar';
  }

  /// Resolves [key] for push/local notifications; replaces `{param}` placeholders.
  static String tr(
    String key, {
    String? languageCode,
    Map<String, dynamic>? params,
  }) {
    final lang = languageCode ?? 'ar';
    final primary = lang == 'ar' ? _ar : _en;
    final fallback = lang == 'ar' ? _en : _ar;
    String s = primary?[key] ?? fallback?[key] ?? key;
    if (s.isEmpty) {
      s = key;
    }
    if (params != null) {
      for (final e in params.entries) {
        s = s.replaceAll('{${e.key}}', e.value?.toString() ?? '');
      }
    }
    return s;
  }
}
