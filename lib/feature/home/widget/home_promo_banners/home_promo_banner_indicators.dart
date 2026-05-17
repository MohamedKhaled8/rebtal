import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';

class HomePromoBannerIndicators extends StatelessWidget {
  const HomePromoBannerIndicators({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: state.promoBannerPage == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: state.promoBannerPage == index
                    ? const Color(0xFF2563EB)
                    : (isDark
                          ? Colors.white30
                          : Colors.black.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}
