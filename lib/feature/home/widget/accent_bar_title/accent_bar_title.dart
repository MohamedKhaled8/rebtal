
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:responsive_screen_master/extensions/orienation_type_value.dart';
import 'package:responsive_screen_master/extensions/responsive_nums.dart';
import 'package:responsive_screen_master/extensions/screen_type_value.dart';

class AccentBarTitle extends StatelessWidget {
  final String title;

  const AccentBarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: stv(
          context: context,
          mobile: 16.sw,
          tablet: 24.sw,
          desktop: 32.sw,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: stv(
                  context: context,
                  mobile: 4.sw,
                  tablet: 6.sw,
                  desktop: 8.sw,
                ),
                height: otv(
                  context: context,
                  portrait: 20.sh,
                  landscape: 16.sh,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(4.sw),
                ),
              ),
              SizedBox(
                width: stv(
                  context: context,
                  mobile: 10.sw,
                  tablet: 14.sw,
                  desktop: 18.sw,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: stv(
                    context: context,
                    mobile: 18.spScaled,
                    tablet: 22.spScaled,
                    desktop: 26.spScaled,
                  ),
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              context.tr('home_view_all'),
              style: TextStyle(
                color: const Color(0xFF2563EB),
                fontSize: stv(
                  context: context,
                  mobile: 13.spScaled,
                  tablet: 15.spScaled,
                  desktop: 17.spScaled,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
