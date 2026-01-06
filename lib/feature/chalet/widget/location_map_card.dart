import 'dart:ui';
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
        final url =
            'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(location)})';
        final uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          final fallbackUrl =
              'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
          final fallbackUri = Uri.parse(fallbackUrl);
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          } else {
            _showError(context, 'لا يمكن فتح الخريطة');
          }
        }
      } else {
        final url = 'geo:0,0?q=${Uri.encodeComponent(location)}';
        final uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          final fallbackUrl =
              'https://www.google.com/maps/search/${Uri.encodeComponent(location)}';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: isDark ? Colors.white12 : Colors.grey[200],
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 24),

          // Title with Accent
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'الموقع',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ColorManager.chaletTextPrimaryDark
                      : ColorManager.chaletTextPrimaryLight,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Map Container
          GestureDetector(
            onTap: () => _openMapInApp(context),
            child: Container(
              height: 250, // Slightly taller for more impact
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // The Map Image
                    _buildRealMapImage(isDark),

                    // Top Glassmorphism Overlay (Address info)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.redAccent[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Navigation Button Badge
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
                            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'عرض المسار',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center Pulse Marker (Visual indicator of target)
                    const Center(child: _MapPulseMarker()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStaticMapImageUrl() {
    if (latitude != null && longitude != null) {
      const apiKey = 'AIzaSyBMO8r4waPphzE5AxGbe95OW8WRNNlbUo0';
      final lat = latitude!;
      final lon = longitude!;
      return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=15&size=800x480&scale=2&maptype=roadmap&key=$apiKey';
    }
    return '';
  }

  Widget _buildRealMapImage(bool isDark) {
    if (latitude != null && longitude != null) {
      final imageUrl = _getStaticMapImageUrl();

      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildMapImagePlaceholder(isDark),
        errorWidget: (context, url, error) => _buildMapImagePlaceholder(isDark),
      );
    }

    return _buildMapImagePlaceholder(isDark);
  }

  Widget _buildMapImagePlaceholder(bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Premium Map Texture Background
        Image.network(
          isDark
              ? 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=1200&auto=format&fit=crop' // Deep blueprint/dark map
              : 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1200&auto=format&fit=crop', // Working clean map/aerial view
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: isDark ? Colors.black : Colors.grey[100],
            child: Icon(
              Icons.map_rounded,
              color: isDark ? Colors.white12 : Colors.black12,
              size: 40,
            ),
          ),
        ),
        // Overlay for better contrast
        Container(
          color: (isDark ? Colors.black : Colors.white).withOpacity(0.4),
        ),
        // Subtle Blur for glass effect
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.transparent),
          ),
        ),
        // Centered Icon to indicate it's a map
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'جاري تحميل الخريطة...',
                style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPulseMarker extends StatefulWidget {
  const _MapPulseMarker();

  @override
  State<_MapPulseMarker> createState() => _MapPulseMarkerState();
}

class _MapPulseMarkerState extends State<_MapPulseMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 40 * _animation.value,
              height: 40 * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent.withOpacity(1.0 - _controller.value),
              ),
            );
          },
        ),
        Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
