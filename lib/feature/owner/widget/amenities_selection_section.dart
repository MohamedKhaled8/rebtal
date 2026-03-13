import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';

/// Modern amenities selection widget with icon-based cards.
class AmenitiesSelectionSection extends StatelessWidget {
  final Map<String, bool> selectedAmenities;
  final Function(String, bool) onAmenityChanged;

  const AmenitiesSelectionSection({
    super.key,
    required this.selectedAmenities,
    required this.onAmenityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    var selectedCount = selectedAmenities.values.where((v) => v).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? ColorsManager.darkBlue1A1A2E : ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? ColorsManager.grey800.withOpacity(0.3)
              : ColorsManager.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ColorsManager.black.withOpacity(0.3)
                : ColorsManager.black.withOpacity(0.05),
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
                  color: ColorsManager.purple764BA2.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: ColorsManager.purple764BA2,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('chalet_what_offers'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? ColorsManager.white
                            : ColorsManager.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('owner_select_amenities_hint'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? ColorsManager.grey400
                            : ColorsManager.grey600,
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
                        ColorsManager.purple764BA2.withOpacity(0.2),
                        ColorsManager.blue2563EB.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColorsManager.purple764BA2.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$selectedCount ${context.tr('owner_selected_count')}',
                    style: const TextStyle(
                      color: ColorsManager.purple764BA2,
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

              return _BouncyAmenityCard(
                label: context.tr(
                  key == 'hasWifi'
                      ? 'chalet_wifi'
                      : key == 'hasPool'
                      ? 'chalet_pool'
                      : key == 'hasAirConditioning'
                      ? 'chalet_ac'
                      : key == 'hasParking'
                      ? 'chalet_parking'
                      : key == 'hasGarden'
                      ? 'chalet_garden'
                      : key == 'hasBBQ'
                      ? 'chalet_bbq'
                      : key == 'hasBeachView'
                      ? 'chalet_beach_view'
                      : key == 'hasHousekeeping'
                      ? 'chalet_housekeeping'
                      : key == 'hasPetsAllowed'
                      ? 'chalet_pets'
                      : key == 'hasGym'
                      ? 'chalet_gym'
                      : key == 'hasKitchen'
                      ? 'chalet_kitchen'
                      : key == 'hasTV'
                      ? 'chalet_tv'
                      : label,
                ),
                icon: icon,
                color: color,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => onAmenityChanged(key, !isSelected),
              );
            },
          ),
          // Additional features removed to prevent duplication as requested
        ],
      ),
    );
  }
}

class _BouncyAmenityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _BouncyAmenityCard({
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
        duration: const Duration(milliseconds: 200),
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
                    ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
                    : ColorsManager.grey50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? ColorsManager.grey800.withOpacity(0.3)
                      : ColorsManager.grey300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : (isDark
                          ? ColorsManager.grey800.withOpacity(0.3)
                          : ColorsManager.grey200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : (isDark ? ColorsManager.grey400 : ColorsManager.grey600),
                size: 24,
              ),
            ),

            // Checkmark Badge
            // Removed for cleaner look in "light" version, or can be kept if desired.
            // Keeping it simple as per "light" request.
            const SizedBox(height: 8),

            // Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? color
                      : (isDark
                            ? ColorsManager.grey300
                            : ColorsManager.grey700),
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
