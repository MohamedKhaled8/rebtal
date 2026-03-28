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
          'https://images.unsplash.com/photo-1540518614846-7eded433c457?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': context.tr('home_banner_title_2'),
      'subtitle': context.tr('home_banner_subtitle_2'),
      'tag': context.tr('home_banner_tag_2'),
      'image':
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': context.tr('home_banner_title_3'),
      'subtitle': context.tr('home_banner_subtitle_3'),
      'tag': context.tr('home_banner_tag_3'),
      'image':
          'https://images.unsplash.com/photo-1510074377623-8cf13fb86c08?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.92);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
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
        SizedBox(
          width: double.infinity,
          height: otv(context: context, portrait: 16.h, landscape: 60.h),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = _bannerData[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(banner['image']!, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            banner['tag']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              banner['title']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF2563EB)
                    : (isDark ? Colors.white30 : Colors.black.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
