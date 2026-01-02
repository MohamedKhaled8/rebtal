import 'package:flutter/material.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/navigation/ui/bottom_nav_controller.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/painter/pattern_painter.dart';
import 'package:rebtal/feature/profile/ui/user_invoices_page.dart';
import 'package:rebtal/feature/profile/widget/modern_profile_item.dart';
import 'package:rebtal/feature/profile/widget/switch_action_tile.dart';
import 'package:rebtal/feature/profile/widget/stat_card.dart';
import 'package:rebtal/feature/profile/widget/modern_action_tile.dart';
import 'package:rebtal/feature/profile/widget/chalet_management_tile.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:rebtal/feature/profile/utils/profile_helper.dart';
import 'package:rebtal/feature/profile/ui/contact_us_page.dart';
import 'package:rebtal/feature/profile/ui/about_us_page.dart';
import 'package:rebtal/feature/profile/ui/privacy_policy_page.dart';
import 'package:rebtal/feature/profile/ui/delivery_policy_page.dart';
import 'package:rebtal/feature/profile/ui/refund_policy_page.dart';
import 'package:rebtal/feature/localization/language_selection_page.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

    return Scaffold(
      backgroundColor: ColorManager.getProfileBackground(isDark),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: ColorManager.getProfileSurface(isDark),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                ColorManager.profileGradientDark1,
                                ColorManager.profileGradientDark2,
                              ]
                            : [
                                ColorManager.white,
                                ColorManager.profileBackgroundLight,
                              ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.08,
                    child: CustomPaint(painter: PatternPainter()),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => HelperImage().addProfilePicture(context),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  ColorManager.profileAccent.withOpacity(0.6),
                                  ColorManager.profileAccent.withOpacity(0.2),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor:
                                      ColorManager.getProfileSurfaceAlt(isDark),
                                  child:
                                      user.profileImageUrl != null &&
                                          user.profileImageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            52,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: user.profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 104,
                                            height: 104,
                                            placeholder: (context, url) => Container(
                                              color:
                                                  ColorManager.getProfileSurfaceAlt(
                                                    isDark,
                                                  ),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        ColorManager
                                                            .profileAccent,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Text(
                                                  user.name.isNotEmpty
                                                      ? user.name[0]
                                                            .toUpperCase()
                                                      : 'U',
                                                  style: TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorManager
                                                        .profileAccent,
                                                  ),
                                                ),
                                          ),
                                        )
                                      : Text(
                                          user.name.isNotEmpty
                                              ? user.name[0].toUpperCase()
                                              : 'U',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: ColorManager.profileAccent,
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorManager.profileAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            ColorManager.getProfileSurfaceAlt(
                                              isDark,
                                            ),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: ColorManager.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.getProfileTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.profileAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: ColorManager.profileAccent.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            ProfileHelper.getRoleText(user.role),
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorManager.profileAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: ColorManager.getProfileTextPrimary(isDark),
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.calendar_month,
                          value: ProfileHelper.calculateDays(user.createdAt),
                          label: 'أيام معنا',
                          color: ColorManager.profileAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          icon: Icons.verified_user,
                          value: 'نشط',
                          label: 'حالة الحساب',
                          color: ColorManager.green3DDC84,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.getProfileSurfaceAlt(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? ColorManager.white.withOpacity(0.06)
                            : ColorManager.black.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColorManager.profileAccent.withOpacity(
                                    0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: ColorManager.profileAccent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'معلومات الحساب',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.getProfileTextPrimary(
                                    isDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ModernProfileItem(
                          icon: Icons.email_outlined,
                          label: 'البريد الإلكتروني',
                          value: user.email,
                          iconColor: ColorManager.profileAccent,
                        ),
                        ModernProfileItem(
                          icon: Icons.phone_outlined,
                          label: 'رقم الهاتف',
                          value: user.phone,
                          iconColor: ColorManager.green3DDC84,
                        ),
                        ModernProfileItem(
                          icon: Icons.access_time,
                          label: 'تاريخ الإنشاء',
                          value: ProfileHelper.formatDate(user.createdAt),
                          iconColor: ColorManager.yellowEAB308,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Only show Chalet Management if the user is an Owner AND is in Owner View Mode
                  if (user.role.toLowerCase() == 'owner' &&
                      context.read<AuthCubit>().getCurrentRole() ==
                          'owner') ...[
                    Container(
                      decoration: BoxDecoration(
                        color: ColorManager.getProfileSurfaceAlt(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? ColorManager.white.withOpacity(0.06)
                              : ColorManager.black.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ColorManager.profileAccent
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.home_outlined,
                                    color: ColorManager.profileAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'إدارة الشاليهات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: ColorManager.getProfileTextPrimary(
                                      isDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ChaletManagementTile(
                            icon: Icons.check_circle_outline,
                            title: 'الشاليهات الموافق عليها',
                            subtitle: 'عرض الشاليهات المقبولة',
                            color: ColorManager.green3DDC84,
                            onTap: () =>
                                onNavigateToChalets(context, 'approved'),
                          ),
                          ChaletManagementTile(
                            icon: Icons.cancel_outlined,
                            title: 'الشاليهات المرفوضة',
                            subtitle: 'عرض الشاليهات المرفوضة',
                            color: ColorManager.chaletUnavailableRed,
                            onTap: () =>
                                onNavigateToChalets(context, 'rejected'),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      color: ColorManager.getProfileSurfaceAlt(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? ColorManager.white.withOpacity(0.06)
                            : ColorManager.black.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? ColorManager.white.withValues(
                                          alpha: 0.06,
                                        )
                                      : ColorManager.black.withValues(
                                          alpha: 0.06,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: isDark
                                      ? ColorManager.white70
                                      : ColorManager.grey600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'الإعدادات والدعم',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.getProfileTextPrimary(
                                    isDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user.role.toLowerCase().trim() == 'owner')
                          Builder(
                            builder: (context) {
                              final currentRole = context
                                  .read<AuthCubit>()
                                  .getCurrentRole();
                              final isOwnerView = currentRole == 'owner';
                              return ModernActionTile(
                                icon: isOwnerView
                                    ? Icons.person_outline
                                    : Icons.store_outlined,
                                title: isOwnerView
                                    ? 'وضع المستخدم'
                                    : 'وضع المالك',
                                subtitle: isOwnerView
                                    ? 'تصفح التطبيق كمستخدم'
                                    : 'العودة للوحة التحكم',
                                color: ColorManager.blue2563EB,
                                onTap: () {
                                  bottomNavIndex.value = 0;
                                  context.read<AuthCubit>().toggleViewMode();
                                },
                              );
                            },
                          ),
                        BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, themeState) {
                            final isDarkMode =
                                themeState.themeMode == ThemeMode.dark;
                            return SwitchActionTile(
                              icon: isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              title: isDarkMode
                                  ? 'الوضع الداكن'
                                  : 'الوضع النهاري',
                              subtitle: isDarkMode
                                  ? 'تفعيل المظهر الداكن'
                                  : 'تفعيل المظهر النهاري',
                              color: ColorManager.profileAccent,
                              value: isDarkMode,
                              onChanged: (value) {
                                context.read<ThemeCubit>().toggleTheme();
                              },
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.translate,
                          title: 'اللغة',
                          subtitle: 'اختيار لغة العرض | Language',
                          color: ColorManager.yellowEAB308,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LanguageSelectionPage(),
                              ),
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'الفواتير',
                          subtitle: 'عرض وتتبع فواتيرك ومدفوعاتك',
                          color: ColorManager.chaletActionGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserInvoicesPage(),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Divider(
                            height: 1,
                            color: isDark
                                ? ColorManager.white10
                                : ColorManager.black.withValues(alpha: 0.05),
                          ),
                        ),
                        ModernActionTile(
                          icon: Icons.contact_support_outlined,
                          title: 'اتصل بنا',
                          subtitle: 'لديك استفسار؟ تواصل معنا',
                          color: ColorManager.cyan06B6D4,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ContactUsPage(),
                              ),
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.info_outline,
                          title: 'عن التطبيق',
                          subtitle: 'تعرف على المزيد عنا',
                          color: ColorManager.purple8B5CF6,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutUsPage(),
                              ),
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'سياسة الخصوصية',
                          subtitle: 'كيف نحمي بياناتك',
                          color: ColorManager.chaletActionGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.local_shipping_outlined,
                          title: 'سياسة الحجز',
                          subtitle: 'شروط الحجز والتأكيد',
                          color: ColorManager.bookingsWarningOrange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeliveryPolicyPage(),
                              ),
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.cancel_outlined,
                          title: 'سياسة الإلغاء والاسترجاع',
                          subtitle: 'شروط الإلغاء والاسترداد',
                          color: ColorManager.chaletGalleryPink,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RefundPolicyPage(),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Divider(
                            height: 1,
                            color: isDark
                                ? ColorManager.white10
                                : ColorManager.black.withValues(alpha: 0.05),
                          ),
                        ),
                        ModernActionTile(
                          icon: Icons.logout_rounded,
                          title: 'تسجيل الخروج',
                          subtitle: 'الخروج من حسابك بأمان',
                          color: const Color(0xFFEF4444),
                          onTap: onLogout,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
