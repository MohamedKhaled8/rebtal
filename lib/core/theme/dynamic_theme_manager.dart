import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/theme/theme_cubit.dart';

class DynamicThemeManager {
  // Private constructor to prevent instantiation
  DynamicThemeManager._();

  /// Changes the primary color of the application.
  /// Usage: DynamicThemeManager.setPrimaryColor(context, Colors.red);
  static void setPrimaryColor(BuildContext context, Color color) {
    context.read<ThemeCubit>().changeColor(color);
  }

  /// Toggles between Light and Dark mode.
  /// Usage: DynamicThemeManager.toggleTheme(context);
  static void toggleTheme(BuildContext context) {
    context.read<ThemeCubit>().toggleTheme();
  }

  /// Returns the current primary color.
  /// Usage: Color myColor = DynamicThemeManager.getPrimaryColor(context);
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  /// Returns true if the current mode is Dark.
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Returns the scaffold background color.
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }
}
