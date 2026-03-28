import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class PropertyDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool compact;

  const PropertyDetail({
    super.key,
    required this.icon,
    required this.text,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: ColorsManager.kPrimaryGradient.colors.first,
          size: compact ? 16 : 18,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: ColorsManager.gray,
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
