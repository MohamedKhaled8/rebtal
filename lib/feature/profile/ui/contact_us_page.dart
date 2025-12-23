import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '01507277511');
    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'reservationsystem07@gmail.com',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF001409) : ColorManager.white,
      appBar: AppBar(
        title: const Text('Contact Us'),
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
            // Header Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.profileAccent.withValues(alpha: 0.2),
                      ColorManager.profileAccent.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.contact_support_outlined,
                  size: 60,
                  color: ColorManager.profileAccent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Get In Touch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re here to help! Reach out to us through any of the following methods.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Contact Cards
            _buildContactCard(
              context,
              isDark: isDark,
              icon: Icons.phone,
              title: 'Phone',
              subtitle: '01507277511',
              onTap: _launchPhone,
              onCopy: () =>
                  _copyToClipboard(context, '01507277511', 'Phone number'),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              isDark: isDark,
              icon: Icons.person,
              title: 'Contact Person',
              subtitle: 'Mohamed Khaled Elsayed Khalil',
              onTap: null,
              onCopy: () => _copyToClipboard(
                context,
                'Mohamed Khaled Elsayed Khalil',
                'Name',
              ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              isDark: isDark,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'reservationsystem07@gmail.com',
              onTap: _launchEmail,
              onCopy: () => _copyToClipboard(
                context,
                'reservationsystem07@gmail.com',
                'Email',
              ),
            ),

            const SizedBox(height: 32),

            // Support Hours
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A2A1D).withValues(alpha: 0.5)
                    : ColorManager.profileAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? ColorManager.profileAccent.withValues(alpha: 0.2)
                      : ColorManager.profileAccent.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: ColorManager.profileAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Support Hours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re available to assist you 24/7',
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

  Widget _buildContactCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A2A1D).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorManager.profileAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: ColorManager.profileAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: Icon(
                    Icons.copy,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  tooltip: 'Copy',
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
