import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF001409) : ColorManager.white,
      appBar: AppBar(
        title: const Text('About Us'),
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
            // App Icon/Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
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
                  Icons.villa,
                  size: 64,
                  color: ColorManager.profileAccent,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Welcome Text
            Text(
              'Welcome to Rebtal',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your trusted platform for chalet bookings',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mission
            _buildSection(
              isDark: isDark,
              icon: Icons.track_changes,
              title: 'Our Mission',
              content:
                  'نسعى لتسهيل عملية الوصول إلى الشاليهات المناسبة لعملائنا بأفضل الأسعار مع ضمان الأمان التام للحجز. نهدف إلى توفير تجربة استثنائية تجمع بين الراحة والموثوقية.',
            ),
            const SizedBox(height: 24),

            // Features
            _buildSection(
              isDark: isDark,
              icon: Icons.star_outline,
              title: 'What We Offer',
              content: '',
              child: Column(
                children: [
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.search,
                    title: 'Easy Search',
                    description:
                        'Find your perfect chalet with our advanced search filters',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.price_check_outlined,
                    title: 'Best Prices',
                    description:
                        'Competitive pricing and exclusive deals for our users',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.verified_user_outlined,
                    title: 'Secure Booking',
                    description:
                        'Safe and reliable booking process with instant confirmation',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    isDark: isDark,
                    icon: Icons.support_agent,
                    title: '24/7 Support',
                    description:
                        'Always here to help with any questions or concerns',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Why Choose Us
            _buildSection(
              isDark: isDark,
              icon: Icons.favorite_border,
              title: 'Why Choose Us',
              content:
                  'We connect chalet owners with guests looking for the perfect getaway. Our platform ensures transparency, security, and convenience for both parties. With verified listings and secure payment methods, you can book with confidence.',
            ),
            const SizedBox(height: 32),

            // CTA
            Center(
              child: Text(
                'Start exploring amazing chalets today!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.profileAccent,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.profileAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: ColorManager.profileAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
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
                color: isDark ? Colors.white70 : Colors.black54,
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
        Icon(icon, color: ColorManager.profileAccent, size: 24),
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
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
