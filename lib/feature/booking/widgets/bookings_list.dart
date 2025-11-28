import 'package:flutter/material.dart';
import 'package:rebtal/core/theme/dynamic_theme_manager.dart';

import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/feature/booking/ui/payment_checkout_page.dart';

class BookingsList extends StatelessWidget {
  final List<Booking> pendingBookings;
  final List<Booking> approvedBookings;
  final List<Booking> rejectedBookings;

  const BookingsList({
    super.key,
    required this.pendingBookings,
    required this.approvedBookings,
    required this.rejectedBookings,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (approvedBookings.isNotEmpty) ...[
            ...approvedBookings.map((b) => BookingCard(booking: b)),
            const SizedBox(height: 16),
          ],
          if (pendingBookings.isNotEmpty) ...[
            ...pendingBookings.map((b) => BookingCard(booking: b)),
            const SizedBox(height: 16),
          ],
          if (rejectedBookings.isNotEmpty) ...[
            ...rejectedBookings.map((b) => BookingCard(booking: b)),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = DynamicThemeManager.isDarkMode(context);
    final isApproved = booking.status == BookingStatus.approved;
    final isRejected = booking.status == BookingStatus.rejected;

    // ألوان الحالة
    final Color statusColor = isApproved
        ? const Color(0xFF10B981)
        : isRejected
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDarkMode
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1A1F1D), const Color(0xFF0B0F0D)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, const Color(0xFFF8F9FA)],
              ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          // تأثير توهج خفيف للحالات
          if (isApproved)
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // زخرفة خلفية خفيفة
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.03),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس البطاقة
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // أيقونة الشاليه
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.holiday_village_rounded,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // اسم الشاليه والمالك
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.chaletName,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: isDarkMode
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.ownerName,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // شارة الحالة
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isApproved
                                  ? 'مقبول'
                                  : isRejected
                                  ? 'مرفوض'
                                  : 'معلق',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // فاصل
                  Divider(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    height: 1,
                  ),

                  const SizedBox(height: 20),

                  // تفاصيل الحجز
                  Row(
                    children: [
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.calendar_today_rounded,
                          label: 'من',
                          value: _formatDate(booking.from),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.event_available_rounded,
                          label: 'إلى',
                          value: _formatDate(booking.to),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.nights_stay_rounded,
                          label: 'المدة',
                          value:
                              '${_calculateDays(booking.from, booking.to)} ليال',
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // زر الدفع أو الحالة النهائية
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApproved
                            ? const Color(0xFF1ED760)
                            : (isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade100),
                        foregroundColor: isApproved
                            ? Colors.black
                            : (isDarkMode
                                  ? Colors.white54
                                  : Colors.grey.shade600),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: isApproved ? 4 : 0,
                        shadowColor: isApproved
                            ? const Color(0xFF1ED760).withOpacity(0.4)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isApproved
                          ? () => _payNow(context, booking)
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isApproved) ...[
                            const Icon(Icons.payment_rounded, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            isApproved
                                ? 'إتمام الدفع'
                                : isRejected
                                ? 'تم رفض هذا الطلب'
                                : 'بانتظار موافقة المضيف',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }

  void _payNow(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentCheckoutPage(booking: booking)),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDarkMode ? Colors.white54 : Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
