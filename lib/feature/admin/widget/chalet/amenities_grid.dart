// AmenitiesGrid widget for displaying amenities
import 'package:flutter/material.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class AmenitiesGrid extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const AmenitiesGrid({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> amenitiesList = [
      {
        'label': 'WiFi',
        'key': 'hasWifi',
        'icon': Icons.wifi,
        'color': Colors.blue,
      },
      {
        'label': 'Pool',
        'key': 'hasPool',
        'icon': Icons.pool,
        'color': Colors.cyan,
      },
      {
        'label': 'AC',
        'key': 'hasAirConditioning',
        'icon': Icons.ac_unit,
        'color': Colors.orange,
      },
      {
        'label': 'Parking',
        'key': 'hasParking',
        'icon': Icons.local_parking,
        'color': Colors.purple,
      },
      {
        'label': 'Garden',
        'key': 'hasGarden',
        'icon': Icons.local_florist,
        'color': Color(0xFF10B981),
      },
      {
        'label': 'BBQ',
        'key': 'hasBBQ',
        'icon': Icons.outdoor_grill,
        'color': Color(0xFFEF4444),
      },
      {
        'label': 'Beach View',
        'key': 'hasBeachView',
        'icon': Icons.beach_access,
        'color': Color(0xFF0EA5E9),
      },
      {
        'label': 'Housekeeping',
        'key': 'hasHousekeeping',
        'icon': Icons.cleaning_services,
        'color': Color(0xFF6366F1),
      },
      {
        'label': 'Pets Allowed',
        'key': 'hasPetsAllowed',
        'icon': Icons.pets,
        'color': Color(0xFFEC4899),
      },
      {
        'label': 'Gym',
        'key': 'hasGym',
        'icon': Icons.fitness_center,
        'color': Color(0xFF14B8A6),
      },
      {
        'label': 'Kitchen',
        'key': 'hasKitchen',
        'icon': Icons.kitchen,
        'color': Color(0xFFF97316),
      },
      {
        'label': 'TV',
        'key': 'hasTV',
        'icon': Icons.tv,
        'color': Color(0xFF6366F1),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: GridView.builder(
              itemCount: amenitiesList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final item = amenitiesList[i];
                final key = item['key'] as String;
                bool enabled = false;

                // Check if amenities list contains the key
                if (requestData['amenities'] is List) {
                  final list = requestData['amenities'] as List;
                  enabled = list.contains(key);
                }
                // Fallback: check boolean flag (for older data or direct map usage)
                else if (requestData[key] == true) {
                  enabled = true;
                }
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: enabled
                        ? (item['color'] as Color).withOpacity(0.08)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: enabled
                          ? (item['color'] as Color)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: enabled
                            ? (item['color'] as Color)
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: enabled ? Colors.black87 : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        enabled ? Icons.check_circle : Icons.cancel,
                        color: enabled ? Colors.green : Colors.red,
                        size: 16,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
