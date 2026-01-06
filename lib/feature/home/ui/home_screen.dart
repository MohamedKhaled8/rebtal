import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/widget/public_chalets_list.dart';
import 'package:rebtal/feature/home/widget/header_section.dart';
import 'package:rebtal/feature/home/widget/top_rated_chalets_list.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String? _selectedCategoryValue;

  @override
  bool get wantKeepAlive => true; // Keep state alive to avoid rebuilds

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorManager.chaletBackgroundDark
          : ColorManager.chaletBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh delay for better UX
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) setState(() {});
        },
        color: ColorManager.chaletAccent,
        backgroundColor: isDark ? ColorManager.darkGrey252540 : Colors.white,
        child: CustomScrollView(
          slivers: [
            // 1. Immersive Header
            const SliverToBoxAdapter(child: HeaderSection()),

            // 2. Top Rating Section
            SliverToBoxAdapter(child: AccentBarTitle(title: "Top Rating")),
            SliverToBoxAdapter(child: SizedBox(height: 1.5.h)),
            const SliverToBoxAdapter(child: TopRatedChaletsList()),
            SliverToBoxAdapter(child: SizedBox(height: 3.h)),

            // 3. Categories Bar ('Chalets')
            SliverToBoxAdapter(child: AccentBarTitle(title: "Chalets")),
            SliverToBoxAdapter(child: SizedBox(height: 1.5.h)),

            // 4. Property Listings - Removed redundant StreamBuilder
            SliverToBoxAdapter(
              child: PublicChaletsList(
                key: ValueKey(
                  'list-${DateTime.now().millisecondsSinceEpoch}',
                ), // Force rebuild on refresh
                selectedCategory: _selectedCategoryValue,
                emptyIcon: Icons.home_outlined,
                emptyTitle: 'لا توجد شاليهات متاحة حالياً',
                emptySubtitle: 'سيتم عرض الشاليهات هنا عند توفرها',
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 10.h),
            ), // Extra padding for FAB/Nav
          ],
        ),
      ),
    );
  }
}

class AccentBarTitle extends StatelessWidget {
  final String title;

  const AccentBarTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
