import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rebtal/feature/onboarding/data/models/onboarding_model.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

/// Reusable widget for displaying a single onboarding page
/// Shows Lottie animation, title, and description with smooth animations
class OnboardingPage extends StatelessWidget {
  final OnboardingContent page;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.page,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation with Hero animation for smooth transitions
          Hero(
            tag: 'onboarding_animation_$pageIndex',
            child: FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Container(
                height: 45.h,
                padding: EdgeInsets.all(4.w),
                child: Lottie.asset(
                  page.animationPath,
                  fit: BoxFit.contain,
                  // Disable animation on first frame for better performance
                  frameRate: FrameRate.max,
                ),
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Title with fade-in animation
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Description with fade-in animation
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
