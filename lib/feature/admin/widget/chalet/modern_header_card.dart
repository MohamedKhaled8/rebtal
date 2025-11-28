import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ModernHeaderCard extends StatefulWidget {
  const ModernHeaderCard({super.key, required this.requestData});
  final Map<String, dynamic> requestData;

  @override
  State<ModernHeaderCard> createState() => _ModernHeaderCardState();
}

class _ModernHeaderCardState extends State<ModernHeaderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelName = widget.requestData['chaletName'] ?? 'Luxury Chalet';
    final location = widget.requestData['location'] ?? 'Unknown Location';
    final price = widget.requestData['price'];
    final rating =
        ((widget.requestData['rating'] ?? widget.requestData['avgRating'])
            ?.toString()) ??
        '0.0';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.kPrimaryGradient.colors.first
                          .withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Gradient Background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              ColorManager.kPrimaryGradient.colors.first
                                  .withOpacity(0.03),
                              ColorManager.kPrimaryGradient.colors.last
                                  .withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),

                      // Animated circles decoration
                      Positioned(
                        top: -50,
                        right: -50,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      ColorManager.kPrimaryGradient.colors.first
                                          .withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Price Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Chalet Name with animated underline
                                      Stack(
                                        children: [
                                          Text(
                                            hotelName,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              foreground: Paint()
                                                ..shader =
                                                    LinearGradient(
                                                      colors: [
                                                        const Color(0xFF1F2937),
                                                        ColorManager
                                                            .kPrimaryGradient
                                                            .colors
                                                            .first,
                                                      ],
                                                    ).createShader(
                                                      const Rect.fromLTWH(
                                                        0,
                                                        0,
                                                        200,
                                                        70,
                                                      ),
                                                    ),
                                              height: 1.2,
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            bottom: -2,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0, end: 1),
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, child) {
                                                return Container(
                                                  width: 60 * value,
                                                  height: 3,
                                                  decoration: BoxDecoration(
                                                    gradient: ColorManager
                                                        .kPrimaryGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpace(12),

                                      // Location with modern icon
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on_rounded,
                                              color: ColorManager
                                                  .kPrimaryGradient
                                                  .colors
                                                  .first,
                                              size: 18,
                                            ),
                                            horizintalSpace(6),
                                            Flexible(
                                              child: Text(
                                                location,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                horizintalSpace(16),

                                // Premium Price Badge
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF059669),
                                        const Color(0xFF10B981),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF059669,
                                        ).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.egp(
                                          (price is num)
                                              ? price
                                              : double.tryParse(
                                                      (price ?? '').toString(),
                                                    ) ??
                                                    0,
                                          withSuffixPerNight: false,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const Text(
                                        'per night',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            verticalSpace(20),

                            // Features Row with glassmorphism
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                // Rating badge
                                _buildFeatureBadge(
                                  icon: Icons.star_rounded,
                                  label: rating,
                                  colors: [
                                    Colors.amber[400]!,
                                    Colors.amber[600]!,
                                  ],
                                  iconColor: Colors.white,
                                  delay: 200,
                                ),

                                // WiFi badge
                                if (widget.requestData['hasWifi'] == true)
                                  _buildFeatureBadge(
                                    icon: Icons.wifi_rounded,
                                    label: 'WiFi',
                                    colors: [
                                      Colors.blue[400]!,
                                      Colors.blue[600]!,
                                    ],
                                    iconColor: Colors.white,
                                    delay: 400,
                                  ),

                                // Breakfast badge
                                if (widget.requestData['hasBreakfast'] == true)
                                  _buildFeatureBadge(
                                    icon: Icons.free_breakfast_rounded,
                                    label: 'Breakfast',
                                    colors: [
                                      Colors.orange[400]!,
                                      Colors.orange[600]!,
                                    ],
                                    iconColor: Colors.white,
                                    delay: 600,
                                  ),

                                // Parking badge (if available)
                                if (widget.requestData['hasParking'] == true)
                                  _buildFeatureBadge(
                                    icon: Icons.local_parking_rounded,
                                    label: 'Parking',
                                    colors: [
                                      Colors.purple[400]!,
                                      Colors.purple[600]!,
                                    ],
                                    iconColor: Colors.white,
                                    delay: 800,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required Color iconColor,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
