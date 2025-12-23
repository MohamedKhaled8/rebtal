import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF001409) : ColorManager.white,
      appBar: AppBar(
        title: const Text('Refund & Cancellation'),
        backgroundColor: isDark ? const Color(0xFF001409) : ColorManager.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refund & Cancellation Policy',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              isDark: isDark,
              icon: Icons.event_busy,
              title: 'Cancellation Rules',
              content:
                  'You can cancel your booking through the app. Cancellation policies vary by property and are clearly stated at the time of booking. Please review the specific cancellation terms before confirming your reservation.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.schedule,
              title: 'Flexible Cancellation',
              content:
                  '• Cancel up to 48 hours before check-in: 100% refund\n• Cancel 24-48 hours before check-in: 50% refund\n• Cancel less than 24 hours before check-in: No refund\n• No-show: No refund',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.security,
              title: 'Strict Cancellation',
              content:
                  '• Cancel up to 7 days before check-in: 50% refund\n• Cancel less than 7 days before check-in: No refund\n• No-show: No refund',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.money_off,
              title: 'Non-Refundable',
              content:
                  'Some special offers and promotions are non-refundable. These bookings are clearly marked during the booking process. Once confirmed, these reservations cannot be cancelled or refunded.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.account_balance_wallet,
              title: 'Refund Processing',
              content:
                  '• Approved refunds are processed within 5-10 business days\n• Refunds are returned to the original payment method\n• You will receive a confirmation email once the refund is processed\n• Bank processing may take additional 3-5 business days',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.warning_amber,
              title: 'Special Circumstances',
              content:
                  'In case of emergencies or unforeseen circumstances (natural disasters, medical emergencies, etc.), please contact us directly. We will review your case and work with the property owner to find a fair solution.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.edit_calendar,
              title: 'Booking Modifications',
              content:
                  'You can request to modify your booking dates subject to availability and property approval. Modifications may incur additional charges based on price differences and modification policies.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.contact_support,
              title: 'Dispute Resolution',
              content:
                  'If you have any issues with your booking or refund, please contact us immediately. We are committed to resolving all disputes fairly and promptly. Our support team will mediate between you and the property owner.',
            ),
            const SizedBox(height: 32),

            // Important Notice
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Always review the specific cancellation policy for your chosen property before booking. Policies may vary.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorManager.profileAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorManager.profileAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.headset_mic,
                    color: ColorManager.profileAccent,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Questions about cancellations?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact us: 01507277511\nreservationsystem07@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
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

  Widget _buildSection({
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorManager.profileAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ColorManager.profileAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
