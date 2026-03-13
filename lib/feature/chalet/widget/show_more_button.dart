import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ShowMoreButton extends StatelessWidget {
  final bool isDark;
  final Color textColor;

  const ShowMoreButton({
    super.key,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.tr('chalet_detail_show_more'),
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 16.spScaled,
              tablet: 18.spScaled,
              desktop: 20.spScaled,
            ),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            color: textColor,
          ),
        ),
        SizedBox(
          width: stv(
            context: context,
            mobile: 4.sw,
            tablet: 6.sw,
            desktop: 8.sw,
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: stv(
            context: context,
            mobile: 12.spScaled,
            tablet: 14.spScaled,
            desktop: 16.spScaled,
          ),
          color: textColor,
        ),
      ],
    );
  }
}

