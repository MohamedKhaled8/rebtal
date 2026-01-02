import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

/// Modern amenities selection widget with icon-based cards
class AmenitiesSelectionSection extends StatelessWidget {
  final Map<String, bool> selectedAmenities;
  final Function(String, bool) onAmenityChanged;

  const AmenitiesSelectionSection({
    super.key,
    required this.selectedAmenities,
    required this.onAmenityChanged,
  });

  static const List<Map<String, dynamic>> allAmenities = [
    {
      'key': 'hasWifi',
      'label': 'WiFi',
      'icon': Icons.wifi,
      'color': ColorManager.chaletActionBlue,
    },
    {
      'key': 'hasPool',
      'label': 'Pool',
      'icon': Icons.pool,
      'color': ColorManager.cyan06B6D4,
    },
    {
      'key': 'hasAirConditioning',
      'label': 'Air Conditioning',
      'icon': Icons.ac_unit,
      'color': ColorManager.bookingsWarningOrange,
    },
    {
      'key': 'hasParking',
      'label': 'Parking',
      'icon': Icons.local_parking,
      'color': ColorManager.purple8B5CF6,
    },
    {
      'key': 'hasGarden',
      'label': 'Garden',
      'icon': Icons.local_florist,
      'color': ColorManager.chaletActionGreen,
    },
    {
      'key': 'hasBBQ',
      'label': 'BBQ Area',
      'icon': Icons.outdoor_grill,
      'color': ColorManager.chaletUnavailableRed,
    },
    {
      'key': 'hasBeachView',
      'label': 'Beach View',
      'icon': Icons.beach_access,
      'color': ColorManager.skyBlue0EA5E9,
    },
    {
      'key': 'hasHousekeeping',
      'label': 'Housekeeping',
      'icon': Icons.cleaning_services,
      'color': ColorManager.indigo6366F1,
    },
    {
      'key': 'hasPetsAllowed',
      'label': 'Pets Allowed',
      'icon': Icons.pets,
      'color': ColorManager.chaletGalleryPink,
    },
    {
      'key': 'hasGym',
      'label': 'Gym',
      'icon': Icons.fitness_center,
      'color': ColorManager.teal,
    },
    {
      'key': 'hasKitchen',
      'label': 'Kitchen',
      'icon': Icons.kitchen,
      'color': ColorManager.orange,
    },
    {
      'key': 'hasTV',
      'label': 'TV',
      'icon': Icons.tv,
      'color': ColorManager.indigo6366F1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorManager.gray.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorManager.kPrimaryGradient.colors.first.withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.room_service,
                  color: ColorManager.kPrimaryGradient.colors.first,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities & Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select all available amenities',
                      style: TextStyle(fontSize: 14, color: ColorManager.gray),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: allAmenities.length,
            itemBuilder: (context, index) {
              final amenity = allAmenities[index];
              final key = amenity['key'] as String;
              final isSelected = selectedAmenities[key] ?? false;
              final color = amenity['color'] as Color;
              final icon = amenity['icon'] as IconData;
              final label = amenity['label'] as String;

              return _AmenityCard(
                label: label,
                icon: icon,
                color: color,
                isSelected: isSelected,
                onTap: () => onAmenityChanged(key, !isSelected),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AmenityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmenityCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : ColorManager.grey300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : ColorManager.grey200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? color : ColorManager.grey600,
                    size: 24,
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: ColorManager.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: ColorManager.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : ColorManager.grey700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
