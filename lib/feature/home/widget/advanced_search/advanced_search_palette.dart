import 'package:flutter/material.dart';

class AdvancedSearchPalette {
  static const Color primaryGreen = Color(0xFF10B981);

  static Color background(bool isDark) =>
      isDark ? const Color(0xFF151520) : const Color(0xFFFFFFFF);

  static Color card(bool isDark) =>
      isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF9FAFB);
}
