import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit() : super(ServicesInitial());

  void loadAmenities(Map<String, dynamic> requestData) {
    final amenitiesList = [
      {'label': 'Swimming Pool', 'key': 'hasPool', 'icon': Icons.pool},
      {'label': 'Parking', 'key': 'hasParking', 'icon': Icons.local_parking},
      {
        'label': 'Fitness Center',
        'key': 'hasGym',
        'icon': Icons.fitness_center,
      },
      {'label': 'WiFi', 'key': 'hasWifi', 'icon': Icons.wifi},
      {'label': 'Bar', 'key': 'hasBars', 'icon': Icons.local_bar},
      {'label': 'Playground', 'key': 'hasPlayground', 'icon': Icons.child_care},
      {
        'label': 'Air Conditioning',
        'key': 'hasAirConditioning',
        'icon': Icons.ac_unit,
      },
      {'label': 'Garden', 'key': 'hasGarden', 'icon': Icons.yard},
      {'label': 'BBQ Area', 'key': 'hasBBQ', 'icon': Icons.outdoor_grill},
      {
        'label': 'Beach View',
        'key': 'hasBeachView',
        'icon': Icons.beach_access,
      },
      {
        'label': 'Housekeeping',
        'key': 'hasHousekeeping',
        'icon': Icons.cleaning_services,
      },
      {'label': 'Pets Allowed', 'key': 'hasPetsAllowed', 'icon': Icons.pets},
      {'label': 'Kitchen', 'key': 'hasKitchen', 'icon': Icons.kitchen},
      {'label': 'TV', 'key': 'hasTV', 'icon': Icons.tv},
      {
        'label': 'Breakfast',
        'key': 'hasBreakfast',
        'icon': Icons.free_breakfast,
      },
    ];

    final enabledAmenities = amenitiesList.where((item) {
      final key = item['key'] as String;

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
