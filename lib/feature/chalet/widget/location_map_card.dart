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
          Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
          const SizedBox(height: 32),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? ColorManager.chaletTextPrimaryDark
                            : ColorManager.chaletTextPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ColorManager.chaletTextSecondaryDark
                            : ColorManager.chaletTextSecondaryLight,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Map Image
          GestureDetector(
            onTap: () => _openMapInApp(context),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // Very subtle shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    _buildRealMapImage(isDark),
                    // Corner Icon Button
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.near_me_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE5E7EB),
      child: Center(
        child: Icon(
          Icons.map_rounded,
          color: isDark ? Colors.white24 : Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }
}
