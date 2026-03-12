import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class AppTheme {
  static ThemeData getLightTheme({
    Color primaryColor = ColorsManager.primaryColor,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: ColorsManager.white,
      useMaterial3: true,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorsManager.white,
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        iconTheme: IconThemeData(color: ColorsManager.black),
        titleTextStyle: TextStyle(
          color: ColorsManager.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData getDarkTheme({
    Color primaryColor = ColorsManager.primaryColor,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: ColorsManager.scaffolColor,
      useMaterial3: true,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        backgroundColor: ColorsManager.transparent,
        iconTheme: IconThemeData(color: ColorsManager.white),
        titleTextStyle: TextStyle(
          color: ColorsManager.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: ColorsManager.scaffolColor,
      ),
    );
  }
}
