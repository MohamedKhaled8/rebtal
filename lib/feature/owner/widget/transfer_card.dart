import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:intl/intl.dart';

class TransferCard extends StatelessWidget {
  final Booking booking;

  const TransferCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedTransferDate = booking.transferredAt != null
        ? dateFormat.format(booking.transferredAt!)
        : "";

    // Theme-based colors
    final cardColor = isDark ? const Color(0xFF161B30) : ColorManager.white;
    final primaryTextColor = isDark
        ? ColorManager.white
        : ColorManager.navyBlue0F3460;
    final accentBlue = isDark
        ? ColorManager.skyBlue0EA5E9
        : ColorManager.chaletActionBlue;
    final labelColor = isDark ? ColorManager.white24 : ColorManager.grey400;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: CustomPaint(
        painter: TicketPainter(
          color: cardColor,
          shadowColor: ColorManager.black.withOpacity(isDark ? 0.4 : 0.08),
          isDark: isDark,
        ),
        child: Column(
          children: [
            // Top Section: Tenant Comparison
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTicketBadge('نقل ملكية الحجز', isDark, accentBlue),
                      if (formattedTransferDate.isNotEmpty)
                        Text(
                          formattedTransferDate,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _TenantTicketInfo(
                          title: 'المستأجر القديم',
                          name: booking.originalTenantName ?? 'غير معروف',
                          phone: booking.originalTenantPhone ?? '---',
                          isDark: isDark,
                          primaryColor: isDark
                              ? ColorManager.orange
                              : ColorManager.orange,
                          textColor: primaryTextColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: accentBlue,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: _TenantTicketInfo(
                          title: 'المستأجر الجديد',
                          name: booking.userName,
                          phone: booking.userPhone ?? '---',
                          isDark: isDark,
                          primaryColor: ColorManager.chaletActionGreen,
                          textColor: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ), // Space for decorative cutter in painter
            // Bottom Section: Chalet Details
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('بيانات الحجز المحول', isDark, labelColor),
                  const SizedBox(height: 18),
                  _TicketDetailRow(
                    icon: Icons.villa_rounded,
                    label: 'اسم الشاليه:',
                    value: booking.chaletName,
                    isDark: isDark,
                    valueColor: primaryTextColor,
                    iconColor: accentBlue,
                  ),
                  _TicketDetailRow(
                    icon: Icons.calendar_month_rounded,
                    label: 'تاريخ الإقامة:',
                    value:
                        '${_formatShortDate(booking.from)} - ${_formatShortDate(booking.to)}',
                    isDark: isDark,
                    valueColor: primaryTextColor,
                    iconColor: accentBlue,
                  ),
                  _TicketDetailRow(
                    icon: Icons.payments_rounded,
                    label: 'قيمة الحجز:',
                    value: '${booking.amount?.toStringAsFixed(0)} EGP',
                    isDark: isDark,
                    valueColor: ColorManager.chaletAccent,
                    iconColor: accentBlue,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accentBlue.withOpacity(0.1)),
                      ),
                      child: Text(
                        'Booking ID: #${booking.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: accentBlue,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) => "${date.day}/${date.month}";

  Widget _buildTicketBadge(String title, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark, Color color) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _TenantTicketInfo extends StatelessWidget {
  final String title;
  final String name;
  final String phone;
  final bool isDark;
  final Color primaryColor;
  final Color textColor;

  const _TenantTicketInfo({
    required this.title,
    required this.name,
    required this.phone,
    required this.isDark,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            color: primaryColor.withOpacity(0.7),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor.withOpacity(0.05),
            child: Icon(Icons.person_rounded, size: 24, color: primaryColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phone,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? ColorManager.white38 : ColorManager.grey,
          ),
        ),
      ],
    );
  }
}

class _TicketDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color valueColor;
  final Color iconColor;

  const _TicketDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.valueColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? ColorManager.white54 : ColorManager.grey600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final bool isDark;

  TicketPainter({
    required this.color,
    required this.shadowColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Premium shadow
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDark ? 12 : 10);

    const double cutoutRadius = 12.0;
    const double cutoutYCenter = 0.53;

    final path = Path();
    path.moveTo(0, 24); // Rounded corners
    path.quadraticBezierTo(0, 0, 24, 0);
    path.lineTo(size.width - 24, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 24);

    // Right side with cutout
    path.lineTo(size.width, size.height * cutoutYCenter - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, size.height * cutoutYCenter + cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - 24);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 24,
      size.height,
    );
    path.lineTo(24, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 24);

    // Left side with cutout
    path.lineTo(0, size.height * cutoutYCenter + cutoutRadius);
    path.arcToPoint(
      Offset(0, size.height * cutoutYCenter - cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Subtle dashed line
    final dashPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.05)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 5;
    double currentX = cutoutRadius + 12;
    final y = size.height * cutoutYCenter;

    while (currentX < size.width - cutoutRadius - 12) {
      canvas.drawLine(
        Offset(currentX, y),
        Offset(currentX + dashWidth, y),
        dashPaint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Additional decorative side indicators for premium feel
    if (!isDark) {
      final accentPaint = Paint()
        ..color = ColorManager.chaletActionBlue.withOpacity(0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(const Offset(40, 0), const Offset(80, 0), accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
