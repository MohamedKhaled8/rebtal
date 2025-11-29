import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/profile/widget/modern_profile_item.dart';
import 'package:rebtal/feature/profile/widget/switch_action_tile.dart';
import 'package:rebtal/feature/profile/widget/stat_card.dart';
import 'package:rebtal/feature/profile/widget/modern_action_tile.dart';
import 'package:rebtal/feature/profile/widget/chalet_management_tile.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

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

    final Color background = isDark
        ? ColorManager.profileBackgroundDark
        : ColorManager.profileBackgroundLight;
    final Color surface = isDark
        ? ColorManager.profileSurfaceDark
        : ColorManager.profileSurfaceLight;
    final Color surfaceAlt = isDark
        ? ColorManager.profileSurfaceAltDark
        : ColorManager.profileSurfaceAltLight;
    final Color accent = ColorManager.profileAccent;
    final Color textPrimary = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: surface,
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
                                accent.withOpacity(0.6),
                                accent.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: surfaceAlt,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: accent,
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
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: accent.withOpacity(0.3)),
                          ),
                          child: Text(
                            _getRoleText(user.role),
                            style: TextStyle(
                              fontSize: 12,
                              color: accent,
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
                icon: Icon(Icons.edit, color: textPrimary),
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
                          value: _calculateDays(user.createdAt),
                          label: 'أيام معنا',
                          color: accent,
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
                      color: surfaceAlt,
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
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'معلومات الحساب',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ModernProfileItem(
                          icon: Icons.email_outlined,
                          label: 'البريد الإلكتروني',
                          value: user.email,
                          iconColor: accent,
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
                          value: _formatDate(user.createdAt),
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
                        color: surfaceAlt,
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
                                    color: accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.home_outlined,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'إدارة الشاليهات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
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
                      color: surfaceAlt,
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
                                  color: textPrimary,
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
                                  ? 'الوضع النهاري'
                                  : 'الوضع الداكن',
                              subtitle: isDarkMode
                                  ? 'تفعيل المظهر النهاري'
                                  : 'تفعيل المظهر الداكن',
                              color: accent,
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

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 'مستخدم';
      case 'owner':
        return 'صاحب شاليه';
      case 'admin':
        return 'مدير';
      default:
        return 'مستخدم';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateDays(DateTime createdAt) {
    final days = DateTime.now().difference(createdAt).inDays;
    return days.toString();
  }
}

// Custom Pattern Painter for background
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
