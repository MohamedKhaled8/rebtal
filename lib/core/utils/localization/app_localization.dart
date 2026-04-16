import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  Locale? local;

  AppLocalizations({this.local});

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static LocalizationsDelegate<AppLocalizations> delegate =
      const _AppLocalizationsDelegate();

  /// Loaded locale (e.g. ar).
  late Map<String, String> jsonStrings;

  /// English strings used when a key is missing in the active locale.
  static Map<String, String>? _englishStrings;

  Future<void> loadLangJson() async {
    final string = await rootBundle.loadString(
      'assets/localization/${local!.languageCode}.json',
    );
    final jsons = json.decode(string) as Map<String, dynamic>;
    jsonStrings = jsons.map((key, value) {
      return MapEntry(key, value.toString());
    });

    _englishStrings ??= await _loadBundleMap('en');
  }

  static Future<Map<String, String>> _loadBundleMap(String languageCode) async {
    final raw = await rootBundle.loadString(
      'assets/localization/$languageCode.json',
    );
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Never returns [key] — missing keys fall back to English, then empty.
  String translate(String key) {
    final primary = jsonStrings[key];
    if (primary != null && primary.isNotEmpty) {
      return primary;
    }
    final en = _englishStrings?[key];
    if (en != null && en.isNotEmpty) {
      return en;
    }
    return '';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appLocalizations = AppLocalizations(local: locale);
    await appLocalizations.loadLangJson();
    return appLocalizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
