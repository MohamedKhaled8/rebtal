import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/widget/clean_search_bar_trigger/clean_search_bar_trigger.dart';
import 'package:rebtal/feature/home/widget/explore_chalet/explore_chalet_home.dart';
import 'package:rebtal/feature/home/widget/public_chalet/public_chalet_list.dart';
import 'package:rebtal/feature/home/widget/home_top_bar/home_top_bar.dart';
import 'package:rebtal/feature/home/widget/home_promo_banners/home_promo_banners.dart';
import 'package:rebtal/feature/home/widget/automated_offers/automated_offers_section.dart';
import 'package:rebtal/feature/home/widget/popular_destinations/popular_destinations_section.dart';

import 'package:responsive_screen_master/responsive_screen_master.dart';

import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String? _selectedPopularDestination;

  @override
  bool get wantKeepAlive => true; // Keep state alive to avoid rebuilds

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.black
          : ColorsManager.chaletBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) setState(() {});
        },
        color: const Color(0xFF2563EB),
        backgroundColor: isDark ? ColorsManager.darkGrey252540 : Colors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Bar (Profile & Notifications)
            const SliverToBoxAdapter(child: SafeArea(child: HomeTopBar())),

            // 2. Clean Search Bar Trigger
            SliverToBoxAdapter(child: CleanSearchBarTrigger(isDark: isDark)),

            // 3. Promo Banners
            SliverToBoxAdapter(child: HomePromoBanners()),

            // 4. Destinations & Areas (under banner)
            SliverToBoxAdapter(
              child: PopularDestinationsSection(
                selectedDestination: _selectedPopularDestination,
                onDestinationSelected: (name) {
                  setState(() {
                    // Tap again to clear selection
                    if (_selectedPopularDestination == name) {
                      _selectedPopularDestination = null;
                    } else {
                      _selectedPopularDestination = name;
                    }
                  });
                },
              ),
            ),

            // 5. Automated Exclusive Offers
            const SliverToBoxAdapter(child: AutomatedOffersSection()),

            // // 5. Top Rated
            // const SliverToBoxAdapter(child: TopRatedSection()),

            // 6. Explore Everything Else
            SliverToBoxAdapter(child: ExploreChaletHome(isDark: isDark)),

            SliverToBoxAdapter(
              child: PublicChaletsList(
                key: const ValueKey('public-chalets-list'),
                selectedCategory: _selectedPopularDestination,
                emptyIcon: Icons.search_off_rounded,
                emptyTitle: context.tr('home_no_results'),
                emptySubtitle: context.tr('home_try_other_search'),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: otv(context: context, portrait: 16.sh, landscape: 8.sh),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
