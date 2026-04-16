import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/app_localization.dart';

/// Extension for easy translation access
extension TranslationExtension on BuildContext {
  /// Resolves UI copy for [key]. Never exposes raw keys to the user: if the
  /// key is missing in both the active locale and English bundles, returns
  /// an empty string (call sites should not concatenate DB values here).
  String tr(String key) {
    final loc = AppLocalizations.of(this);
    if (loc == null) return '';
    return loc.translate(key);
  }
}
