import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
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
import 'package:rebtal/feature/localization/logic/locale_cubit.dart';
import 'package:rebtal/feature/localization/ui/language_selection_page.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_contract.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

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
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // —— رأس الملف: صورة + اسم + إيميل + زر عرض الملف الشخصي ——
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  stv(
                    context: context,
                    mobile: 20.sw,
                    tablet: 24.sw,
                    desktop: 32.sw,
                  ),
                  otv(context: context, portrait: 24.sh, landscape: 12.sh),
                  stv(
                    context: context,
                    mobile: 20.sw,
                    tablet: 24.sw,
                    desktop: 32.sw,
                  ),
                  otv(context: context, portrait: 20.sh, landscape: 10.sh),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => getIt<HelperImageContract>()
                          .addProfilePicture(context),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: stv(
                              context: context,
                              mobile: 44.sw,
                              tablet: 54.sw,
                              desktop: 64.sw,
                            ),
                            backgroundColor: Colors.grey.shade800,
                            child:
                                user.profileImageUrl != null &&
                                    user.profileImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(44),
                                    child: CachedNetworkImage(
                                      imageUrl: user.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      width: 88,
                                      height: 88,
                                      placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
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
                              padding: EdgeInsets.all(
                                stv(
                                  context: context,
                                  mobile: 6.sw,
                                  tablet: 8.sw,
                                  desktop: 10.sw,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF121212)
                                      : Colors.white,
                                  width: 2,
                                ),
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
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 12.sh,
                        landscape: 6.sh,
                      ),
                    ),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: stv(
                          context: context,
                          mobile: 22.spScaled,
                          tablet: 26.spScaled,
                          desktop: 30.spScaled,
                        ),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 4.sh,
                        landscape: 2.sh,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: stv(
                          context: context,
                          mobile: 14.spScaled,
                          tablet: 16.spScaled,
                          desktop: 18.spScaled,
                        ),
                        color: subColor,
                      ),
                    ),
                    SizedBox(
                      height: otv(
                        context: context,
                        portrait: 14.sh,
                        landscape: 8.sh,
                      ),
                    ),
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
                        child: Text(context.tr('profile_view_profile')),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // —— إعدادات الحساب ——
            _sectionTitle(
              context,
              context.tr('profile_account_settings'),
              textColor,
            ),
            SliverToBoxAdapter(
              child: _buildCard(context, cardColor, dividerColor, [
                _settingsTile(
                  context,
                  icon: Icons.person_outline,
                  title: context.tr('profile_personal_info'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalInfoPage(user: user),
                    ),
                  ),
                  textColor: textColor,
                ),
                // Debug: Show role info
                if (user.role.toLowerCase().trim() == 'owner' ||
                    context.read<AppCubit>().getCurrentRole() == 'owner')
                  Builder(
                    builder: (context) {
                      final currentRole = context
                          .read<AppCubit>()
                          .getCurrentRole();
                      final userRole = user.role;
                      debugPrint(
                        '🔍 Profile: user.role=$userRole, currentRole=$currentRole',
                      );
                      return _settingsTile(
                        context,
                        icon: Icons.home_work_outlined,
                        title: currentRole == 'owner'
                            ? context.tr('profile_switch_to_user')
                            : context.tr('profile_switch_to_owner'),
                        subtitle: currentRole == 'owner'
                            ? context.tr('profile_switch_user_subtitle')
                            : context.tr('profile_switch_owner_subtitle'),
                        onTap: () {
                          bottomNavIndex.value = 0;
                          context.read<AppCubit>().toggleViewMode();
                        },
                        textColor: textColor,
                        subColor: subColor,
                      );
                    },
                  ),
                _settingsTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: context.tr('profile_invoices_payments'),
                  subtitle: context.tr('profile_invoices_subtitle'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserInvoicesPage()),
                  ),
                  textColor: textColor,
                  subColor: subColor,
                ),
              ]),
            ),

            // —— الدعم والمساعدة ——
            _sectionTitle(context, context.tr('profile_support'), textColor),
            SliverToBoxAdapter(
              child: _buildCard(context, cardColor, dividerColor, [
                _settingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: context.tr('profile_contact'),
                  subtitle: context.tr('profile_contact_subtitle'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsPage()),
                  ),
                  textColor: textColor,
                  subColor: subColor,
                ),
                _settingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: context.tr('profile_about_app'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  ),
                  textColor: textColor,
                ),
              ]),
            ),

            // —— القانونية ——
            _sectionTitle(context, context.tr('profile_legal'), textColor),
            SliverToBoxAdapter(
              child: _buildCard(context, cardColor, dividerColor, [
                _settingsTile(
                  context,
                  icon: Icons.shield_outlined,
                  title: context.tr('profile_privacy'),
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
                  title: context.tr('profile_terms'),
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
                  title: context.tr('profile_refund_policy'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RefundPolicyPage()),
                  ),
                  textColor: textColor,
                ),
              ]),
            ),

            // —— تفضيلات التطبيق ——
            _sectionTitle(
              context,
              context.tr('profile_app_preferences'),
              textColor,
            ),
            SliverToBoxAdapter(
              child: _buildCard(context, cardColor, dividerColor, [
                BlocBuilder<AppCubit, AppState>(
                  buildWhen: (p, c) => p.themeMode != c.themeMode,
                  builder: (context, appState) {
                    final isDarkMode = isEffectivelyDarkMode(
                      appState.themeMode,
                      MediaQuery.platformBrightnessOf(context),
                    );
                    return ListTile(
                      leading: Icon(
                        Icons.dark_mode_outlined,
                        color: textColor,
                        size: 24,
                      ),
                      title: Text(
                        context.tr('profile_dark_mode'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        value: isDarkMode,
                        onChanged: (_) {
                          context.read<AppCubit>().toggleTheme(
                            platformBrightness:
                                MediaQuery.platformBrightnessOf(context),
                          );
                        },
                        activeColor: CupertinoColors.activeBlue,
                      ),
                    );
                  },
                ),
                _settingsTile(
                  context,
                  icon: Icons.language,
                  title: context.tr('profile_language'),
                  subtitle:
                      context.read<AppCubit>().state.locale.languageCode == 'ar'
                      ? context.tr('language_arabic')
                      : context.tr('language_english'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => BlocProvider<LocaleCubit>(
                        create: (context) =>
                            LocaleCubit(appCubit: context.read<AppCubit>()),
                        child: const LanguageSelectionPage(),
                      ),
                    ),
                  ),
                  textColor: textColor,
                  subColor: subColor,
                ),
              ]),
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
                        child: Text(context.tr('profile_logout')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.read<AppCubit>().state.locale.languageCode == 'ar'
                          ? 'الإصدار 2.0.0'
                          : 'Version 2.0.0',
                      style: TextStyle(fontSize: 12, color: subColor),
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

  Widget _sectionTitle(BuildContext context, String title, Color textColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          stv(context: context, mobile: 20.sw, tablet: 24.sw, desktop: 32.sw),
          otv(context: context, portrait: 16.sh, landscape: 8.sh),
          stv(context: context, mobile: 20.sw, tablet: 24.sw, desktop: 32.sw),
          otv(context: context, portrait: 8.sh, landscape: 4.sh),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: stv(
              context: context,
              mobile: 16.spScaled,
              tablet: 18.spScaled,
              desktop: 20.spScaled,
            ),
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
      margin: EdgeInsets.symmetric(
        horizontal: stv(
          context: context,
          mobile: 20.sw,
          tablet: 24.sw,
          desktop: 32.sw,
        ),
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.sw),
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
      contentPadding: EdgeInsets.symmetric(
        horizontal: stv(
          context: context,
          mobile: 16.sw,
          tablet: 20.sw,
          desktop: 24.sw,
        ),
        vertical: otv(context: context, portrait: 4.sh, landscape: 2.sh),
      ),
      leading: Icon(
        icon,
        color: tx,
        size: stv(
          context: context,
          mobile: 24.spScaled,
          tablet: 28.spScaled,
          desktop: 32.spScaled,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: tx,
          fontSize: stv(
            context: context,
            mobile: 15.spScaled,
            tablet: 17.spScaled,
            desktop: 19.spScaled,
          ),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: stv(
                  context: context,
                  mobile: 12.spScaled,
                  tablet: 14.spScaled,
                  desktop: 16.spScaled,
                ),
                color: sx,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: stv(
          context: context,
          mobile: 14.spScaled,
          tablet: 16.spScaled,
          desktop: 18.spScaled,
        ),
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
