import 'package:flutter/material.dart';

/// Central definition for popular destinations used across the app
class PopularDestinations {
  static const List<PopularDestination> all = [
    PopularDestination(
      key: 'north_coast',
      nameAr: 'الساحل الشمالي',
      nameEn: 'North Coast',
      imageUrl:
          'https://images.pexels.com/photos/1007657/pexels-photo-1007657.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'ain_sokhna',
      nameAr: 'العين السخنة',
      nameEn: 'Ain Sokhna',
      imageUrl:
          'https://images.pexels.com/photos/1450360/pexels-photo-1450360.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'sharm_sheikh',
      nameAr: 'شرم الشيخ',
      nameEn: 'Sharm El Sheikh',
      imageUrl:
          'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'hurghada',
      nameAr: 'الغردقة',
      nameEn: 'Hurghada',
      imageUrl:
          'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'gouna',
      nameAr: 'الجونة',
      nameEn: 'El Gouna',
      imageUrl:
          'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'dahab',
      nameAr: 'دهب',
      nameEn: 'Dahab',
      imageUrl:
          'https://images.pexels.com/photos/1486222/pexels-photo-1486222.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'marsa_alam',
      nameAr: 'مرسى علم',
      nameEn: 'Marsa Alam',
      imageUrl:
          'https://images.pexels.com/photos/2370796/pexels-photo-2370796.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'taba',
      nameAr: 'طابا',
      nameEn: 'Taba',
      imageUrl:
          'https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'nuweiba',
      nameAr: 'نويبع',
      nameEn: 'Nuweiba',
      imageUrl:
          'https://images.pexels.com/photos/2559941/pexels-photo-2559941.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    PopularDestination(
      key: 'ras_mohammed',
      nameAr: 'رأس محمد',
      nameEn: 'Ras Mohammed',
      imageUrl:
          'https://images.pexels.com/photos/258744/pexels-photo-258744.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
  ];

  /// Arabic names list – used when we need only the label (e.g. for features)
  static List<String> get namesAr =>
      all.map((destination) => destination.nameAr).toList(growable: false);

  /// English names list – used when we need only the English label
  static List<String> get namesEn =>
      all.map((destination) => destination.nameEn).toList(growable: false);

  /// Get destination by key
  static PopularDestination? getByKey(String key) {
    try {
      return all.firstWhere((destination) => destination.key == key);
    } catch (e) {
      return null;
    }
  }
}

class PopularDestination {
  final String key;
  final String nameAr;
  final String nameEn;
  final String imageUrl;

  const PopularDestination({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.imageUrl,
  });

  /// Get the localized name based on the current locale
  String getLocalizedName(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'ar' ? nameAr : nameEn;
  }
}
