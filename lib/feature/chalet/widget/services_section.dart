import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ServicesSection extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final bool isDark;

  const ServicesSection({
    super.key,
    required this.requestData,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final amenitiesList = [
      {'label': 'Swimming Pool', 'key': 'hasPool', 'icon': Icons.pool},
      {'label': 'Parking', 'key': 'hasParking', 'icon': Icons.local_parking},
      {
        'label': 'Fitness Center',
        'key': 'hasGym',
        'icon': Icons.fitness_center,
      },
      {'label': 'WiFi', 'key': 'hasWifi', 'icon': Icons.wifi},
      {
        'label': '${requestData['bedrooms'] ?? 'N/A'} Bedrooms',
        'key': 'bedrooms',
        'icon': Icons.bed,
      },
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

    // Filter enabled amenities
    final enabledAmenities = amenitiesList.where((item) {
      final key = item['key'] as String;
      if (key == 'bedrooms') return true;
      if (requestData['amenities'] is List) {
        return (requestData['amenities'] as List).contains(key);
      }
      return requestData[key] == true;
    }).toList();

    if (enabledAmenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services & Facilities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark
                ? ColorManager.chaletTextPrimaryDark
                : ColorManager.chaletTextPrimaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: enabledAmenities.length,
          itemBuilder: (context, index) {
            final item = enabledAmenities[index];
            return _buildAmenityCard(
              label: item['label'] as String,
              icon: item['icon'] as IconData,
              isDark: isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmenityCard({
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ColorManager.chaletCardDark
            : ColorManager.chaletCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorManager.chaletAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: ColorManager.chaletAccent),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
