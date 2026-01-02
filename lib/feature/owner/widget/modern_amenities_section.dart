import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';

class ModernAmenitiesSection extends StatelessWidget {
  final Map<String, bool> selectedAmenities;
  final Function(String, bool) onAmenityChanged;

  const ModernAmenitiesSection({
    super.key,
    required this.selectedAmenities,
    required this.onAmenityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final selectedCount = selectedAmenities.values.where((v) => v).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ColorManager.darkBlue1A1A2E : ColorManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorManager.grey800.withOpacity(0.3)
              : ColorManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorManager.black.withOpacity(0.3)
                : ColorManager.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorManager.purple764BA2.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: ColorManager.purple764BA2,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities & Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? ColorManager.white : ColorManager.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select all that apply',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? ColorManager.grey400
                            : ColorManager.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.purple764BA2.withOpacity(0.2),
                        ColorManager.blue2563EB.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColorManager.purple764BA2.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$selectedCount selected',
                    style: const TextStyle(
                      color: ColorManager.purple764BA2,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Amenities Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: OwnerHelper.allAmenities.length,
            itemBuilder: (context, index) {
              final amenity = OwnerHelper.allAmenities[index];
              final key = amenity['key'] as String;
              final isSelected = selectedAmenities[key] ?? false;
              final color = amenity['color'] as Color;
              final icon = amenity['icon'] as IconData;
              final label = amenity['label'] as String;

              return _ModernAmenityCard(
                label: label,
                icon: icon,
                color: color,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => onAmenityChanged(key, !isSelected),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModernAmenityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ModernAmenityCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                    ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
                    : ColorManager.grey50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? ColorManager.grey800.withOpacity(0.3)
                      : ColorManager.grey300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : (isDark
                              ? ColorManager.grey800.withOpacity(0.3)
                              : ColorManager.grey200),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? color
                        : (isDark
                              ? ColorManager.grey400
                              : ColorManager.grey600),
                    size: 24,
                  ),
                ),
                // Checkmark Badge
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? ColorManager.darkBlue1A1A2E
                              : ColorManager.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: ColorManager.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : (isDark ? ColorManager.grey300 : ColorManager.grey700),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
