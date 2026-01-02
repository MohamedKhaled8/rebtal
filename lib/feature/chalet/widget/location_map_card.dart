import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LocationMapCard extends StatelessWidget {
  final String location;
  final double? latitude;
  final double? longitude;

  const LocationMapCard({
    super.key,
    required this.location,
    this.latitude,
    this.longitude,
  });

  Future<void> _openMapInApp(BuildContext context) async {
    try {
      if (latitude != null && longitude != null) {
        // استخدام geo: URI scheme - يعرض قائمة التطبيقات المتاحة تلقائياً
        // على Android/iOS، يعرض قائمة جميع تطبيقات الخرائط المتاحة (Google Maps, Waze, Apple Maps, etc.)
        final url = 'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(location)})';
        final uri = Uri.parse(url);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: استخدام Google Maps URL الذي يعرض قائمة التطبيقات أيضاً
          final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
          final fallbackUri = Uri.parse(fallbackUrl);
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          } else {
            _showError(context, 'لا يمكن فتح الخريطة');
          }
        }
      } else {
        // إذا لم يكن لدينا إحداثيات، نستخدم العنوان مع geo: scheme
        final url = 'geo:0,0?q=${Uri.encodeComponent(location)}';
        final uri = Uri.parse(url);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback: استخدام Google Maps URL
          final fallbackUrl = 'https://www.google.com/maps/search/${Uri.encodeComponent(location)}';
          final fallbackUri = Uri.parse(fallbackUrl);
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          } else {
            _showError(context, 'لا يمكن فتح الخريطة');
          }
        }
      }
    } catch (e) {
      _showError(context, 'خطأ: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    SnackBarHelper.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorManager.chaletCardDark,
                  ColorManager.chaletCardDark.withOpacity(0.8),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorManager.chaletCardLight,
                  ColorManager.chaletCardLight.withOpacity(0.95),
                ],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? ColorManager.white.withOpacity(0.05)
              : ColorManager.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.chaletActionBlue.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.chaletActionBlue.withOpacity(0.2),
                      ColorManager.chaletActionBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorManager.chaletActionBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: ColorManager.chaletActionBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الموقع',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? ColorManager.chaletTextPrimaryDark
                            : ColorManager.chaletGalleryTextDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? ColorManager.chaletTextSecondaryDark
                            : ColorManager.chaletTextSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Real Google Maps Image Only (No Design)
          GestureDetector(
            onTap: () => _openMapInApp(context),
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _buildRealMapImage(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStaticMapImageUrl() {
    if (latitude != null && longitude != null) {
      // استخدام Google Maps Static API للحصول على صورة حقيقية للخريطة (مثل screenshot)
      // API Key موجود في AndroidManifest.xml
      const apiKey = 'AIzaSyBMO8r4waPphzE5AxGbe95OW8WRNNlbUo0';
      final lat = latitude!;
      final lon = longitude!;
      
      // إنشاء URL لصورة الخريطة الحقيقية من Google Maps Static API
      // zoom=15 للحصول على تفاصيل جيدة (15 مناسب لعرض المنطقة)
      // size=800x480 للحصول على جودة عالية (نسبة 5:3)
      // maptype=roadmap للحصول على خريطة حقيقية مع الطرق والأسماء
      // scale=2 للحصول على جودة أعلى (retina display)
      // لا نضع marker في الصورة لأننا سنضيفه في الواجهة
      return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=15&size=800x480&scale=2&maptype=roadmap&key=$apiKey';
    }
    return '';
  }

  Widget _buildRealMapImage(bool isDark) {
    if (latitude != null && longitude != null) {
      // عرض صورة حقيقية من Google Maps Static API
      final imageUrl = _getStaticMapImageUrl();
      
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildMapImagePlaceholder(isDark),
        errorWidget: (context, url, error) => _buildMapImagePlaceholder(isDark),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      );
    }
    
    return _buildMapImagePlaceholder(isDark);
  }

  Widget _buildMapImagePlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ColorManager.chaletActionDarkBlue,
                  ColorManager.chaletActionBlue,
                  ColorManager.chaletActionDarkBlue,
                ]
              : [
                  ColorManager.chaletGrey50,
                  ColorManager.chaletActionBlue.withOpacity(0.3),
                  ColorManager.chaletActionBlue.withOpacity(0.5),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Map-like grid pattern (يشبه الخريطة)
          CustomPaint(
            painter: MapGridPainter(isDark: isDark),
            size: Size.infinite,
          ),
          // Location marker
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.chaletUnavailableRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorManager.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.chaletUnavailableRed.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: ColorManager.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated marker with continuous ripple effect
class _RippleMarker extends StatefulWidget {
  @override
  State<_RippleMarker> createState() => _RippleMarkerState();
}

class _RippleMarkerState extends State<_RippleMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect rings (3 rings)
            ...List.generate(3, (index) {
              final delay = index * 0.33;
              final animationValue = (_controller.value - delay) % 1.0;
              final opacity = (1 - animationValue).clamp(0.0, 1.0);
              final scale = 1.0 + (animationValue * 0.8);
              
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity * 0.4,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorManager.white.withOpacity(0.6 * opacity),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Main marker (white circle with home icon)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorManager.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_rounded,
                color: ColorManager.chaletGrey800,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for map grid pattern
class MapGridPainter extends CustomPainter {
  final bool isDark;
  
  MapGridPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? ColorManager.chaletActionBlue.withOpacity(0.2)
          : ColorManager.chaletActionBlue.withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw some roads (horizontal and vertical)
    final roadPaint = Paint()
      ..color = isDark
          ? ColorManager.chaletActionBlue.withOpacity(0.3)
          : ColorManager.chaletActionBlue.withOpacity(0.4)
      ..strokeWidth = 8;

    // Horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      roadPaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

