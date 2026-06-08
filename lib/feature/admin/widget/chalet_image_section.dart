import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class ChaletImageSection extends StatelessWidget {
  final String imageUrl;
  final String location;
  final String docId;

  const ChaletImageSection({
    super.key,
    required this.imageUrl,
    required this.location,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200.sp,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.sp),
            child: AppImageHelper(path: imageUrl, fit: BoxFit.cover, cacheScope: docId),
          ),
        ),
        Positioned(
          top: 2.h,
          left: 2.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: ColorsManager.kPrimaryGradient.colors.first,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.my_location, color: Colors.white, size: 16),
                horizintalSpace(3),
                Text(location, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
