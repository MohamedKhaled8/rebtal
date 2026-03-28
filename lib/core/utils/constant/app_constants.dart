import 'package:flutter/material.dart';

class AppConstants {
  static const List<Map<String, dynamic>> chaletCategories = [
    {'label': 'مسبح', 'value': 'Pool', 'icon': Icons.pool},
    {'label': 'بحر', 'value': 'Sea', 'icon': Icons.beach_access},
    {
      'label': 'عائلي',
      'value': 'Family Gathering',
      'icon': Icons.family_restroom,
    },
    {'label': 'فاخر', 'value': 'Luxury', 'icon': Icons.diamond},
    {'label': 'جبلي', 'value': 'Mountain', 'icon': Icons.landscape},
  ];

  static const List<Map<String, dynamic>> serviceFacilities = [
    {'labelKey': 'facility_pool', 'value': 'hasPool', 'icon': Icons.pool},
    {
      'labelKey': 'facility_parking',
      'value': 'hasParking',
      'icon': Icons.local_parking,
    },
    {
      'labelKey': 'facility_gym',
      'value': 'hasGym',
      'icon': Icons.fitness_center,
    },
    {'labelKey': 'facility_wifi', 'value': 'hasWifi', 'icon': Icons.wifi},
    {'labelKey': 'facility_bars', 'value': 'hasBars', 'icon': Icons.local_bar},
    {
      'labelKey': 'facility_playground',
      'value': 'hasPlayground',
      'icon': Icons.child_care,
    },
    {
      'labelKey': 'facility_ac',
      'value': 'hasAirConditioning',
      'icon': Icons.ac_unit,
    },
    {'labelKey': 'facility_garden', 'value': 'hasGarden', 'icon': Icons.yard},
    {
      'labelKey': 'facility_bbq',
      'value': 'hasBBQ',
      'icon': Icons.outdoor_grill,
    },
    {
      'labelKey': 'facility_beach_view',
      'value': 'hasBeachView',
      'icon': Icons.beach_access,
    },
    {
      'labelKey': 'facility_housekeeping',
      'value': 'hasHousekeeping',
      'icon': Icons.cleaning_services,
    },
    {
      'labelKey': 'facility_pets',
      'value': 'hasPetsAllowed',
      'icon': Icons.pets,
    },
    {
      'labelKey': 'facility_kitchen',
      'value': 'hasKitchen',
      'icon': Icons.kitchen,
    },
    {'labelKey': 'facility_tv', 'value': 'hasTV', 'icon': Icons.tv},
    {
      'labelKey': 'facility_breakfast',
      'value': 'hasBreakfast',
      'icon': Icons.free_breakfast,
    },
  ];
}
