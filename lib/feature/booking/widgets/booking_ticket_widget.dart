import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:intl/intl.dart';

class BookingTicketWidget extends StatelessWidget {
  final Booking booking;
  final String? ownerPhone;

  const BookingTicketWidget({
    super.key,
    required this.booking,
    this.ownerPhone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final dateFormat = DateFormat('yyyy-MM-dd');
    final currencyFormat = NumberFormat.currency(
      symbol: 'EGP',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: CustomPaint(
        painter: TicketPainter(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 40,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'فاتورة الحجز',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Booking Receipt',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1, height: 1),
              const SizedBox(height: 20),

              // Chalet Details
              _buildSectionTitle('تفاصيل الشاليه', isDark),
              _buildDetailRow('الاسم:', booking.chaletName, isDark),
              _buildDetailRow(
                'الموقع:',
                booking.chaletLocation ?? 'غير محدد',
                isDark,
              ),

              const SizedBox(height: 16),

              // Host Details
              _buildSectionTitle('بيانات المضيف (المالك)', isDark),
              _buildDetailRow('الاسم:', booking.ownerName, isDark),
              _buildDetailRow(
                'الهاتف:',
                booking.ownerPhone ?? ownerPhone ?? 'غير متوفر',
                isDark,
              ),
              _buildDetailRow(
                'البريد:',
                booking.ownerEmail ?? 'غير متوفر',
                isDark,
              ),

              const SizedBox(height: 16),

              // Guest Details
              _buildSectionTitle('بيانات الضيف (أنت)', isDark),
              _buildDetailRow('الاسم:', booking.userName, isDark),
              _buildDetailRow(
                'الهاتف:',
                booking.userPhone ?? 'غير متوفر',
                isDark,
              ),
              _buildDetailRow(
                'البريد:',
                booking.userEmail ?? 'غير متوفر',
                isDark,
              ),

              const SizedBox(height: 16),
              _buildDashedLine(isDark),
              const SizedBox(height: 16),

              // Booking Dates
              _buildSectionTitle('تفاصيل الحجز', isDark),
              _buildDetailRow(
                'الوصول:',
                dateFormat.format(booking.from),
                isDark,
              ),
              _buildDetailRow(
                'المغادرة:',
                dateFormat.format(booking.to),
                isDark,
              ),
              _buildDetailRow(
                'المدة:',
                '${booking.to.difference(booking.from).inDays + 1} ليال',
                isDark,
              ),

              const SizedBox(height: 16),
              _buildDashedLine(isDark),
              const SizedBox(height: 16),

              // Payment Details
              _buildDetailRow(
                'المبلغ الإجمالي:',
                currencyFormat.format(booking.amount ?? 0),
                isDark,
                isBold: true,
                valueColor: const Color(0xFF10B981),
              ),
              _buildDetailRow(
                'حالة الدفع:',
                booking.status == BookingStatus.confirmed
                    ? 'مدفوع بالكامل'
                    : 'قيد المراجعة',
                isDark,
                valueColor: booking.status == BookingStatus.confirmed
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),

              const SizedBox(height: 24),
              // Barcode placeholder
              Center(
                child: Text(
                  'مسح للتفاصيل',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white30 : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  booking.id,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount =
            (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white30 : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
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

  TicketPainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    const double cutoutRadius = 12.0;
    const double cutoutY = 0.25; // Relative position from top

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * cutoutY - cutoutRadius);

    // Right cutout
    path.arcToPoint(
      Offset(size.width, size.height * cutoutY + cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.lineTo(0, size.height * cutoutY + cutoutRadius);

    // Left cutout
    path.arcToPoint(
      Offset(0, size.height * cutoutY - cutoutRadius),
      radius: const Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Draw dashed line
    final dashPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double currentX = cutoutRadius + 10;
    final y = size.height * cutoutY;

    while (currentX < size.width - cutoutRadius - 10) {
      canvas.drawLine(
        Offset(currentX, y),
        Offset(currentX + dashWidth, y),
        dashPaint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
