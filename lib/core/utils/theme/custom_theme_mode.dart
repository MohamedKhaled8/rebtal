import 'package:flutter/material.dart';

class CustomThemeMode {
  List<Color?> gredientColors;
  Color? switchColor;
  Color? thumbColor;
  Color? switchBgColor;
  CustomThemeMode({
    required this.gredientColors,
    this.switchColor,
    this.thumbColor,
    this.switchBgColor,
  });
}