import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const SectionTitle({super.key, required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: isDark
            ? ColorManager.chaletTextPrimaryDark
            : ColorManager.chaletTextPrimaryLight,
        letterSpacing: 0.5,
      ),
    );
  }
}
