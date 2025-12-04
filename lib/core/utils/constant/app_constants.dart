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
    {'label': 'مسبح', 'value': 'hasPool', 'icon': Icons.pool},
    {
      'label': 'موقف سيارات',
      'value': 'hasParking',
      'icon': Icons.local_parking,
    },
    {'label': 'نادي رياضي', 'value': 'hasGym', 'icon': Icons.fitness_center},
    {'label': 'واي فاي', 'value': 'hasWifi', 'icon': Icons.wifi},
    {'label': 'مشروبات', 'value': 'hasBars', 'icon': Icons.local_bar},
    {'label': 'منطقة لعب', 'value': 'hasPlayground', 'icon': Icons.child_care},
    {'label': 'تكييف', 'value': 'hasAirConditioning', 'icon': Icons.ac_unit},
    {'label': 'حديقة', 'value': 'hasGarden', 'icon': Icons.yard},
    {'label': 'شواء', 'value': 'hasBBQ', 'icon': Icons.outdoor_grill},
    {
      'label': 'إطلالة بحرية',
      'value': 'hasBeachView',
      'icon': Icons.beach_access,
    },
    {
      'label': 'تنظيف',
      'value': 'hasHousekeeping',
      'icon': Icons.cleaning_services,
    },
    {'label': 'حيوانات أليفة', 'value': 'hasPetsAllowed', 'icon': Icons.pets},
    {'label': 'مطبخ', 'value': 'hasKitchen', 'icon': Icons.kitchen},
    {'label': 'تلفاز', 'value': 'hasTV', 'icon': Icons.tv},
    {'label': 'إفطار', 'value': 'hasBreakfast', 'icon': Icons.free_breakfast},
  ];
}
