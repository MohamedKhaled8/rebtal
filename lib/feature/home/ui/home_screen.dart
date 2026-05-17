import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/home/logic/cubit/home_cubit.dart';
import 'package:rebtal/feature/home/widget/location_areas/location_areas_section.dart';
import 'package:rebtal/feature/home/widget/top_rated/top_rated_section.dart';
import 'package:rebtal/feature/home/ui/home_bloc_scope.dart';
import 'package:rebtal/feature/home/widget/automated_offers/automated_offers_section.dart';
import 'package:rebtal/feature/home/widget/clean_search_bar_trigger/clean_search_bar_trigger.dart';
import 'package:rebtal/feature/home/widget/explore_chalet/explore_chalet_home.dart';
import 'package:rebtal/feature/home/widget/home_promo_banners/home_promo_banners.dart';
import 'package:rebtal/feature/home/widget/home_top_bar/home_top_bar.dart';
import 'package:rebtal/feature/home/widget/popular_destinations/popular_destinations_section.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBlocScope(child: HomePageContent());
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.black
          : ColorsManager.chaletBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<HomeCubit>().refresh();
        },
        color: const Color(0xFF2563EB),
        backgroundColor: isDark ? ColorsManager.darkGrey252540 : Colors.white,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              const SliverToBoxAdapter(child: SafeArea(child: HomeTopBar())),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CleanSearchBarTrigger(isDark: isDark),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: HomePromoBanners(),
                ),
              ),
              const SliverToBoxAdapter(child: PopularDestinationsSection()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: AutomatedOffersSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ExploreChaletHome(isDark: isDark),
                ),
              ),
            ];
          },
          body: PublicChaletsList(
            key: const ValueKey('public-chalets-list'),
            emptyIcon: Icons.search_off_rounded,
            emptyTitle: context.tr('home_no_results'),
            emptySubtitle: context.tr('home_try_other_search'),
          ),
        ),
      ),
    );
  }
}
