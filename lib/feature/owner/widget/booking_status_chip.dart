import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final bool isDark;
  final Booking? booking; // Add booking to check paymentRejected

  const BookingStatusChip({
    super.key,
    required this.status,
    required this.isDark,
    this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 16,
            color: ColorsManager.white,
          ),
          const SizedBox(width: 6),
          Text(
            config['text'] as String,
            style: const TextStyle(
              color: ColorsManager.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(
    BuildContext context,
    BookingStatus status,
  ) {
    switch (status) {
      case BookingStatus.pending:
        return {
          'color': ColorsManager.orange,
          'text': context.tr('booking_status_pending'),
          'icon': Icons.schedule,
        };
      case BookingStatus.approved:
        return {
          'color': ColorsManager.chaletActionGreen,
          'text': context.tr('booking_status_accepted'),
          'icon': Icons.check_circle,
        };
      case BookingStatus.awaitingPayment:
        // Check if payment was rejected
        final isPaymentRejected =
            booking != null &&
            (booking!.paymentRejected == true ||
                (booking!.adminPaymentNotes != null &&
                    booking!.adminPaymentNotes!.isNotEmpty));
        return {
          'color': isPaymentRejected
              ? ColorsManager.red
              : ColorsManager.chaletActionBlue,
          'text': isPaymentRejected
              ? '${context.tr('booking_status_awaiting_payment')} - ${context.tr('booking_status_rejected')}'
              : context.tr('booking_status_awaiting_payment'),
          'icon': isPaymentRejected ? Icons.cancel : Icons.payment,
        };
      case BookingStatus.paymentUnderReview:
        return {
          'color': ColorsManager.purple,
          'text': context.tr('booking_status_payment_review'),
          'icon': Icons.hourglass_empty,
        };
      case BookingStatus.confirmed:
        return {
          'color': ColorsManager.teal,
          'text': context.tr('booking_status_confirmed'),
          'icon': Icons.verified,
        };
      case BookingStatus.completed:
        return {
          'color': ColorsManager.indigo6366F1,
          'text': context.tr('booking_status_completed'),
          'icon': Icons.done_all,
        };
      case BookingStatus.rejected:
        return {
          'color': ColorsManager.red,
          'text': context.tr('booking_status_rejected'),
          'icon': Icons.cancel,
        };
      case BookingStatus.cancelled:
        return {
          'color': ColorsManager.grey600,
          'text': context.tr('booking_status_cancelled'),
          'icon': Icons.block,
        };
      case BookingStatus.reOffered:
        return {
          'color': ColorsManager.chaletActionBlue,
          'text': context.tr('booking_status_under_discussion'),
          'icon': Icons.swap_horiz,
        };
      case BookingStatus.pendingOwnerApproval:
        return {
          'color': ColorsManager.orange,
          'text': context.tr('booking_status_awaiting_approval'),
          'icon': Icons.pending_actions,
        };
    }
  }
}
