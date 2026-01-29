import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class HomePromoBanners extends StatefulWidget {
  const HomePromoBanners({super.key});

  @override
  State<HomePromoBanners> createState() => _HomePromoBannersState();
}

class _HomePromoBannersState extends State<HomePromoBanners> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  final List<Map<String, String>> _bannerData = [
    {
      'title': 'استمتع بأفضل شاليهات\nالساحل الشمالي',
      'subtitle': 'خصومات تصل إلى 25% مع تطبيق ريبتال',
      'tag': 'عرض خاص',
      'image':
          'https://images.unsplash.com/photo-1540518614846-7eded433c457?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'هدوء ورفاهية في\nالعين السخنة',
      'subtitle': 'احجز الآن واستلم خصم فوري 15%',
      'tag': 'حجز مبكر',
      'image':
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?q=80&w=400&auto=format&fit=crop',
    },
    {
      'title': 'أجواء لا تُنسى في\nمدينة دهب',
      'subtitle': 'عروض حصرية للعائلات والمجموعات',
      'tag': 'الأكثر طلباً',
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
          height: 170,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerData.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = _bannerData[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              color: const Color(0xFF2563EB),
                              child: Text(
                                banner['tag']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              banner['title']!,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              banner['subtitle']!,
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 11,
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
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 20 : 8,
              height: 4,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF2563EB)
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
