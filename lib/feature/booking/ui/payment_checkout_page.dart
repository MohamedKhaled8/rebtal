import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rebtal/core/utils/helper/app_image_helper.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/services/paymob_service.dart';
import 'package:paymob_payment/paymob_payment.dart';

class PaymentCheckoutPage extends StatelessWidget {
  const PaymentCheckoutPage({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001409),
      appBar: AppBar(
        title: const Text('إتمام الدفع'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B0F0D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chalets')
            .doc(booking.chaletId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;

          // Debug: Print all chalet data
          print('🏠 Chalet data for ${booking.chaletId}:');
          data?.forEach((key, value) {
            print('  $key: $value (${value.runtimeType})');
          });

          final String image = (data != null)
              ? ((data['images'] is List && (data['images'] as List).isNotEmpty)
                    ? data['images'][0]
                    : (data['profileImage'] ?? ''))
              : '';
          final double pricePerNight = _parsePrice(data?['price']);
          final int nights = booking.to.difference(booking.from).inDays + 1;
          final double total = pricePerNight * nights;

          print('💰 Final calculation: $pricePerNight × $nights = $total');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0F0D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: image.isNotEmpty
                              ? AppImageHelper(path: image, fit: BoxFit.cover)
                              : Container(color: Colors.white12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        booking.chaletName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'من ${_formatDate(booking.from)} إلى ${_formatDate(booking.to)} · $nights ليالٍ',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تأكيد إلغاء الحجز'),
                                    content: const Text(
                                      'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('لا'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('نعم'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    await context
                                        .read<BookingCubit>()
                                        .updateBookingStatus(
                                          booking.id,
                                          BookingStatus.cancelled,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('تم إلغاء الحجز بنجاح'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('فشل إلغاء الحجز: $e'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              child: const Text('إلغاء الحجز'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                foregroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('Details'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الإجمالي',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pricePerNight > 0
                                      ? CurrencyFormatter.egp(total)
                                      : 'السعر غير متوفر',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            if (pricePerNight > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1ED760),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  pricePerNight > 0
                                      ? CurrencyFormatter.egp(
                                          pricePerNight,
                                          withSuffixPerNight: true,
                                        )
                                      : 'السعر غير متوفر',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1ED760),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 4,
                      shadowColor: const Color(0xFF1ED760).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: pricePerNight > 0
                        ? () => _processPayment(context, total)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment_rounded, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          pricePerNight > 0
                              ? 'ادفع الآن ${CurrencyFormatter.egp(total)}'
                              : 'السعر غير متوفر',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _parsePrice(dynamic priceField) {
    if (priceField == null) return 0;

    // If it's already a number, return it directly
    if (priceField is num) return priceField.toDouble();

    // Handle string prices - just extract the number, no currency conversion
    String priceStr = priceField.toString().trim();

    // Debug print to see what we're parsing
    print(
      '🔍 Original price field: "$priceField" (type: ${priceField.runtimeType})',
    );

    // Remove currency symbols and text, keep only numbers and decimal point
    final cleaned = priceStr.replaceAll(RegExp('[^0-9.]'), '');
    final parsed = double.tryParse(cleaned);

    print('🔍 Cleaned: "$cleaned", Parsed: $parsed');

    return parsed ?? 0;
  }

  Future<void> _processPayment(BuildContext context, double amount) async {
    try {
      // Initialize Paymob service
      final paymobService = PaymobService();
      paymobService.initialize();

      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Process payment
      final PaymobResponse? response = await paymobService.pay(
        context: context,
        amountInEGP: amount,
        onPayment: (response) {
          debugPrint('💳 Payment response: ${response.success}');
        },
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Handle payment response
      if (paymobService.isPaymentSuccessful(response)) {
        final transactionId = paymobService.getTransactionId(response) ?? '';

        // Update booking as paid
        await context.read<BookingCubit>().markBookingAsPaid(
          bookingId: booking.id,
          transactionId: transactionId,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم الدفع بنجاح'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ فشل الدفع، حاول مرة أخرى'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Payment error: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}
