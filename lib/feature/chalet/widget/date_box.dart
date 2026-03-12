import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class DateBox extends StatelessWidget {
  final String label;
  final String date;
  final bool isDark;

  const DateBox({
    super.key,
    required this.label,
    required this.date,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? ColorsManager.chaletIconBackgroundDark
              : ColorsManager.greyF9FAFB,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ColorsManager.white10 : ColorsManager.greyE5E7EB,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: isDark
                      ? ColorsManager.chaletTextSecondaryDark
                      : ColorsManager.grey6B7280,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ColorsManager.chaletTextSecondaryDark
                        : ColorsManager.grey6B7280,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? ColorsManager.chaletTextPrimaryDark
                    : ColorsManager.grey1F2937,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
