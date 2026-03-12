import 'package:flutter/material.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Modern logo container
        Container(
          width: stv(
            context: context,
            mobile: 20.w,
            tablet: 90.w,
            desktop: 100.w,
          ),
          height: stv(
            context: context,
            mobile: 10.h,
            tablet: 90.h,
            desktop: null,
          ),
          decoration: BoxDecoration(
            color: ColorsManager.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.house_siding_rounded,
            size: 5.h,
            color: ColorsManager.skyBlue0EA5E9,
          ),
        ),
        const SizedBox(height: 20),

        // App title
        SizedBox(
          width: double.infinity, // يخلي النص ياخد عرض الشاشة بالكامل
          child: Text(
            'ChaletBooker',
            textAlign: TextAlign.center, // يخلي السطر الأول والتاني في النص
            softWrap: true,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: ColorsManager.white,
            ),
          ),
        ),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Text(
            'Your Gateway to Mountain Retreats',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 20.sp,
              color: ColorsManager.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
