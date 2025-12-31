import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

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
            color: Colors.blue.withOpacity(0.1),
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
                      Colors.blue.withOpacity(0.2),
                      Colors.blue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.blue,
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
          const SizedBox(height: 24),
          
          // Map Image (Interactive)
          GestureDetector(
            onTap: () => _openMapInApp(context),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100.withOpacity(0.3),
                    Colors.blue.shade200.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Map Image (Real Google Maps Screenshot)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildMapPlaceholder(),
                  ),
                  
                  // Tap indicator (Bottom Right)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'افتح في الخريطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStaticMapImageUrl() {
    if (latitude != null && longitude != null) {
      // استخدام Google Maps Static API للحصول على صورة حقيقية للخريطة
      // API Key موجود في AndroidManifest.xml
      const apiKey = 'AIzaSyBMO8r4waPphzE5AxGbe95OW8WRNNlbUo0';
      final lat = latitude!;
      final lon = longitude!;
      
      // إنشاء URL لصورة الخريطة من Google Maps Static API
      return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=15&size=600x300&markers=color:red|$lat,$lon&key=$apiKey';
    }
    return '';
  }

  Widget _buildMapPlaceholder() {
    if (latitude != null && longitude != null) {
      // عرض صورة حقيقية من Google Maps Static API
      final imageUrl = _getStaticMapImageUrl();
      
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildMapImagePlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          // إذا فشل التحميل، نستخدم placeholder
          return _buildMapImagePlaceholder();
        },
      );
    }
    
    return _buildMapImagePlaceholder();
  }

  Widget _buildMapImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
            Colors.blue.shade200,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Map-like grid pattern (يشبه الخريطة)
          CustomPaint(
            painter: MapGridPainter(),
            size: Size.infinite,
          ),
          // Location marker
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for map grid pattern
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200.withOpacity(0.3)
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
      ..color = Colors.blue.shade300.withOpacity(0.4)
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

