import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/app_localization.dart';

/// Extension for easy translation access
extension TranslationExtension on BuildContext {
  /// Translate a key using [AppLocalizations]
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
