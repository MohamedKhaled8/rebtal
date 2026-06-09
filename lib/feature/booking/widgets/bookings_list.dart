import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/Router/routes.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/booking_helper.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/ui/rating_page.dart';
import 'package:rebtal/feature/booking/ui/cancellation_details_page.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

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
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isRejected =
        booking.status == BookingStatus.rejected || isPaymentRejected;

    // ألوان الحالة
    final Color statusColor = isPaymentRejected
        ? const Color(0xFFEF4444) // Red for payment rejected
        : isConfirmed
        ? const Color(0xFF10B981) // Green for confirmed
        : isApproved
        ? const Color(0xFF10B981) // Green for approved/accepted
        : isCancelled
        ? ColorsManager.grey600
        : isRejected
        ? const Color(0xFFEF4444)
        : booking.status == BookingStatus.paymentUnderReview
        ? const Color(0xFF3B82F6) // Blue for under review
        : booking.status == BookingStatus.reOffered
        ? const Color(0xFF2196F3) // Blue for re-offered
        : booking.status == BookingStatus.pendingOwnerApproval
        ? const Color(0xFF9C27B0) // Purple for action required
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
                                  ? context.tr('booking_status_confirmed')
                                  : isCancelled
                                  ? context.tr('booking_status_cancelled')
                                  : isApproved
                                  ? context.tr('booking_status_accepted')
                                  : isRejected
                                  ? context.tr('booking_status_rejected')
                                  : booking.status ==
                                        BookingStatus.paymentUnderReview
                                  ? context.tr('booking_status_payment_review')
                                  : context.tr('booking_status_pending'),
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
                          label: context.tr('booking_from'),
                          value: _formatDate(booking.from),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.event_available_rounded,
                          label: context.tr('booking_to'),
                          value: _formatDate(booking.to),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.nights_stay_rounded,
                          label: context.tr('booking_duration'),
                          value:
                              '${_calculateNights(booking.from, booking.to)} ${context.tr('booking_nights')}',
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
                                  context.tr(
                                    'booking_payment_rejected_msg_short',
                                  ),
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
                              '${context.tr('common_reason')} ${booking.adminPaymentNotes}',
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
                                          '${context.tr('booking_whatsapp_contact')} ${booking.id.substring(0, 8)}',
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    context.tr('booking_whatsapp'),
                                    style: const TextStyle(fontSize: 13),
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
                                  label: Text(
                                    context.tr('booking_call'),
                                    style: const TextStyle(fontSize: 13),
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
                  else if (isConfirmed)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CancellationDetailsPage(booking: booking),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  context.tr('booking_cancel_booking'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () => _reList(context, booking),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swap_horiz, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  context.tr('booking_reoffer'),
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
                    )
                  else if (booking.status == BookingStatus.pending)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent.shade400,
                          side: BorderSide(color: Colors.redAccent.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _showPendingCancelDialog(context, booking),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cancel_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('booking_cancel_booking'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApproved
                              ? const Color(0xFF1ED760)
                              : booking.status == BookingStatus.reOffered
                              ? const Color(0xFF2196F3)
                              : (isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100),
                          foregroundColor:
                              isApproved ||
                                  booking.status == BookingStatus.reOffered
                              ? Colors.white
                              : (isDarkMode
                                    ? Colors.white54
                                    : Colors.grey.shade600),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation:
                              isApproved ||
                                  booking.status == BookingStatus.reOffered
                              ? 4
                              : 0,
                          shadowColor:
                              isApproved ||
                                  booking.status == BookingStatus.reOffered
                              ? Colors.black26
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isApproved
                            ? () => _payNow(context, booking)
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
                            : booking.status == BookingStatus.reOffered
                            ? () {
                                // Undo re-offer logic if needed
                              }
                            : booking.status ==
                                  BookingStatus.pendingOwnerApproval
                            ? () => _finalizeTransfer(context, booking)
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isApproved) ...[
                              const Icon(Icons.payment_rounded, size: 20),
                              const SizedBox(width: 8),
                            ],
                            if (booking.status == BookingStatus.completed) ...[
                              const Icon(Icons.star_rounded, size: 20),
                              const SizedBox(width: 8),
                            ],
                            if (booking.status ==
                                BookingStatus.pendingOwnerApproval) ...[
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              isApproved
                                  ? context.tr('booking_complete_payment')
                                  : booking.status == BookingStatus.completed
                                  ? context.tr('booking_rate_chalet')
                                  : isCancelled
                                  ? context.tr('booking_cancelled_msg')
                                  : isRejected
                                  ? context.tr('booking_status_rejected')
                                  : booking.status ==
                                        BookingStatus.paymentUnderReview
                                  ? context.tr('booking_status_payment_review')
                                  : booking.status == BookingStatus.reOffered
                                  ? context.tr(
                                      'booking_status_under_discussion',
                                    )
                                  : booking.status ==
                                        BookingStatus.pendingOwnerApproval
                                  ? context.tr('booking_final_approval')
                                  : context.tr('booking_awaiting_host'),
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
    final span = to.difference(from).inDays.clamp(0, 365);
    return span + 1;
  }

  int _calculateNights(DateTime from, DateTime to) {
    return to.difference(from).inDays.clamp(0, 365);
  }

  void _payNow(BuildContext context, Booking booking) {
    Navigator.pushNamed(
      context,
      Routes.paymentMethodSelection,
      arguments: {'booking': booking, 'totalAmount': booking.amount ?? 0.0},
    );
  }

  void _finalizeTransfer(BuildContext context, Booking booking) async {
    try {
      final appCubit = context.read<AppCubit>();
      await appCubit.bookingCubit.finalizeTransfer(booking.id);

      if (context.mounted) {
        // Refresh list
        final currentState = appCubit.state;
        if (currentState is AppAuthenticated) {
          appCubit.bookingCubit.loadUserBookings(currentState.user.uid);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('booking_transfer_success_msg'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('booking_error_msg')} $e')),
        );
      }
    }
  }

  void _confirmCancel(BuildContext context, Booking booking) {
    // 1. Normalize Dates (Ignore Time) for accurate calculation
    final now = DateTime.now();

    // Today at midnight
    final dateToday = DateTime(now.year, now.month, now.day);

    final dateCheckIn = DateTime(
      booking.from.year,
      booking.from.month,
      booking.from.day,
    );

    final daysRemaining = dateCheckIn.difference(dateToday).inDays;

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
              Text(
                context.tr('booking_cancellation_policy_title'),
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCancellationPolicyCard(
                  isDarkMode,
                  title: context.tr('booking_policy_7_nights'),
                  text: context.tr('booking_policy_7_refund'),
                  color: const Color(0xFF4CAF50),
                  isActive: refundInfo.tier == 0,
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 10),
                _buildCancellationPolicyCard(
                  isDarkMode,
                  title: context.tr('booking_policy_3_6_nights'),
                  text: context.tr('booking_policy_3_6_refund'),
                  color: const Color(0xFFFF9800),
                  isActive: refundInfo.tier == 1,
                  icon: Icons.savings_outlined,
                ),
                const SizedBox(height: 10),
                _buildCancellationPolicyCard(
                  isDarkMode,
                  title: context.tr('booking_policy_less_3'),
                  text: context.tr('booking_policy_less_3_refund'),
                  color: const Color(0xFFF44336),
                  isActive: refundInfo.tier == 2,
                  icon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 10),
                _buildCancellationPolicyCard(
                  isDarkMode,
                  title: context.tr('booking_policy_same_day'),
                  text: context.tr('booking_policy_no_refund'),
                  color: const Color(0xFFD32F2F),
                  isActive: refundInfo.tier == 3,
                  icon: Icons.block_rounded,
                ),

                const SizedBox(height: 20),

                // 2. تفاصيل الحجز (مدة الحجز + المتبقي للوصول)
                Text(
                  context.tr('booking_details_dates'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDateRow(
                  context.tr('booking_duration'),
                  '${_calculateDays(booking.from, booking.to)} ${context.tr('booking_days_label')}, ${_calculateNights(booking.from, booking.to)} ${context.tr('booking_nights')}',
                  isDarkMode,
                ),
                _buildDateRow(
                  context.tr('booking_arrival_date'),
                  _formatDate(booking.from),
                  isDarkMode,
                ),
                _buildDateRow(
                  context.tr('booking_remaining'),
                  daysRemaining < 0
                      ? context.tr('booking_arrival_passed_short')
                      : (daysRemaining == 0
                            ? context.tr('booking_today')
                            : context
                                  .tr('booking_remaining_days')
                                  .replaceFirst(
                                    '{}',
                                    daysRemaining.toString(),
                                  )),
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
                      context.tr('booking_amount_paid'),
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white60
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${(booking.amount ?? 0).toStringAsFixed(0)} ${context.tr('booking_egp_currency')}',
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
                      context.tr('booking_discount_value'),
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white60
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '-${((booking.amount ?? 0) - refundInfo.refundAmount).toStringAsFixed(0)} ${context.tr('booking_egp_currency')}',
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
                      Text(
                        context.tr('booking_refund_amount_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${refundInfo.refundAmount.toStringAsFixed(0)} ${context.tr('booking_egp_currency')}',
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
              child: Text(context.tr('booking_revert_btn')),
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
              child: Text(context.tr('booking_confirm_cancel_btn')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCancellationPolicyCard(
    bool isDarkMode, {
    required String title,
    required String text,
    required Color color,
    required bool isActive,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : color.withOpacity(0.4),
          width: isActive ? 2.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : color,
                  ),
                ),
              ],
            ),
          ),
          if (isActive) Icon(Icons.check_circle, color: color, size: 24),
        ],
      ),
    );
  }

  void _reList(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('booking_reoffer_dialog_title')),
        content: Text(context.tr('booking_reoffer_dialog_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('booking_revert_btn')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppCubit>().bookingCubit.updateBookingStatus(
                booking.id,
                BookingStatus.reOffered,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('booking_reoffer_success_snack')),
                ),
              );
            },
            child: Text(context.tr('booking_confirm_reoffer_btn')),
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

void _showPendingCancelDialog(BuildContext context, Booking booking) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(dialogContext.tr('booking_cancel_dialog_title')),
      content: Text(dialogContext.tr('booking_cancel_dialog_content')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(dialogContext.tr('common_no')),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final appCubit = context.read<AppCubit>();
            appCubit.bookingCubit.cancelBooking(booking.id);
            if (!context.mounted) return;
            final state = appCubit.state;
            if (state is AppAuthenticated) {
              appCubit.bookingCubit.loadUserBookings(state.user.uid);
            }
            SnackBarHelper.showSuccess(
              context,
              context.tr('booking_cancelled_msg'),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.shade400,
            foregroundColor: Colors.white,
          ),
          child: Text(dialogContext.tr('common_yes')),
        ),
      ],
    ),
  );
}
