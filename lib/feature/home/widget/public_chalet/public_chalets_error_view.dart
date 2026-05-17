import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsErrorView extends StatelessWidget {
  const PublicChaletsErrorView({
    super.key,
    required this.shrinkWrap,
    required this.isDark,
  });

  final bool shrinkWrap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final listPhysics = shrinkWrap
        ? const NeverScrollableScrollPhysics()
        : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

    return ListView(
      shrinkWrap: shrinkWrap,
      physics: listPhysics,
      children: [
        SizedBox(
          height: 280.sh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.spScaled,
                color: ColorsManager.chaletUnavailableRed,
              ),
              SizedBox(height: 16.sh),
              Text(
                context.tr('home_load_error'),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
