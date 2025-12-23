import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF001409) : ColorManager.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              isDark: isDark,
              title: 'Information We Collect',
              content:
                  'We collect information that you provide directly to us when you create an account, make a booking, or contact us. This may include your name, email address, phone number, and booking preferences.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'How We Use Your Information',
              content:
                  'We use your information to:\n• Process and manage your bookings\n• Communicate with you about your reservations\n• Improve our services and user experience\n• Send important updates and notifications\n• Ensure security and prevent fraud',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Data Protection',
              content:
                  'We implement robust security measures to protect your personal information. Your data is encrypted and stored securely. We never sell or share your personal information with third parties for marketing purposes.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Your Rights',
              content:
                  'You have the right to:\n• Access your personal data\n• Request corrections to your information\n• Delete your account and associated data\n• Opt-out of promotional communications\n• Request a copy of your data',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Cookies and Tracking',
              content:
                  'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and remember your preferences. You can control cookie settings through your browser.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Third-Party Services',
              content:
                  'We may use third-party services for payment processing, analytics, and communication. These services have their own privacy policies and we encourage you to review them.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Children\'s Privacy',
              content:
                  'Our services are not intended for users under the age of 18. We do not knowingly collect personal information from children.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Changes to This Policy',
              content:
                  'We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the "Last updated" date.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us at reservationsystem07@gmail.com or call 01507277511.',
            ),
            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.profileAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColorManager.profileAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using our services, you agree to this Privacy Policy.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
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

  Widget _buildSection({
    required bool isDark,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
