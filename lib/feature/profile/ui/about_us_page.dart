import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? ColorsManager.profileBackgroundDark
          : ColorsManager.white,
      appBar: AppBar(
        title: Text(context.tr('profile_about_us_title')),
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
            // App Icon/Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
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
                  Icons.villa,
                  size: 64,
                  color: ColorsManager.profileAccent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Welcome Text
            Text(
              context.tr('profile_welcome_rebtal'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? ColorsManager.white
                    : ColorsManager.chaletTextPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('profile_trusted_platform'),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mission
            _buildSection(
              isDark: isDark,
              icon: Icons.track_changes,
              title: context.tr('profile_our_mission_title'),
              content: context.tr('profile_our_mission_content'),
            ),
            const SizedBox(height: 24),

            // Features
            _buildSection(
              isDark: isDark,
              icon: Icons.star_outline,
              title: context.tr('profile_what_we_offer_title'),
              content: '',
              child: Column(
                children: [
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.search,
                    title: context.tr('profile_easy_search'),
                    description: context.tr('profile_easy_search_desc'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.price_check_outlined,
                    title: context.tr('profile_best_prices'),
                    description: context.tr('profile_best_prices_desc'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.verified_user_outlined,
                    title: context.tr('profile_secure_booking'),
                    description: context.tr('profile_secure_booking_desc'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.support_agent,
                    title: context.tr('profile_support_24'),
                    description: context.tr('profile_support_24_desc'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Why Choose Us
            _buildSection(
              isDark: isDark,
              icon: Icons.favorite_border,
              title: context.tr('profile_why_choose_us_title'),
              content: context.tr('profile_why_choose_us_content'),
            ),
            const SizedBox(height: 32),

            // CTA
            Center(
              child: Text(
                context.tr('profile_start_exploring'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.profileAccent,
                ),
                textAlign: TextAlign.center,
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
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.darkGreen0A2A1D.withValues(alpha: 0.5)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsManager.profileAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ColorsManager.profileAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ColorsManager.white
                      : ColorsManager.chaletTextPrimaryLight,
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 16), child],
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ColorsManager.profileAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? ColorsManager.white
                      : ColorsManager.chaletTextPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
