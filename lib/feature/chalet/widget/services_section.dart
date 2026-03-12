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
    // Extract features from requestData
    final featuresList = requestData['features'] as List?;

    if (featuresList == null || featuresList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 32),
          Text(
            'Additional Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? ColorsManager.chaletTextPrimaryDark
                  : ColorsManager.chaletTextPrimaryLight,
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(featuresList.length, (index) {
              final feature = featuresList[index];

              // Define Palette of Distinct Colors
              final List<Color> palette = [
                ColorsManager.chaletActionBlue,
                ColorsManager.purple8B5CF6,
                ColorsManager.orangeF59E0B,
                ColorsManager.chaletGalleryPink,
                Colors.teal,
                Colors.indigo,
                Colors.blueGrey,
                Colors.green,
                Colors.cyan,
                Colors.deepOrange,
              ];

              // Cycle through palette
              final color = palette[index % palette.length];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    0.08,
                  ), // Always light colored background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(
                      0.3,
                    ), // Always matching colored border
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: color, // Always matching colored icon
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87, // Keep text clearly visible
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
