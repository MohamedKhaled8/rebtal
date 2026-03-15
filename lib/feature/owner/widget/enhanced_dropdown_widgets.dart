import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/constant/popular_destinations.dart';

// ==========================================
// Custom Widgets for Enhanced Dropdown
// ==========================================

class AnimatedRotationSwitcher extends StatelessWidget {
  final bool isExpanded;
  final Color color;

  const AnimatedRotationSwitcher({
    super.key,
    required this.isExpanded,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: animation.drive(
            Tween(begin: 0.0, end: isExpanded ? 0.5 : 0.0),
          ),
          child: child,
        );
      },
      child: Icon(
        isExpanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        key: ValueKey(isExpanded),
        color: color,
        size: 24,
      ),
    );
  }
}

class ElegantDropdownItem extends StatelessWidget {
  final PopularDestination destination;
  final bool isDark;

  const ElegantDropdownItem({
    super.key,
    required this.destination,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Destination Names
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? destination.nameAr
                      : destination.nameEn,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ColorsManager.white : ColorsManager.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
