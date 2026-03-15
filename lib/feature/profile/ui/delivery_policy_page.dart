import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class DeliveryPolicyPage extends StatelessWidget {
  const DeliveryPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.profileBackgroundDark
          : ColorsManager.white,
      appBar: AppBar(
        title: Text(context.tr('profile_booking_confirm_title')),
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
            Text(
              context.tr('profile_booking_confirm_title'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              isDark: isDark,
              icon: Icons.check_circle_outline,
              title: context.tr('profile_instant_confirm_title'),
              content: context.tr('profile_instant_confirm_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.schedule,
              title: context.tr('profile_booking_timeline_title'),
              content: context.tr('profile_booking_timeline_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.key,
              title: context.tr('profile_checkin_proc_title'),
              content: context.tr('profile_checkin_proc_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.exit_to_app,
              title: context.tr('profile_checkout_proc_title'),
              content: context.tr('profile_checkout_proc_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.verified_user,
              title: context.tr('profile_booking_verify_title'),
              content: context.tr('profile_booking_verify_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.info_outline,
              title: context.tr('profile_important_info_title'),
              content: context.tr('profile_important_info_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.support_agent,
              title: context.tr('profile_stay_support_title'),
              content: context.tr('profile_stay_support_content'),
            ),
            const SizedBox(height: 32),

            // Contact Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorsManager.profileAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorsManager.profileAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.phone_in_talk,
                    color: ColorsManager.profileAccent,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('profile_support_contact_hint')
                        .replaceFirst('{}', '01507277511')
                        .replaceFirst('{}', 'rebtal.service@gmail.com'),
                    textAlign: TextAlign.center,
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
            color: ColorsManager.profileAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ColorsManager.profileAccent, size: 20),
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
                  color: isDark
                      ? ColorsManager.white
                      : ColorsManager.chaletTextPrimaryLight,
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
