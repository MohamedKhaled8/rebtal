import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  const ThemeState(
    this.themeMode, {
    this.primaryColor = ColorsManager.profileAccent,
  });

  ThemeState copyWith({ThemeMode? themeMode, Color? primaryColor}) {
    return ThemeState(
      themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.system)) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'primary_color';

  /// Ignores stale [_loadTheme] results after the user changes theme.
  int _userThemeRevision = 0;

  /// Loads the saved theme and color from SharedPreferences.
  Future<void> _loadTheme() async {
    final revisionAtStart = _userThemeRevision;
    final prefs = await SharedPreferences.getInstance();
    if (revisionAtStart != _userThemeRevision) return;

    final savedThemeIndex = prefs.getInt(_themeKey);
    final savedColorValue = prefs.getInt(_colorKey);

    ThemeMode mode = ThemeMode.system;
    if (savedThemeIndex != null &&
        savedThemeIndex >= 0 &&
        savedThemeIndex < ThemeMode.values.length) {
      mode = ThemeMode.values[savedThemeIndex];
    }

    Color color = ColorsManager.profileAccent;
    if (savedColorValue != null) {
      color = Color(savedColorValue);
    }

    if (revisionAtStart != _userThemeRevision) return;
    emit(ThemeState(mode, primaryColor: color));
  }

  /// Changes the theme and saves the selection.
  void changeTheme(ThemeMode themeMode) {
    _userThemeRevision++;
    emit(state.copyWith(themeMode: themeMode));
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    });
  }

  /// Changes the primary color and saves the selection.
  void changeColor(Color color) {
    emit(state.copyWith(primaryColor: color));
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_colorKey, color.value);
    });
  }

  /// Toggles between light and dark using the effective brightness (handles [ThemeMode.system]).
  void toggleTheme({Brightness? platformBrightness}) {
    final brightness =
        platformBrightness ?? PlatformDispatcher.instance.platformBrightness;
    final isEffectivelyDark = switch (state.themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => brightness == Brightness.dark,
    };
    changeTheme(isEffectivelyDark ? ThemeMode.light : ThemeMode.dark);
  }
}

/// Resolves whether dark UI should be shown for [themeMode].
bool isEffectivelyDarkMode(ThemeMode themeMode, Brightness platformBrightness) {
  return switch (themeMode) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => platformBrightness == Brightness.dark,
  };
}
