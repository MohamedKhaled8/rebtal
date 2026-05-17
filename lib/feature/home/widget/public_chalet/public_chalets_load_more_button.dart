import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class PublicChaletsLoadMoreButton extends StatelessWidget {
  const PublicChaletsLoadMoreButton({
    super.key,
    required this.remainingCount,
    required this.onPressed,
  });

  final int remainingCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sw, vertical: 10.sh),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.expand_more,
            color: Colors.white,
            size: 24.spScaled,
          ),
          label: Text(
            '${context.tr('home_show_more')} ($remainingCount ${context.tr('common_chalet')})',
            style: TextStyle(
              fontSize: 16.spScaled,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14.sh),
            backgroundColor: ColorsManager.chaletAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.sp),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
