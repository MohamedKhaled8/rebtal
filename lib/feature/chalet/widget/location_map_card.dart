import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/maps/osm_tile_support.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';

Future<(double, double)?> _geocodeAddressWithNominatim(String query) async {
  final q = query.trim();
  if (q.isEmpty) return null;
  try {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(q)}&format=json&limit=1',
    );
    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'Rebtal/1.0 (chalet map preview; contact via app store listing)',
        'Accept-Language': 'ar,en',
      },
    );
    if (response.statusCode != 200) return null;
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) return null;
    final map = list.first as Map<String, dynamic>;
    final lat = double.tryParse(map['lat']?.toString() ?? '');
    final lon = double.tryParse(map['lon']?.toString() ?? '');
    if (lat == null || lon == null) return null;
    return (lat, lon);
  } catch (_) {
    return null;
  }
}

/// Resolves coordinates (Firestore or Nominatim) and shows a real OSM tile map.
class _ResolvedLatLngMap extends StatefulWidget {
  const _ResolvedLatLngMap({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.isDark,
    required this.placeholder,
  });

  final String location;
  final double? latitude;
  final double? longitude;
  final bool isDark;
  final Widget placeholder;

  @override
  State<_ResolvedLatLngMap> createState() => _ResolvedLatLngMapState();
}

class _ResolvedLatLngMapState extends State<_ResolvedLatLngMap> {
  late final Future<LatLng?> _centerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      _centerFuture = Future.value(
        LatLng(widget.latitude!, widget.longitude!),
      );
    } else {
      final addr = widget.location.trim();
      _centerFuture = addr.isEmpty
          ? Future.value(null)
          : _geocodeAddressWithNominatim(addr).then(
              (c) => c == null ? null : LatLng(c.$1, c.$2),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng?>(
      future: _centerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
            alignment: Alignment.center,
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          );
        }
        final center = snapshot.data;
        if (center == null) {
          return widget.placeholder;
        }
        return _InteractiveOsmMap(
          center: center,
          offlineHint: context.tr('chalet_map_tiles_unavailable'),
        );
      },
    );
  }
}

/// Real map tiles (OpenStreetMap) with pan/zoom — same stack as owner location picker.
class _InteractiveOsmMap extends StatefulWidget {
  const _InteractiveOsmMap({required this.center, required this.offlineHint});

  final LatLng center;
  final String offlineHint;

  @override
  State<_InteractiveOsmMap> createState() => _InteractiveOsmMapState();
}

class _InteractiveOsmMapState extends State<_InteractiveOsmMap> {
  bool _tileLoadFailed = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: canReachOpenStreetMapTiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data != true || _tileLoadFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.offlineHint,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: 15,
            minZoom: 3,
            maxZoom: 19,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.rebtal.app',
              errorImage: kOsmTileErrorImage,
              errorTileCallback: (_, error, stackTrace) {
                if (!mounted || _tileLoadFailed) return;
                setState(() {
                  _tileLoadFailed = true;
                });
              },
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 48,
                  height: 48,
                  point: widget.center,
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 44,
                    color: Colors.redAccent.shade400,
                    shadows: const [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black45,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class LocationMapCard extends StatelessWidget {
  final String location;
  final double? latitude;
  final double? longitude;
  final String? fallbackImage;

  const LocationMapCard({
    super.key,
    required this.location,
    this.latitude,
    this.longitude,
    this.fallbackImage,
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
            if (!context.mounted) return;
            _showError(context, context.tr('cannot_open_map'));
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
            if (!context.mounted) return;
            _showError(context, context.tr('cannot_open_map'));
          }
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, '${context.tr('common_error')}: $e');
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
          const SizedBox(height: 16),

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
                context.tr('chalet_location'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Map — interactive OSM tiles; tap overlays to open external maps app.
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _ResolvedLatLngMap(
                      location: location,
                      latitude: latitude,
                      longitude: longitude,
                      isDark: isDark,
                      placeholder: _buildMapImagePlaceholder(
                        context,
                        isDark,
                        fallbackPhoto: fallbackImage,
                      ),
                    ),
                  ),

                  // Top address — opens Google Maps / geo for directions
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openMapInApp(context),
                        borderRadius: BorderRadius.circular(16),
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
                                    ? Colors.black.withValues(alpha: 0.58)
                                    : Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.white.withValues(alpha: 0.25),
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
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Open in maps app
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openMapInApp(context),
                        borderRadius: BorderRadius.circular(30),
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
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                context.tr('chalet_view_route'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildMapImagePlaceholder(
    BuildContext context,
    bool isDark, {
    String? fallbackPhoto,
  }) {
    final photo = fallbackPhoto?.trim();
    final hasNetworkPhoto =
        photo != null && photo.startsWith('http');
    final networkUrl = hasNetworkPhoto ? photo : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (networkUrl != null)
          AppImageHelper(
            path: networkUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        Container(
          color: hasNetworkPhoto
              ? Colors.black.withValues(alpha: isDark ? 0.5 : 0.35)
              : (isDark ? const Color(0xFF1A1A1A) : Colors.grey[100]),
        ),
        if (!hasNetworkPhoto)
          Container(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
          ),
        Opacity(
          opacity: 0.1,
          child: CustomPaint(painter: _MapPatternPainter(isDark: isDark)),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map_rounded,
                  color: isDark ? Colors.white38 : Colors.black38,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('chalet_tap_to_open'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('chalet_view_location_details'),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  final bool isDark;
  _MapPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width * i / 5, 0),
        Offset(size.width * i / 5, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 5),
        Offset(size.width, size.height * i / 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
