import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_palette.dart';

class AdvancedSearchSectionHeader extends StatelessWidget {
  const AdvancedSearchSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
  });

  final String title;
  final IconData icon;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdvancedSearchPalette.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: themeColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
