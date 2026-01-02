import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

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
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'] as IconData, size: 16, color: ColorManager.white),
          const SizedBox(width: 6),
          Text(
            config['text'] as String,
            style: const TextStyle(
              color: ColorManager.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return {
          'color': ColorManager.orange,
          'text': 'معلق',
          'icon': Icons.schedule,
        };
      case BookingStatus.approved:
        return {
          'color': ColorManager.chaletActionGreen,
          'text': 'مقبول',
          'icon': Icons.check_circle,
        };
      case BookingStatus.awaitingPayment:
        // Check if payment was rejected
        final isPaymentRejected = booking != null &&
            (booking!.paymentRejected == true ||
                (booking!.adminPaymentNotes != null &&
                    booking!.adminPaymentNotes!.isNotEmpty));
        return {
          'color': isPaymentRejected
              ? ColorManager.red
              : ColorManager.chaletActionBlue,
          'text': isPaymentRejected
              ? 'في انتظار الدفع - مرفوض'
              : 'في انتظار الدفع',
          'icon': isPaymentRejected ? Icons.cancel : Icons.payment,
        };
      case BookingStatus.paymentUnderReview:
        return {
          'color': ColorManager.purple,
          'text': 'قيد المراجعة',
          'icon': Icons.hourglass_empty,
        };
      case BookingStatus.confirmed:
        return {
          'color': ColorManager.teal,
          'text': 'مؤكد',
          'icon': Icons.verified,
        };
      case BookingStatus.completed:
        return {
          'color': ColorManager.indigo6366F1,
          'text': 'مكتمل',
          'icon': Icons.done_all,
        };
      case BookingStatus.rejected:
        return {
          'color': ColorManager.red,
          'text': 'مرفوض',
          'icon': Icons.cancel,
        };
      case BookingStatus.cancelled:
        return {
          'color': ColorManager.grey600,
          'text': 'ملغي',
          'icon': Icons.block,
        };
    }
  }
}
