import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/Router/routes.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/booking_helper.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/feature/booking/ui/rating_page.dart';

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
    // Check if payment was rejected (awaitingPayment with paymentRejected flag or adminPaymentNotes)
    final isPaymentRejected =
        booking.status == BookingStatus.awaitingPayment &&
        (booking.paymentRejected == true ||
            (booking.adminPaymentNotes != null &&
                booking.adminPaymentNotes!.isNotEmpty));
    final isApproved =
        booking.status == BookingStatus.approved ||
        (booking.status == BookingStatus.awaitingPayment && !isPaymentRejected);
    final isConfirmed = booking.status == BookingStatus.confirmed;
    final isRejected =
        booking.status == BookingStatus.rejected ||
        booking.status == BookingStatus.cancelled ||
        isPaymentRejected;

    // ألوان الحالة
    final Color statusColor = isPaymentRejected
        ? const Color(0xFFEF4444) // Red for payment rejected
        : isConfirmed
        ? const Color(0xFF10B981) // Green for confirmed
        : isApproved
        ? const Color(0xFF10B981) // Green for approved/accepted
        : isRejected
        ? const Color(0xFFEF4444)
        : booking.status == BookingStatus.paymentUnderReview
        ? const Color(0xFF3B82F6) // Blue for under review
        : const Color(0xFFF59E0B); // Orange for pending/awaiting

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      // ... (Rest of decoration is same, we only want to change the button logic)
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
          if (isApproved || isConfirmed)
            BoxShadow(
              color: statusColor.withOpacity(0.05),
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
            // ... (Same Stack children until ElevatedButton)
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              isConfirmed
                                  ? 'مؤكد'
                                  : isApproved
                                  ? 'مقبول'
                                  : isRejected
                                  ? (isPaymentRejected ? 'مرفوض' : 'مرفوض')
                                  : booking.status ==
                                        BookingStatus.paymentUnderReview
                                  ? 'قيد المراجعة'
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
                  Divider(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    height: 1,
                  ),
                  const SizedBox(height: 20),
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
                  // Show contact buttons if payment was rejected
                  if (isPaymentRejected) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'تم رفض إثبات الدفع',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (booking.adminPaymentNotes != null &&
                              booking.adminPaymentNotes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'السبب: ${booking.adminPaymentNotes}',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    UriLauncherService.launchWhatsAppContact(
                                      context: context,
                                      phone: '201008422234',
                                      message:
                                          'مرحباً، تم رفض إثبات الدفع لحجز رقم: ${booking.id.substring(0, 8)}',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'واتساب',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    UriLauncherService.launchPhoneCall(
                                      context,
                                      '201008422234',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.phone_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'اتصال',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Show contact buttons if payment was rejected, otherwise show normal button
                  if (isPaymentRejected)
                    const SizedBox.shrink() // Contact buttons already shown above
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApproved
                              ? const Color(0xFF1ED760)
                              : isConfirmed
                              ? Colors.redAccent.shade400
                              : (isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100),
                          foregroundColor: isApproved || isConfirmed
                              ? Colors.white
                              : (isDarkMode
                                    ? Colors.white54
                                    : Colors.grey.shade600),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: isApproved || isConfirmed ? 4 : 0,
                          shadowColor: isApproved || isConfirmed
                              ? Colors.black26
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isApproved
                            ? () => _payNow(context, booking)
                            : isConfirmed
                            ? () => _confirmCancel(context, booking)
                            : booking.status == BookingStatus.completed
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RatingPage(booking: booking),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isApproved) ...[
                              const Icon(Icons.payment_rounded, size: 20),
                              const SizedBox(width: 8),
                            ],
                            if (isConfirmed) ...[
                              const Icon(
                                Icons.cancel_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (booking.status == BookingStatus.completed) ...[
                              const Icon(Icons.star_rounded, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isApproved
                                  ? 'إتمام الدفع'
                                  : isConfirmed
                                  ? 'إلغاء الحجز'
                                  : booking.status == BookingStatus.completed
                                  ? 'تقييم الشاليه'
                                  : isRejected
                                  ? 'تم رفض هذا الطلب'
                                  : booking.status ==
                                        BookingStatus.paymentUnderReview
                                  ? 'جاري مراجعة الدفع'
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
    Navigator.pushNamed(
      context,
      Routes.paymentMethodSelection,
      arguments: {'booking': booking, 'totalAmount': booking.amount ?? 0.0},
    );
  }

  void _confirmCancel(BuildContext context, Booking booking) {
    // 1. Normalize Dates (Ignore Time) for accurate calculation
    final now = DateTime.now();

    // Today at midnight
    final dateToday = DateTime(now.year, now.month, now.day);

    // Check-in at midnight
    final dateCheckIn = DateTime(
      booking.from.year,
      booking.from.month,
      booking.from.day,
    );

    // Check-out at midnight
    final dateCheckOut = DateTime(
      booking.to.year,
      booking.to.month,
      booking.to.day,
    );

    // 2. Calculations
    final daysRemaining = dateCheckIn.difference(dateToday).inDays;
    final actualNights = dateCheckOut.difference(dateCheckIn).inDays;

    // الحصول على معلومات الاسترداد
    final refundInfo = BookingHelper.calculateRefund(
      booking.from,
      booking.amount ?? 0.0,
    );

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = DynamicThemeManager.isDarkMode(context);
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('سياسة إلغاء الحجز', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. عرض القواعد العامة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white10 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? Colors.white24 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قواعد الاسترداد:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPolicyRow(
                        '• 7 أيام أو أكثر:',
                        'استرداد كامل (100%)',
                        isDarkMode,
                      ),
                      _buildPolicyRow(
                        '• من 3 إلى 7 أيام:',
                        'استرداد (50%)',
                        isDarkMode,
                      ),
                      _buildPolicyRow(
                        '• أقل من 3 أيام:',
                        'غير مسترد (0%)',
                        isDarkMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. تفاصيل الحجز (مدة الحجز + المتبقي للوصول)
                Text(
                  'تفاصيل الحجز والتواريخ:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDateRow(
                  'مدة الحجز:',
                  '$actualNights ليالٍ (${_calculateDays(booking.from, booking.to)} أيام)',
                  isDarkMode,
                ),
                _buildDateRow(
                  'تاريخ الوصول:',
                  _formatDate(booking.from),
                  isDarkMode,
                ),
                _buildDateRow(
                  'المتبقي للوصول:',
                  daysRemaining < 0
                      ? 'مضى موعد الوصول'
                      : (daysRemaining == 0 ? 'اليوم' : '$daysRemaining يوم'),
                  isDarkMode,
                  isBold: true,
                  valueColor: daysRemaining < 0 ? Colors.red : null,
                ),

                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    refundInfo.message,
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),

                const Divider(height: 24),

                // 3. الحسبة المالية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المبلغ المدفوع:',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white60
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${(booking.amount ?? 0).toStringAsFixed(0)} جنية',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'قيمة الخصم:',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white60
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '-${((booking.amount ?? 0) - refundInfo.refundAmount).toStringAsFixed(0)} جنية',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // المبلغ النهائي
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المبلغ المسترد:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${refundInfo.refundAmount.toStringAsFixed(0)} جنية',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode
                    ? Colors.white70
                    : Colors.grey.shade700,
              ),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AppCubit>().bookingCubit.cancelBookingWithRefund(
                  booking.id,
                  refundInfo.refundAmount,
                  refundInfo.message,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPolicyRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(
    String label,
    String value,
    bool isDarkMode, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white60 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
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
