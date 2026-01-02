import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class AppTheme {
  static ThemeData getLightTheme({
    Color primaryColor = ColorManager.primaryColor,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: ColorManager.white,
      useMaterial3: true,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorManager.white,
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        iconTheme: IconThemeData(color: ColorManager.black),
        titleTextStyle: TextStyle(
          color: ColorManager.black,
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
    Color primaryColor = ColorManager.primaryColor,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: ColorManager.scaffolColor,
      useMaterial3: true,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0.0,
        backgroundColor: ColorManager.transparent,
        iconTheme: IconThemeData(color: ColorManager.white),
        titleTextStyle: TextStyle(
          color: ColorManager.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: ColorManager.scaffolColor,
      ),
    );
  }
}
