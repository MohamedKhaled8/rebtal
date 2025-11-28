import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  Locale? local;

  AppLocalizations({
    this.local,
  });



  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static LocalizationsDelegate<AppLocalizations> delegate =
      const _AppLocalizationsDelegate();
  late Map<String, String> jsonStrings;
  Future loadLangJson() async {
    String string = await rootBundle
        .loadString('assets/localization/${local!.languageCode}.json');
    Map<String, dynamic> jsons = json.decode(string);
    jsonStrings = jsons.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String translate(String key) => jsonStrings[key] ?? "";
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
