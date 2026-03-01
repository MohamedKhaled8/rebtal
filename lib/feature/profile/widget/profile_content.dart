import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/profile/ui/user_invoices_page.dart';
import 'package:rebtal/feature/profile/ui/contact_us_page.dart';
import 'package:rebtal/feature/profile/ui/about_us_page.dart';
import 'package:rebtal/feature/profile/ui/privacy_policy_page.dart';
import 'package:rebtal/feature/profile/ui/delivery_policy_page.dart';
import 'package:rebtal/feature/profile/ui/refund_policy_page.dart';
import 'package:rebtal/feature/profile/ui/personal_info_page.dart';
import 'package:rebtal/feature/localization/language_selection_page.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// صفحة الإعدادات كما في التصميم: رأس الملف الشخصي + أقسام إعدادات الحساب، الدعم، القانونية، تفضيلات التطبيق.
class ProfileContent extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final Function(BuildContext, String) onNavigateToChalets;

  const ProfileContent({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onNavigateToChalets,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = DynamicThemeManager.isDarkMode(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // —— رأس الملف: صورة + اسم + إيميل + زر عرض الملف الشخصي ——
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => HelperImage().addProfilePicture(context),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.grey.shade800,
                            child: user.profileImageUrl != null &&
                                    user.profileImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(44),
                                    child: CachedNetworkImage(
                                      imageUrl: user.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      width: 88,
                                      height: 88,
                                      placeholder: (_, __) => const Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (_, __, ___) => Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '؟',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '؟',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF121212)
                                        : Colors.white,
                                    width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: subColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PersonalInfoPage(user: user),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(color: dividerColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('عرض الملف الشخصي'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // —— إعدادات الحساب ——
            _sectionTitle('إعدادات الحساب', textColor),
            SliverToBoxAdapter(
              child: _buildCard(
                context,
                cardColor,
                dividerColor,
                [
                  _settingsTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'المعلومات الشخصية',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PersonalInfoPage(user: user),
                      ),
                    ),
                    textColor: textColor,
                  ),
                  if (user.role.toLowerCase().trim() == 'owner')
                    _settingsTile(
                      context,
                      icon: Icons.home_work_outlined,
                      title: 'التبديل إلى وضع المالك',
                      subtitle: 'العودة لوحة التحكم أو التصفح',
                      onTap: () {
                        bottomNavIndex.value = 0;
                        context.read<AppCubit>().toggleViewMode();
                      },
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  _settingsTile(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'الفواتير والمدفوعات',
                    subtitle: 'عرض تفاصيل مدفوعاتك',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserInvoicesPage(),
                      ),
                    ),
                    textColor: textColor,
                    subColor: subColor,
                  ),
                ],
              ),
            ),

            // —— الدعم والمساعدة ——
            _sectionTitle('الدعم والمساعدة', textColor),
            SliverToBoxAdapter(
              child: _buildCard(
                context,
                cardColor,
                dividerColor,
                [
                  _settingsTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'اتصل بنا',
                    subtitle: 'فريق الدعم متاح للمساعدة',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactUsPage(),
                      ),
                    ),
                    textColor: textColor,
                    subColor: subColor,
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'عن التطبيق',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutUsPage(),
                      ),
                    ),
                    textColor: textColor,
                  ),
                ],
              ),
            ),

            // —— القانونية ——
            _sectionTitle('القانونية', textColor),
            SliverToBoxAdapter(
              child: _buildCard(
                context,
                cardColor,
                dividerColor,
                [
                  _settingsTile(
                    context,
                    icon: Icons.shield_outlined,
                    title: 'سياسة الخصوصية',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    ),
                    textColor: textColor,
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'الشروط والأحكام',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeliveryPolicyPage(),
                      ),
                    ),
                    textColor: textColor,
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.replay_outlined,
                    title: 'سياسة الاسترجاع',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RefundPolicyPage(),
                      ),
                    ),
                    textColor: textColor,
                  ),
                ],
              ),
            ),

            // —— تفضيلات التطبيق ——
            _sectionTitle('تفضيلات التطبيق', textColor),
            SliverToBoxAdapter(
              child: _buildCard(
                context,
                cardColor,
                dividerColor,
                [
                  BlocBuilder<AppCubit, AppState>(
                    buildWhen: (p, c) =>
                        p.themeMode != c.themeMode,
                    builder: (context, appState) {
                      final isDarkMode =
                          appState.themeMode == ThemeMode.dark;
                      return ListTile(
                        leading: Icon(
                          Icons.dark_mode_outlined,
                          color: textColor,
                          size: 24,
                        ),
                        title: Text(
                          'الوضع الليلي',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (_) =>
                              context.read<AppCubit>().toggleTheme(),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  _settingsTile(
                    context,
                    icon: Icons.language,
                    title: 'اللغة',
                    subtitle: 'العربية',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageSelectionPage(),
                      ),
                    ),
                    textColor: textColor,
                    subColor: subColor,
                  ),
                ],
              ),
            ),

            // —— تسجيل الخروج + الإصدار ——
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textColor,
                          side: BorderSide(color: dividerColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('تسجيل الخروج'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'الإصدار 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: subColor,
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Color cardColor,
    Color dividerColor,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(height: 1, color: dividerColor),
          ],
        ],
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? subColor,
  }) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final tx = textColor ?? (isDark ? Colors.white : Colors.black87);
    final sx = subColor ?? (isDark ? Colors.white54 : Colors.grey.shade600);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: tx, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: tx,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: sx),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
