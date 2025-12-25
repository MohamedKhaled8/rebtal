import 'package:flutter/material.dart';
import 'package:rebtal/feature/booking/models/booking.dart';

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;
  final bool isDark;

  const BookingStatusChip({
    super.key,
    required this.status,
    required this.isDark,
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'] as IconData, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            config['text'] as String,
            style: const TextStyle(
              color: Colors.white,
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
          'color': Colors.orange.shade600,
          'text': 'معلق',
          'icon': Icons.schedule,
        };
      case BookingStatus.approved:
        return {
          'color': Colors.green.shade600,
          'text': 'مقبول',
          'icon': Icons.check_circle,
        };
      case BookingStatus.awaitingPayment:
        return {
          'color': Colors.blue.shade600,
          'text': 'في انتظار الدفع',
          'icon': Icons.payment,
        };
      case BookingStatus.paymentUnderReview:
        return {
          'color': Colors.purple.shade600,
          'text': 'قيد المراجعة',
          'icon': Icons.hourglass_empty,
        };
      case BookingStatus.confirmed:
        return {
          'color': Colors.teal.shade600,
          'text': 'مؤكد',
          'icon': Icons.verified,
        };
      case BookingStatus.completed:
        return {
          'color': Colors.indigo.shade600,
          'text': 'مكتمل',
          'icon': Icons.done_all,
        };
      case BookingStatus.rejected:
        return {
          'color': Colors.red.shade600,
          'text': 'مرفوض',
          'icon': Icons.cancel,
        };
      case BookingStatus.cancelled:
        return {
          'color': Colors.grey.shade600,
          'text': 'ملغي',
          'icon': Icons.block,
        };
    }
  }
}
