import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class AmenityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const AmenityCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.chaletCardDark
            : ColorsManager.chaletCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? ColorsManager.white.withOpacity(0.05)
              : ColorsManager.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(isDark ? 0.3 : 0.05),
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
              color: ColorsManager.chaletAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: ColorsManager.chaletAccent),
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
                    ? ColorsManager.chaletTextPrimaryDark
                    : ColorsManager.chaletTextPrimaryLight,
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
