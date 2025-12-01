import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class PropertyFeaturesCard extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const PropertyFeaturesCard({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final bedrooms = requestData['bedrooms']?.toString() ?? 'N/A';
    final bathrooms = requestData['bathrooms']?.toString() ?? 'N/A';
    final chaletArea = requestData['chaletArea']?.toString();
    final childrenCount = requestData['childrenCount']?.toString();
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? ColorManager.chaletCardDark
            : ColorManager.chaletCardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? ColorManager.chaletTextPrimaryDark
                  : ColorManager.chaletTextPrimaryLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.0, // Adjusted to prevent overflow
            children: [
              FeatureItem(
                icon: Icons.bed_rounded,
                color: const Color(0xFF3B82F6),
                value: bedrooms,
                label: 'Bedrooms',
                isDark: isDark,
              ),
              FeatureItem(
                icon: Icons.bathtub_rounded,
                color: const Color(0xFF8B5CF6),
                value: bathrooms,
                label: 'Bathrooms',
                isDark: isDark,
              ),
              if (chaletArea != null && chaletArea.isNotEmpty)
                FeatureItem(
                  icon: Icons.square_foot_rounded,
                  color: const Color(0xFFF59E0B),
                  value: '$chaletArea m²',
                  label: 'Area',
                  isDark: isDark,
                ),
              if (childrenCount != null)
                FeatureItem(
                  icon: Icons.child_care_rounded,
                  color: const Color(0xFFEC4899),
                  value: childrenCount,
                  label: 'Children',
                  isDark: isDark,
                ),
            ],
          ),

          // Features Section
          if (requestData['features'] != null &&
              (requestData['features'] as List).isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(
              height: 1,
              color: isDark ? ColorManager.white10 : const Color(0xFFEEEEEE),
            ),
            const SizedBox(height: 24),
            Text(
              'Additional Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? ColorManager.chaletTextPrimaryDark
                    : ColorManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (requestData['features'] as List)
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorManager.chaletIconBackgroundDark
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorManager.transparent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? ColorManager.chaletTextSecondaryDark
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool isDark;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? ColorManager.chaletIconBackgroundDark
                  : ColorManager.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? ColorManager.chaletTextPrimaryDark
                        : const Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? ColorManager.chaletTextSecondaryDark
                        : ColorManager.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
