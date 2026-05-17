import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/cubit/home_state.dart';
import 'package:rebtal/feature/home/logic/helpers/home_promo_banners_helper.dart';
import 'package:rebtal/feature/home/widget/home_promo_banners/home_promo_banner_tile.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// [PageController] requires [StatefulWidget] for dispose lifecycle.
class HomePromoBannersCarousel extends StatefulWidget {
  const HomePromoBannersCarousel({super.key, required this.banners});

  final List<HomePromoBannerItem> banners;

  @override
  State<HomePromoBannersCarousel> createState() =>
      HomePromoBannersCarouselState();
}

class HomePromoBannersCarouselState extends State<HomePromoBannersCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.promoBannerPage != current.promoBannerPage,
      listener: (context, state) {
        if (!_pageController.hasClients) return;
        _pageController.animateToPage(
          state.promoBannerPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: otv(context: context, portrait: 16.h, landscape: 60.h),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.banners.length,
          onPageChanged: context.read<HomeCubit>().onPromoPageChanged,
          itemBuilder: (context, index) {
            return HomePromoBannerTile(
              banner: widget.banners[index],
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }
}
