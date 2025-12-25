import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/booking/models/booking.dart';
import 'package:rebtal/core/utils/services/uri_launcher_service.dart';
import 'package:rebtal/core/utils/format/currency.dart';
import 'package:rebtal/core/Router/routes.dart';

class PaymentInstructionsPage extends StatefulWidget {
  final Booking booking;
  final PaymentMethod? paymentMethod;
  final double? amount;

  const PaymentInstructionsPage({
    super.key,
    required this.booking,
    this.paymentMethod,
    this.amount,
  });

  @override
  State<PaymentInstructionsPage> createState() =>
      _PaymentInstructionsPageState();
}

class _PaymentInstructionsPageState extends State<PaymentInstructionsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('إتمام الدفع'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorManager.primaryColor, Color(0xFF00A896)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'المبلغ المطلوب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.egp(
                      widget.amount ?? widget.booking.amount ?? 0,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'رقم الحجز: #${widget.booking.id.substring(0, 8)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Payment Methods / Instructions
            Text(
              'طرق الدفع المتاحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Instapay / Wallet Card
            _buildMethodCard(
              context,
              isDark,
              icon: Icons.account_balance_wallet,
              title: 'المحافظ الإلكترونية / Instapay',
              details:
                  'يرجى التحويل إلى الرقم التالي:\n010XXXXXXXX', // TOOD: Fetch dynamic
              onCopy: () {},
            ),
            const SizedBox(height: 24),

            // Contact Owner Button
            OutlinedButton.icon(
              onPressed: () async {
                // Default owner phone or fetch
                final phone = '0100000000'; // Placeholder
                await UriLauncherService.launchWhatsAppContact(
                  context: context,
                  phone: phone,
                  message:
                      'مرحباً، بخصوص الحجز رقم ${widget.booking.id}\nلقد قمت بتحويل مبلغ ${widget.booking.amount}. مرفق الإيصال.',
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('تواصل مع المالك لإرسال الإيصال'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.paymentProofUpload,
                  arguments: {
                    'booking': widget.booking,
                    'paymentMethod':
                        widget.paymentMethod ??
                        widget.booking.paymentMethod ??
                        PaymentMethod.bankTransfer,
                    'amount': widget.amount ?? widget.booking.amount ?? 0.0,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.primaryColor,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'تأكيد الدفع (أدخل رقم العملية)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'سيقوم المالك بمراجعة الدفع وتأكيد حجزك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String details,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorManager.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ColorManager.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 20),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
