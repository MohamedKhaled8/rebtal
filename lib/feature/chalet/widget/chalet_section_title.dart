import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletSectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const ChaletSectionTitle({
    super.key,
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: stv(
            context: context,
            mobile: 22.spScaled,
            tablet: 26.spScaled,
            desktop: 30.spScaled,
          ),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

