import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/home_search_notifier.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

import 'package:rebtal/feature/home/widget/advanced_search/advanced_search_sheet.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final TextEditingController _controller = TextEditingController();
  String _currentLocation = 'جاري تحديد الموقع...';

  // Images for the slideshow
  final List<String> _backgroundImages = [
    'https://images.pexels.com/photos/189296/pexels-photo-189296.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1134176/pexels-photo-1134176.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1450360/pexels-photo-1450360.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/2103127/pexels-photo-2103127.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1287460/pexels-photo-1287460.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/261187/pexels-photo-261187.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1438834/pexels-photo-1438834.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1579253/pexels-photo-1579253.jpeg?auto=compress&cs=tinysrgb&w=600',
  ];
  late PageController _pageController;
  late Timer _timer;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.text = HomeSearch.currentQuery;
    _getCurrentLocation();
    _pageController = PageController();
    _startImageSlideshow();
  }

  void _startImageSlideshow() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _currentImageIndex =
            (_currentImageIndex + 1) % _backgroundImages.length;
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _currentLocation = 'الموقع غير مفعل');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _currentLocation = 'إذن الموقع مرفوض');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _currentLocation = 'إذن الموقع مرفوض');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (!mounted) return;
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) setState(() => _currentLocation = 'الموقع الحالي');
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=ar',
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String city = data['city'] ?? data['locality'] ?? '';
        String country = data['countryName'] ?? '';

        if (mounted) {
          if (city.isNotEmpty) {
            setState(() => _currentLocation = city);
          } else if (country.isNotEmpty) {
            setState(() => _currentLocation = country);
          } else {
            setState(() => _currentLocation = 'الموقع الحالي');
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _currentLocation = 'الموقع الحالي');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return SizedBox(
      height: 380, // Increased height for more immersion
      child: Stack(
        children: [
          // 1. Background Slideshow with Gradient Overlay
          Positioned.fill(
            child: RepaintBoundary(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _backgroundImages.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: AppImageHelper(
                          path: _backgroundImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient Overlay for text readability
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                      const Color(0xFF001409).withOpacity(0.8),
                                      const Color(0xFF001409),
                                    ],
                                    stops: const [0.0, 0.4, 0.8, 1.0],
                                  )
                                : null, // No gradient in Light Mode
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Top Bar: Greeting & Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'مرحباً بك 👋',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'استكشف جمال الطبيعة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Glass Location Pill
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF2563EB),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _currentLocation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Big Title
                  Text(
                    'ابحث عن\nوجهتك القادمة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: isDark
                          ? [
                              const Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Glass Search Bar
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AdvancedSearchSheet(),
                      );
                    },
                    child: Hero(
                      tag: 'search-bar',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Color(0xFF2563EB),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'إلى أين تريد الذهاب؟',
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ValueListenableBuilder<
                                              SearchFilters
                                            >(
                                              valueListenable:
                                                  HomeSearch.filters,
                                              builder: (context, filters, _) {
                                                String sub =
                                                    'أي مكان • أي وقت • ضيوف';
                                                if (!filters.isEmpty) {
                                                  sub = '';
                                                  if (filters.location !=
                                                      null) {
                                                    sub +=
                                                        '${filters.location} • ';
                                                  }
                                                  sub += 'تم الفلترة';
                                                }
                                                return Text(
                                                  sub,
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white70
                                                        : Colors.black54,
                                                    fontSize: 11,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      isDark ? 0.1 : 0.8,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.tune,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
