import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  const ThemeState(
    this.themeMode, {
    this.primaryColor = const Color(0xFF1ED760),
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

  /// Loads the saved theme and color from SharedPreferences
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeKey);
    final savedColorValue = prefs.getInt(_colorKey);

    ThemeMode mode = ThemeMode.system;
    if (savedThemeIndex != null) {
      mode = ThemeMode.values[savedThemeIndex];
    }

    Color color = const Color(0xFF1ED760);
    if (savedColorValue != null) {
      color = Color(savedColorValue);
    }

    emit(ThemeState(mode, primaryColor: color));
  }

  /// Changes the theme and saves the selection
  void changeTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    emit(state.copyWith(themeMode: themeMode));
  }

  /// Changes the primary color and saves the selection
  void changeColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
    emit(state.copyWith(primaryColor: color));
  }

  /// Toggles between light and dark mode
  void toggleTheme() {
    final ThemeMode newMode;
    if (state.themeMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      // If light or system, switch to dark
      newMode = ThemeMode.dark;
    }
    changeTheme(newMode);
  }
}
