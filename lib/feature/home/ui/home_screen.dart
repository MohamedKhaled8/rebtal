import 'package:flutter/material.dart';
import 'package:rebtal/feature/home/widget/public_chalets_list.dart';
import 'package:rebtal/feature/home/widget/home_top_bar.dart';
import 'package:rebtal/feature/home/widget/home_promo_banners.dart';
import 'package:rebtal/feature/home/widget/automated_offers_section.dart';
import 'package:rebtal/feature/home/widget/top_rated_section.dart';
import 'package:rebtal/feature/home/widget/advanced_search_sheet.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
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
  @override
  bool get wantKeepAlive => true; // Keep state alive to avoid rebuilds

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? Colors.black
          : ColorManager.chaletBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) setState(() {});
        },
        color: const Color(0xFF2563EB),
        backgroundColor: isDark ? ColorManager.darkGrey252540 : Colors.white,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Bar (Profile & Notifications)
            const SliverToBoxAdapter(child: SafeArea(child: HomeTopBar())),

            // 2. Clean Search Bar Trigger
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AdvancedSearchSheet(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color(0xFF2563EB),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'إلى أين تريد الذهاب؟',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.tune,
                          size: 18,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Logic-based Location Areas
            SliverToBoxAdapter(child: HomePromoBanners()),

            // 4. Automated Exclusive Offers
            const SliverToBoxAdapter(child: AutomatedOffersSection()),

            // 5. Top Rated (Higher visual contrast)
            const SliverToBoxAdapter(child: TopRatedSection()),

            // 6. Explore Everything Else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'استكشف الشاليهات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    ValueListenableBuilder<SearchFilters>(
                      valueListenable: HomeSearch.filters,
                      builder: (context, filters, _) {
                        if (filters.isEmpty) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: () => HomeSearch.clear(),
                          child: const Text('إعادة تعيين'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: PublicChaletsList(
                key: const ValueKey('public-chalets-list'),
                emptyIcon: Icons.search_off_rounded,
                emptyTitle: 'لا توجد نتائج مطابقة',
                emptySubtitle: 'جرب البحث عن شيء آخر',
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 10.h)),
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
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'عرض الكل',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
           ),
        ],
      ),
    );
  }
}
