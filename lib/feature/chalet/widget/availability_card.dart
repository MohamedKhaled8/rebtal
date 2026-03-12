import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/chalet/logic/cubit/chalet_detail_cubit.dart';

class AvailabilityCard extends StatefulWidget {
  const AvailabilityCard({super.key, required this.requestData});

  final Map<String, dynamic> requestData;

  @override
  State<AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard>
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
    return BlocBuilder<ChaletDetailCubit, ChaletDetailState>(
      builder: (context, state) {
        final cubit = context.read<ChaletDetailCubit>();

        // Data Extraction
        List<dynamic>? bookedDates = widget.requestData['bookedDates'];
        if (state is ChaletDetailLoaded && state.bookedDates != null) {
          bookedDates = state.bookedDates;
        }

        final bookingAvailability = widget.requestData['bookingAvailability'];
        final isAvailableFromBooking =
            bookingAvailability == 'available' || bookingAvailability == null;
        final isAvailableFromFlag = widget.requestData['isAvailable'] == true;
        final isAvailable =
            isAvailableFromFlag ||
            (widget.requestData['isAvailable'] == null &&
                isAvailableFromBooking);

        final isDark = DynamicThemeManager.isDarkMode(context);

        // Date Strings
        final fromDate = cubit.formatDate(widget.requestData['availableFrom']);
        final toDate = cubit.formatDate(widget.requestData['availableTo']);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
              const SizedBox(height: 32),

              Text(
                'Availability Check',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? ColorsManager.chaletTextPrimaryDark
                      : ColorsManager.chaletTextPrimaryLight,
                ),
              ),

              const SizedBox(height: 24),

              // --- THE DIAGRAM LAYOUT ---
              SizedBox(
                height: 180, // Fixed height for the diagram area
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 1. The Painter (Lines & Animation)
                    // Placed slightly down to start from bottom of Status Badge
                    Positioned.fill(
                      top: 40, // Height of status badge approx / 2
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _DiagramConnectorPainter(
                              color: isAvailable
                                  ? ColorsManager.chaletAvailableGreen
                                  : ColorsManager.chaletUnavailableRed,
                              isDark: isDark,
                              progress: _controller.value,
                            ),
                          );
                        },
                      ),
                    ),

                    // 2. The Components
                    Column(
                      children: [
                        // -- Top: Status Badge (The Source) --
                        _buildStatusBadge(isAvailable, isDark),

                        const Spacer(), // Pushes dates to bottom
                        // -- Bottom: Date Boxes (The Targets) --
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // Push to edges
                          children: [
                            Expanded(
                              child: _buildDatePlate(
                                'Check-in',
                                fromDate,
                                Icons.login_rounded,
                                isDark,
                                isAvailable,
                              ),
                            ),
                            const SizedBox(width: 40), // Gap for lines
                            Expanded(
                              child: _buildDatePlate(
                                'Check-out',
                                toDate,
                                Icons.logout_rounded,
                                isDark,
                                isAvailable,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Booked Dates List (Minimal)
              _BookedDatesList(
                bookedDates: bookedDates,
                isDark: isDark,
                cubit: cubit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isAvailable, bool isDark) {
    final color = isAvailable
        ? ColorsManager.chaletAvailableGreen
        : ColorsManager.chaletUnavailableRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isAvailable ? 'Available Now' : 'Currently Unavailable',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePlate(
    String label,
    String date,
    IconData icon,
    bool isDark,
    bool isAvailable,
  ) {
    final accentColor = isAvailable
        ? ColorsManager.chaletActionBlue
        : ColorsManager.chaletGrey400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter for the Wavy Lines & Animation ---
class _DiagramConnectorPainter extends CustomPainter {
  final Color color;
  final bool isDark;
  final double progress; // Animation progress 0.0 -> 1.0

  _DiagramConnectorPainter({
    required this.color,
    required this.isDark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Static Lines
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final startPoint = Offset(size.width / 2, 0);
    final endPointLeft = Offset(size.width * 0.25, size.height - 100);
    final endPointRight = Offset(size.width * 0.75, size.height - 100);

    // Left Path
    final pathLeft = Path();
    pathLeft.moveTo(startPoint.dx, startPoint.dy);
    pathLeft.quadraticBezierTo(
      size.width * 0.25,
      startPoint.dy + 20,
      endPointLeft.dx,
      endPointLeft.dy,
    );

    // Right Path
    final pathRight = Path();
    pathRight.moveTo(startPoint.dx, startPoint.dy);
    pathRight.quadraticBezierTo(
      size.width * 0.75,
      startPoint.dy + 20,
      endPointRight.dx,
      endPointRight.dy,
    );

    canvas.drawPath(pathLeft, paint);
    canvas.drawPath(pathRight, paint);

    // 2. Draw End Points (Static)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(startPoint, 4, dotPaint);
    canvas.drawCircle(endPointLeft, 3, dotPaint);
    canvas.drawCircle(endPointRight, 3, dotPaint);

    // 3. Draw Moving Animation Dot
    final animPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    // Add subtle glow to moving dot

    _drawMovingDot(canvas, pathLeft, animPaint);
    _drawMovingDot(canvas, pathRight, animPaint);
  }

  void _drawMovingDot(Canvas canvas, Path path, Paint paint) {
    if (progress <= 0 || progress >= 1) return;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final length = metric.length;
      final distance = length * progress;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        canvas.drawCircle(tangent.position, 5, paint);

        // Optional: Draw a fading tail? (Maybe too complex for now, keep it simple dot)
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiagramConnectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}

class _BookedDatesList extends StatelessWidget {
  final dynamic bookedDates;
  final bool isDark;
  final ChaletDetailCubit cubit;

  const _BookedDatesList({
    required this.bookedDates,
    required this.isDark,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (bookedDates == null ||
        (bookedDates is List && (bookedDates as List).isEmpty)) {
      return const SizedBox.shrink();
    }

    final List<dynamic> dates = bookedDates as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 16,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Booked Dates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dates.take(5).map((date) {
            String formattedDate = '';
            if (date is Timestamp) {
              formattedDate = cubit.formatDate(date);
            } else if (date is String) {
              formattedDate = date;
            } else if (date is DateTime) {
              formattedDate = cubit.formatDate(date);
            } else {
              formattedDate = date.toString();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : ColorsManager.chaletUnavailableRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? Colors.transparent
                      : ColorsManager.chaletUnavailableRed.withOpacity(0.2),
                ),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white70
                      : ColorsManager.chaletUnavailableRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
