import 'package:flutter/material.dart';

abstract class ColorManager {
  ColorManager._();

  static const primaryColor = Colors.blue;
  static const transparent = Colors.transparent;
  static const pColor = Color(0xFF6F35A5);
  static const kPColor = Color(0x0ff1e6ff);
  static const purple = Colors.purple;
  static const cyan = Colors.cyan;
  static const brown = Colors.brown;
  static const teal = Colors.teal;
  static const scaffolColor = Color.fromARGB(255, 1, 18, 28);
  static const Color lightBlue = Color(0xFF80D8FF); // Add lightBlue
  static const black = Colors.black;
  static const mainColor = Color(0xFF011520);
  static const black26 = Colors.black26;
  static const white = Colors.white;
  static const white24 = Colors.white24;
  static const white70 = Colors.white70;
  static const gray = Colors.grey;
  static const red = Colors.red;
  static const green = Colors.green;
  static const yellow = Colors.yellow;
  static const yellowDark = Color(0xFFe48400);
  static const orange = Colors.orange;
  static const pink = Color(0xFF443070);
  static const mainBlue = Color.fromARGB(255, 4, 101, 153);
  static const kSecondaryColor = Color(0xFF8B94BC);
  static const kGreenColor = Color(0xFF6AC259);
  static const kRedColor = Color(0xFFE92E30);
  static const kGrayColor = Color(0xFFC1C1C1);
  static const kBlackColor = Color(0xFF101010);
  static const kPrimaryGradient = LinearGradient(
    colors: [Color(0xFF46A0AE), Color(0xFF00FFCB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Profile Page Colors
  static const profileBackgroundDark = Color(0xFF001409);
  static const profileBackgroundLight = Color(0xFFF5F5F5);
  static const profileSurfaceDark = Color(0xFF0B0F0D);
  static const profileSurfaceLight = Colors.white;
  static const profileSurfaceAltDark = Color(0xFF111614);
  static const profileSurfaceAltLight = Colors.white;
  static const profileAccent = Color(0xFF1ED760);
  static const profileGradientDark1 = Color(0xFF0B0F0D);
  static const profileGradientDark2 = Color(0xFF001409);

  static const profileTextPrimaryDark = Colors.white;
  static const profileTextPrimaryLight = Colors.black;

  static Color getProfileBackground(bool isDark) =>
      isDark ? profileBackgroundDark : profileBackgroundLight;

  static Color getProfileSurface(bool isDark) =>
      isDark ? profileSurfaceDark : profileSurfaceLight;

  static Color getProfileSurfaceAlt(bool isDark) =>
      isDark ? profileSurfaceAltDark : profileSurfaceAltLight;

  static Color getProfileTextPrimary(bool isDark) =>
      isDark ? profileTextPrimaryDark : profileTextPrimaryLight;

  // Owner Bookings Page Colors
  static const bookingsBackgroundDark = Color(0xFF0A0E27);
  static const bookingsBackgroundLight = Color(0xFFF8F9FA);
  static const bookingsCardDark = Color(0xFF1A1F3A);
  static const bookingsCardLight = Color(0xFFFFFFFF);
  static const bookingsAccentPrimary = Color(0xFF667EEA);
  static const bookingsAccentSecondary = Color(0xFF764BA2);
  static const bookingsSuccessGreen = Color(0xFF10B981);
  static const bookingsErrorRed = Color(0xFFEF4444);
  static const bookingsWarningOrange = Color(0xFFF59E0B);
  static const bookingsInfoBlue = Color(0xFF3B82F6);
  static const bookingsTextPrimaryDark = Color(0xFFFFFFFF);
  static const bookingsTextPrimaryLight = Color(0xFF1F2937);
  static const bookingsTextSecondaryDark = Color(0xFFD1D5DB);
  static const bookingsTextSecondaryLight = Color(0xFF6B7280);
  static const bookingsBorderDark = Color(0xFF374151);
  static const bookingsBorderLight = Color(0xFFE5E7EB);
}
