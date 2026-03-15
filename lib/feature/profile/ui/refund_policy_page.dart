import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.profileBackgroundDark
          : ColorsManager.white,
      appBar: AppBar(
        title: Text(context.tr('profile_refund_cancel_title')),
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
              context.tr('profile_refund_cancel_title'),
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
              icon: Icons.event_busy,
              title: context.tr('profile_cancel_rules_title'),
              content: context.tr('profile_cancel_rules_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.schedule,
              title: context.tr('profile_flexible_cancel_title'),
              content: context.tr('profile_flexible_cancel_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.security,
              title: context.tr('profile_strict_cancel_title'),
              content: context.tr('profile_strict_cancel_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.money_off,
              title: context.tr('profile_non_refundable_title'),
              content: context.tr('profile_non_refundable_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.account_balance_wallet,
              title: context.tr('profile_refund_proc_title'),
              content: context.tr('profile_refund_proc_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.warning_amber,
              title: context.tr('profile_special_circ_title'),
              content: context.tr('profile_special_circ_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.edit_calendar,
              title: context.tr('profile_booking_mod_title'),
              content: context.tr('profile_booking_mod_content'),
            ),
            const SizedBox(height: 20),

            _buildSection(
              isDark: isDark,
              icon: Icons.contact_support,
              title: context.tr('profile_dispute_res_title'),
              content: context.tr('profile_dispute_res_content'),
            ),
            const SizedBox(height: 32),

            // Important Notice
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorsManager.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorsManager.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: ColorsManager.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('profile_review_specific_policy'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey600,
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
                color: ColorsManager.profileAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorsManager.profileAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.headset_mic,
                    color: ColorsManager.profileAccent,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('profile_questions_cancel'),
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
                    context
                        .tr('profile_questions_cancel_contact')
                        .replaceFirst('{}', '01507277511')
                        .replaceFirst('{}', 'rebtal.service@gmail.com'),
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
