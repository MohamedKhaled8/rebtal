import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit() : super(ServicesInitial());

  void loadAmenities(
    Map<String, dynamic> requestData, {
    bool preferDayUseAmenities = false,
  }) {
    final amenitiesList = [
      {'l10nKey': 'chalet_pool', 'key': 'hasPool', 'icon': Icons.pool},
      {'l10nKey': 'chalet_parking', 'key': 'hasParking', 'icon': Icons.local_parking},
      {
        'l10nKey': 'chalet_gym',
        'key': 'hasGym',
        'icon': Icons.fitness_center,
      },
      {'l10nKey': 'chalet_wifi', 'key': 'hasWifi', 'icon': Icons.wifi},
      {'l10nKey': 'chalet_bar', 'key': 'hasBars', 'icon': Icons.local_bar},
      {'l10nKey': 'chalet_playground', 'key': 'hasPlayground', 'icon': Icons.child_care},
      {
        'l10nKey': 'chalet_ac',
        'key': 'hasAirConditioning',
        'icon': Icons.ac_unit,
      },
      {'l10nKey': 'chalet_garden', 'key': 'hasGarden', 'icon': Icons.yard},
      {'l10nKey': 'chalet_bbq', 'key': 'hasBBQ', 'icon': Icons.outdoor_grill},
      {
        'l10nKey': 'chalet_beach_view',
        'key': 'hasBeachView',
        'icon': Icons.beach_access,
      },
      {
        'l10nKey': 'chalet_housekeeping',
        'key': 'hasHousekeeping',
        'icon': Icons.cleaning_services,
      },
      {'l10nKey': 'chalet_pets', 'key': 'hasPetsAllowed', 'icon': Icons.pets},
      {'l10nKey': 'chalet_kitchen', 'key': 'hasKitchen', 'icon': Icons.kitchen},
      {'l10nKey': 'chalet_tv', 'key': 'hasTV', 'icon': Icons.tv},
      {
        'l10nKey': 'chalet_breakfast',
        'key': 'hasBreakfast',
        'icon': Icons.free_breakfast,
      },
    ];

    final enabledAmenities = amenitiesList.where((item) {
      final key = item['key'] as String;
      final useDayUseList = preferDayUseAmenities &&
          requestData['dayUseAmenities'] is List &&
          (requestData['dayUseAmenities'] as List).isNotEmpty;

      if (useDayUseList) {
        final list = requestData['dayUseAmenities'] as List;
        final shortKey = key.startsWith('has')
            ? key.substring(3).toLowerCase()
            : key;
        return list.contains(key) || list.contains(shortKey);
      }

      // 1. Check direct boolean property (e.g. hasWifi: true)
      if (requestData[key] == true) return true;

      // 2. Check in amenities list (support both 'hasWifi' and 'wifi')
      if (requestData['amenities'] is List) {
        final list = requestData['amenities'] as List;
        // Check exact match or short version (remove 'has' prefix)
        final shortKey = key.startsWith('has')
            ? key.substring(3).toLowerCase()
            : key;

        return list.contains(key) || list.contains(shortKey);
      }
      return false;
    }).toList();

    emit(ServicesLoaded(enabledAmenities));
  }
}
