
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

class HomePromoBanners extends StatefulWidget {
  const HomePromoBanners({super.key});

  @override
  State<HomePromoBanners> createState() => _HomePromoBannersState();
}

class _HomePromoBannersState extends State<HomePromoBanners> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  List<Map<String, String>> get _bannerData => [
    {
      'title': context.tr('home_banner_title_1'),
      'subtitle': context.tr('home_banner_subtitle_1'),
      'tag': context.tr('home_banner_tag_1'),
      'image':
          'https://images.unsplash.com/photo-1540518614846-7eded433c457?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': context.tr('home_banner_title_2'),
      'subtitle': context.tr('home_banner_subtitle_2'),
      'tag': context.tr('home_banner_tag_2'),
      'image':
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': context.tr('home_banner_title_3'),
      'subtitle': context.tr('home_banner_subtitle_3'),
      'tag': context.tr('home_banner_tag_3'),
      'image':
          'https://images.unsplash.com/photo-1510074377623-8cf13fb86c08?q=80&w=400&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: otv(context: context, portrait: 22.h, landscape: 30.h),
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: otv(context: context, portrait: 20.sh, landscape: 10.sh)),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = _bannerData[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw)),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: stv(context: context, mobile: 10.sw, tablet: 14.sw, desktop: 18.sw),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: stv(context: context, mobile: 20.sw, tablet: 28.sw, desktop: 36.sw),
                          vertical: otv(context: context, portrait: 15.sh, landscape: 10.sh),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              isDark ? Colors.black : const Color(0xFFF9FAFB),
                              isDark
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: stv(context: context, mobile: 8.sw, tablet: 12.sw, desktop: 16.sw),
                                vertical: otv(context: context, portrait: 4.sh, landscape: 2.sh),
                              ),
                              color: const Color(0xFF2563EB),
                              child: Text(
                                banner['tag']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: stv(context: context, mobile: 9.spScaled, tablet: 11.spScaled, desktop: 13.spScaled),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: otv(context: context, portrait: 8.sh, landscape: 4.sh)),
                            Text(
                              banner['title']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: stv(context: context, mobile: 18.spScaled, tablet: 22.spScaled, desktop: 26.spScaled),
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: otv(context: context, portrait: 8.sh, landscape: 4.sh)),
                            Text(
                              banner['subtitle']!,
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: stv(
                                  context: context,
                                  mobile: 11.spScaled,
                                  tablet: 15.spScaled,
                                  desktop: 20.spScaled,
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Image.network(
                        banner['image']!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: stv(context: context, mobile: 4.sw, tablet: 6.sw, desktop: 8.sw)),
              width: _currentPage == index 
                ? stv(context: context, mobile: 20.sw, tablet: 26.sw, desktop: 32.sw) 
                : stv(context: context, mobile: 8.sw, tablet: 12.sw, desktop: 16.sw),
              height: otv(context: context, portrait: 4.sh, landscape: 2.sh),
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF2563EB)
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(2.sw),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
