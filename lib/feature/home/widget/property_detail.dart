import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class PropertyDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const PropertyDetail({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ColorManager.kPrimaryGradient.colors.first, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: ColorManager.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
