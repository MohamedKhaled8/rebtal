import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class DeliveryPolicyPage extends StatelessWidget {
  const DeliveryPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF001409) : ColorManager.white,
      appBar: AppBar(
        title: const Text('Booking & Confirmation'),
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
              'Booking & Confirmation Policy',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              isDark: isDark,
              icon: Icons.check_circle_outline,
              title: 'Instant Confirmation',
              content:
                  'Once your booking is submitted and payment is processed, you will receive an instant confirmation via email and in-app notification. Your booking details will be immediately available in your account.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.schedule,
              title: 'Booking Timeline',
              content:
                  'You can book a chalet up to 6 months in advance. Last-minute bookings are accepted subject to availability. We recommend booking at least 48 hours before your desired check-in date for the best availability.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.key,
              title: 'Check-In Process',
              content:
                  '• Check-in time: As specified in the chalet listing (typically 2:00 PM)\n• You will receive check-in instructions 24 hours before arrival\n• Present your booking confirmation to the property owner\n• All guest information must be accurate and verified',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.exit_to_app,
              title: 'Check-Out Process',
              content:
                  '• Check-out time: As specified in the chalet listing (typically 12:00 PM)\n• Please leave the chalet in good condition\n• Return all keys and access cards\n• Late check-out may be available upon request (additional fees may apply)',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.verified_user,
              title: 'Booking Verification',
              content:
                  'All bookings are subject to verification by the property owner. In rare cases, a booking may be declined. If this occurs, you will receive a full refund within 3-5 business days.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.info_outline,
              title: 'Important Information',
              content:
                  '• Bring a valid ID for check-in\n• Review house rules before your stay\n• Maximum occupancy must be respected\n• Smoking and pet policies vary by property\n• Contact the owner for any special requests',
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.support_agent,
              title: 'Support During Your Stay',
              content:
                  'Our support team is available 24/7 to assist you during your stay. Contact us immediately if you encounter any issues with the property or have questions about your booking.',
            ),
            const SizedBox(height: 32),

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
                    Icons.phone_in_talk,
                    color: ColorManager.profileAccent,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Need help with your booking?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Call us at 01507277511\nEmail: reservationsystem07@gmail.com',
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
