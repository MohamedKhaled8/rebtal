import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';

class LocationAreaChip extends StatelessWidget {
  const LocationAreaChip({
    super.key,
    required this.areaName,
    required this.isDark,
    required this.isSelected,
  });

  final String areaName;
  final bool isDark;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HomeSearch.filters.value = HomeSearch.filters.value.copyWith(
          query: isSelected ? '' : areaName,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          areaName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }
}
