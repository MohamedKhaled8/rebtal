import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.profileBackgroundDark
          : ColorsManager.white,
      appBar: AppBar(
        title: Text(context.tr('profile_privacy_policy_title')),
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
              context.tr('profile_privacy_policy_title'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('profile_last_updated').replaceFirst('{}', DateTime.now().year.toString()),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_info_collect_title'),
              content: context.tr('profile_info_collect_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_how_use_info_title'),
              content: context.tr('profile_how_use_info_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_data_protection_title'),
              content: context.tr('profile_data_protection_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_your_rights_title'),
              content: context.tr('profile_your_rights_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_cookies_tracking_title'),
              content: context.tr('profile_cookies_tracking_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_third_party_title'),
              content: context.tr('profile_third_party_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_children_privacy_title'),
              content: context.tr('profile_children_privacy_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_policy_changes_title'),
              content: context.tr('profile_policy_changes_content'),
            ),
            const SizedBox(height: 24),

            _buildSection(
              isDark: isDark,
              title: context.tr('profile_contact'),
              content: context
                  .tr('profile_privacy_policy_contact')
                  .replaceFirst('{}', 'rebtal.service@gmail.com')
                  .replaceFirst('{}', '01507277511'),
            ),
            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorsManager.profileAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: ColorsManager.profileAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('profile_privacy_agree_info'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? ColorsManager.white70
                            : ColorsManager.grey600,
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
