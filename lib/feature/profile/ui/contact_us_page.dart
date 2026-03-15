import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
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
      path: 'rebtal.service@gmail.com',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarHelper.showSuccess(
      context,
      context.tr('profile_copied_clipboard').replaceFirst('{}', label),
      icon: Icons.copy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.profileBackgroundDark
          : ColorsManager.white,
      appBar: AppBar(
        title: Text(context.tr('profile_contact')),
        backgroundColor: isDark
            ? ColorsManager.transparent
            : ColorsManager.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? ColorsManager.white : ColorsManager.black,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? ColorsManager.white : ColorsManager.black,
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
                      ColorsManager.profileAccent.withValues(alpha: 0.2),
                      ColorsManager.profileAccent.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.contact_support_outlined,
                  size: 60,
                  color: ColorsManager.profileAccent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              context.tr('profile_get_in_touch'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('profile_contact_hint'),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
              ),
            ),
            const SizedBox(height: 32),

            // Contact Cards
            _buildContactCard(
              context,
              isDark: isDark,
              icon: Icons.phone,
              title: context.tr('profile_phone'),
              subtitle: '01507277511',
              onTap: _launchPhone,
              onCopy: () =>
                  _copyToClipboard(context, '01507277511', context.tr('profile_phone')),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              isDark: isDark,
              icon: Icons.person,
              title: context.tr('profile_contact_person'),
              subtitle: 'Mohamed Khaled Elsayed Khalil',
              onTap: null,
              onCopy: () => _copyToClipboard(
                context,
                'Mohamed Khaled Elsayed Khalil',
                context.tr('profile_contact_person'),
              ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              isDark: isDark,
              icon: Icons.email,
              title: context.tr('profile_email'),
              subtitle: 'rebtal.service@gmail.com',
              onTap: _launchEmail,
              onCopy: () => _copyToClipboard(
                context,
                'rebtal.service@gmail.com',
                context.tr('profile_email'),
              ),
            ),

            const SizedBox(height: 32),

            // Support Hours
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? ColorsManager.darkGreen0A2A1D.withValues(alpha: 0.5)
                    : ColorsManager.profileAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? ColorsManager.profileAccent.withValues(alpha: 0.2)
                      : ColorsManager.profileAccent.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: ColorsManager.profileAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('profile_support_hours_title'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? ColorsManager.white
                              : ColorsManager.chaletTextPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('profile_support_hours_content'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? ColorsManager.white70
                          : ColorsManager.grey600,
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
            : ColorsManager.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? ColorsManager.white.withValues(alpha: 0.1)
              : ColorsManager.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: ColorsManager.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: ColorsManager.transparent,
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
                    color: ColorsManager.profileAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: ColorsManager.profileAccent,
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
                          color: isDark
                              ? ColorsManager.white70
                              : ColorsManager.grey600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? ColorsManager.white
                              : ColorsManager.chaletTextPrimaryLight,
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
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey600,
                  ),
                  tooltip: 'Copy',
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark
                        ? ColorsManager.white70
                        : ColorsManager.grey400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
