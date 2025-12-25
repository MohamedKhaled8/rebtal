import 'package:flutter/material.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentProofUploadPage extends StatefulWidget {
  final Booking booking;
  final PaymentMethod paymentMethod;
  final double amount;

  const PaymentProofUploadPage({
    super.key,
    required this.booking,
    required this.paymentMethod,
    required this.amount,
  });

  @override
  State<PaymentProofUploadPage> createState() => _PaymentProofUploadPageState();
}

class _PaymentProofUploadPageState extends State<PaymentProofUploadPage> {
  bool _isSubmitting = false;
  // User requested this specific number for payments (Admin number)
  final String _adminPhone = '201008422234';
  bool _whatsAppOpened = false;

  @override
  void initState() {
    super.initState();
    // No need to fetch owner phone for payment if we are transferring to Admin
  }

  Future<void> _launchWhatsApp() async {
    final message = Uri.encodeComponent(
      'مرحباً، لقد قمت بتحويل مبلغ ${widget.amount} لحجز شاليه ${widget.booking.chaletName} رقم الحجز: ${widget.booking.id.substring(0, 8)}',
    );

    // Use the fixed admin number
    final url = Uri.parse('whatsapp://send?phone=$_adminPhone&text=$message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // Fallback to web whatsapp
        final webUrl = Uri.parse('https://wa.me/$_adminPhone?text=$message');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح واتساب. يرجى التأكد من تثبيت التطبيق.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    } finally {
      // Reveal Step 2 after attempting to open WhatsApp
      if (mounted) {
        setState(() {
          _whatsAppOpened = true;
        });
      }
    }
  }

  Future<void> _submitConfirmation() async {
    setState(() => _isSubmitting = true);

    try {
      // Send simplified confirmation without transaction details
      // We pass a special flag or message as transaction number to indicate WhatsApp method
      await context.read<BookingCubit>().uploadPaymentProof(
        bookingId: widget.booking.id,
        proofImageUrl: null,
        transactionNumber: 'SENT_VIA_WHATSAPP',
      );

      if (mounted) {
        // Navigate directly to booking confirmation page
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.bookingConfirmationPage,
          (route) => false,
          arguments: widget.booking,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ColorManager.chaletAccent;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0E27)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('خطوة الدفع الأخيرة'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 1: Instruction
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'الخطوة 1: إرسال الإيصال',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يرجى الضغط على الزر أدناه لإرسال صورة إيصال التحويل للمسؤول (Admin) عبر واتساب.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _launchWhatsApp,
                icon: const Icon(Icons.send_rounded),
                label: const Text('فتح واتساب وإرسال الإيصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const Spacer(),

              // Step 2: Confirmation (Only visible after clicking WhatsApp)
              if (_whatsAppOpened) ...[
                const Text(
                  'الخطوة 2: تأكيد العملية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'بعد إرسال الإيصال، اضغط هنا لتأكيد العملية وعرض الفاتورة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'تم الإرسال - عرض الفاتورة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
