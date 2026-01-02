import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/owner/utils/owner_helper.dart';

/// Modern amenities selection widget with icon-based cards
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
                      'المرافق والخدمات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? ColorManager.white : ColorManager.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اختر جميع المرافق المتوفرة',
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
                    '$selectedCount محدد',
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

              return _BouncyAmenityCard(
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

class _BouncyAmenityCard extends StatefulWidget {
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
  State<_BouncyAmenityCard> createState() => _BouncyAmenityCardState();
}

class _BouncyAmenityCardState extends State<_BouncyAmenityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Quick bounce
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    widget.onTap();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      widget.color.withOpacity(0.2),
                      widget.color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected
                ? null
                : (widget.isDark
                      ? ColorManager.darkBlue2A2E4B.withOpacity(0.5)
                      : ColorManager.grey50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? widget.color
                  : (widget.isDark
                        ? ColorManager.grey800.withOpacity(0.3)
                        : ColorManager.grey300),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
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
                      color: widget.isSelected
                          ? widget.color.withOpacity(0.2)
                          : (widget.isDark
                                ? ColorManager.grey800.withOpacity(0.3)
                                : ColorManager.grey200),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? widget.color
                          : (widget.isDark
                                ? ColorManager.grey400
                                : ColorManager.grey600),
                      size: 24,
                    ),
                  ),
                  // Checkmark Badge
                  if (widget.isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isDark
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
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? widget.color
                        : (widget.isDark
                              ? ColorManager.grey300
                              : ColorManager.grey700),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
