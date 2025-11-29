import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/painter/pattern_painter.dart';
import 'package:rebtal/feature/profile/widget/modern_profile_item.dart';
import 'package:rebtal/feature/profile/widget/switch_action_tile.dart';
import 'package:rebtal/feature/profile/widget/stat_card.dart';
import 'package:rebtal/feature/profile/widget/modern_action_tile.dart';
import 'package:rebtal/feature/profile/widget/chalet_management_tile.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'package:rebtal/feature/profile/utils/profile_helper.dart';

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
                                Colors.white,
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
                        Container(
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
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: ColorManager.getProfileSurfaceAlt(
                              isDark,
                            ),
                            child: Text(
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
                          color: const Color(0xFF3DDC84),
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
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.1),
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
                          iconColor: const Color(0xFF3DDC84),
                        ),
                        ModernProfileItem(
                          icon: Icons.access_time,
                          label: 'تاريخ الإنشاء',
                          value: ProfileHelper.formatDate(user.createdAt),
                          iconColor: const Color(0xFFEAB308),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.role.toLowerCase() == 'owner') ...[
                    Container(
                      decoration: BoxDecoration(
                        color: ColorManager.getProfileSurfaceAlt(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.1),
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
                            color: const Color(0xFF3DDC84),
                            onTap: () =>
                                onNavigateToChalets(context, 'approved'),
                          ),
                          ChaletManagementTile(
                            icon: Icons.cancel_outlined,
                            title: 'الشاليهات المرفوضة',
                            subtitle: 'عرض الشاليهات المرفوضة',
                            color: const Color(0xFFEF4444),
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
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.1),
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
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'الإجراءات',
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
                              onChanged: (_) {
                                DynamicThemeManager.toggleTheme(context);
                              },
                            );
                          },
                        ),
                        ModernActionTile(
                          icon: Icons.translate,
                          title: 'اللغة',
                          subtitle: 'اختيار لغة العرض',
                          color: const Color(0xFFEAB308),
                          onTap: () {},
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
