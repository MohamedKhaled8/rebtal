import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/logic/helpers/home_promo_banners_helper.dart';
import 'package:rebtal/feature/home/widget/home_promo_banners/home_promo_banner_indicators.dart';
import 'package:rebtal/feature/home/widget/home_promo_banners/home_promo_banners_carousel.dart';

class HomePromoBanners extends StatelessWidget {
  const HomePromoBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final banners = HomePromoBannersHelper.resolveBanners(context);
    context.read<HomeCubit>().startPromoAutoScroll(banners.length);

    return Column(
      children: [
        HomePromoBannersCarousel(banners: banners),
        const SizedBox(height: 12),
        HomePromoBannerIndicators(count: banners.length),
      ],
    );
  }
}
