import 'package:flutter/material.dart';

abstract class ColorsManager {
  ColorsManager._();

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
  static const black87 = Colors.black87;
  static const mainColor = Color(0xFF011520);
  static const black26 = Colors.black26;
  static const white = Colors.white;
  static const white24 = Colors.white24;
  static const white38 = Colors.white38;
  static const white54 = Colors.white54;
  static const white70 = Colors.white70;
  static const white10 = Colors.white10;
  static const gray = Colors.grey;
  static const grey = Colors.grey;
  static const red = Colors.red;
  static const green = Colors.green;
  static const yellow = Colors.yellow;
  static const yellowDark = Color(0xFFe48400);
  static const amber = Colors.amber;
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
  // Chalet Detail Page Colors
  static const chaletBackgroundDark = Colors.black;
  static const chaletBackgroundLight = Colors.white;

  static const chaletCardDark = Color(0xFF0B0F0D);
  static const chaletCardLight = Colors.white;

  static const chaletTextPrimaryDark = Colors.white;
  static const chaletTextPrimaryLight = Color(0xFF1A1A2E);

  static const chaletTextSecondaryDark = Color(0xFFB0B0B0);
  static const chaletTextSecondaryLight = Color(0xFF555555);

  static const chaletIconBackgroundDark = Color(0xFF1A1F1C);
  static const chaletIconBackgroundLight = Color(0xFFF0F4FF);

  static const chaletAccent = Color(
    0xFF1ED760,
  ); // Using the green accent from Navbar

  // Chalet Availability Colors
  static const chaletAvailableGreen = Color(0xFF10B981);
  static const chaletAvailableDarkGreen = Color(0xFF064E3B);
  static const chaletAvailableLightGreen = Color(0xFFECFDF5);

  static const chaletUnavailableRed = Color(0xFFEF4444);
  static const chaletUnavailableDarkRed = Color(0xFF7F1D1D);
  static const chaletUnavailableLightRed = Color(0xFFFEF2F2);

  static const chaletGrey100 = Color(0xFFF3F4F6);
  static const chaletGrey200 = Color(0xFFE5E7EB);
  static const chaletGrey400 = Color(0xFF9CA3AF);
  static const chaletGrey500 = Color(0xFF6B7280);
  static const chaletGrey600 = Color(0xFF4B5563);
  static const chaletGrey800 = Color(0xFF1F2937);
  static const chaletGrey50 = Color(0xFFF9FAFB);

  // Chalet Action Colors
  static const chaletActionGreen = Color(0xFF10B981);
  static const chaletActionDarkGreen = Color(0xFF059669);
  static const chaletActionRed = Color(0xFFEF4444);
  static const chaletActionDarkRed = Color(0xFFDC2626);
  static const chaletActionBlue = Color(0xFF3B82F6);
  static const chaletActionDarkBlue = Color(0xFF1D4ED8);
  static const chaletActionGrey = Color(0xFF6B7280);
  static const chaletActionDarkGrey = Color(0xFF4B5563);

  // Chalet Gallery Colors
  static const chaletGalleryPink = Color(0xFFEC4899);
  static const chaletGalleryBlue = Color(0xFF3B82F6);
  static const chaletGalleryTextDark = Color(0xFF1F2937);

  // Common UI Colors
  static const blue2563EB = Color(0xFF2563EB);
  static const green3DDC84 = Color(0xFF3DDC84);
  static const yellowEAB308 = Color(0xFFEAB308);
  static const cyan06B6D4 = Color(0xFF06B6D4);
  static const purple8B5CF6 = Color(0xFF8B5CF6);
  static const whatsappGreen = Color(0xFF25D366);
  static const teal00A896 = Color(0xFF00A896);
  static const green17B85A = Color(0xFF17B85A);
  static const skyBlue0EA5E9 = Color(0xFF0EA5E9);
  static const darkBackground121212 = Color(0xFF121212);
  static const darkSurface1E1E1E = Color(0xFF1E1E1E);
  static const lightBackgroundF5F7FA = Color(0xFFF5F7FA);
  static const lightGreyF9F9F9 = Color(0xFFF9F9F9);
  static const darkBackground0F0F1E = Color(0xFF0F0F1E);
  static const darkBlue1A1A2E = Color(0xFF1A1A2E);
  static const darkGrey252540 = Color(0xFF252540);
  static const darkGrey2A2A3E = Color(0xFF2A2A3E);
  static const indigo6366F1 = Color(0xFF6366F1);
  static const redE94560 = Color(0xFFE94560);
  static const goldFFD700 = Color(0xFFFFD700);
  static const darkGreen0A2A1D = Color(0xFF0A2A1D);
  static const darkBlue16213E = Color(0xFF16213E);
  static const navyBlue0F3460 = Color(0xFF0F3460);
  static const darkBlue2A2E4B = Color(0xFF2A2E4B);
  static const darkBlue161B30 = Color(0xFF161B30);
  static const darkBlue1E2235 = Color(0xFF1E2235);
  static const darkBlue2E335A = Color(0xFF2E335A);
  static const darkBlue2A2D4E = Color(0xFF2A2D4E);
  static const darkGreen1E3C29 = Color(0xFF1E3C29);
  static const darkGreen0F1E15 = Color(0xFF0F1E15);
  static const lightGreenE8F5E9 = Color(0xFFE8F5E9);
  static const darkBackground0F121F = Color(0xFF0F121F);
  static const lightBackgroundF8FAFF = Color(0xFFF8FAFF);
  static const darkBlue1B1E2B = Color(0xFF1B1E2B);
  static const darkBackground0A0E27 = Color(0xFF0A0E27);

  // Grey shades (matching Material Colors.grey.shadeXXX)
  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);

  // Welcome Screen Colors
  static const darkSlate0F172A = Color(0xFF0F172A);
  static const blue1E40AF = Color(0xFF1E40AF);
  static const blue93C5FD = Color(0xFF93C5FD);
  static const purple312E81 = Color(0xFF312E81);
  static const greyE2E8F0 = Color(0xFFE2E8F0);
  static const blueEFF6FF = Color(0xFFEFF6FF);
  static const skyBlue38BDF8 = Color(0xFF38BDF8);
  static const slate475569 = Color(0xFF475569);

  // Additional Colors
  static const darkGrey2D2D44 = Color(0xFF2D2D44);
  static const purple764BA2 = Color(0xFF764BA2);
  static const greyF9FAFB = Color(0xFFF9FAFB);
  static const greyE5E7EB = Color(0xFFE5E7EB);
  static const grey6B7280 = Color(0xFF6B7280);
  static const grey374151 = Color(0xFF374151);
  static const grey1F2937 = Color(0xFF1F2937);
  static const grey9CA3AF = Color(0xFF9CA3AF);
  static const greyF3F4F6 = Color(0xFFF3F4F6);
  static const orangeF59E0B = Color(0xFFF59E0B);
  static const cyan00C9FF = Color(0xFF00C9FF);
  static const green92FE9D = Color(0xFF92FE9D);
  static const redFF3B30 = Color(0xFFFF3B30);
}
