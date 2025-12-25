import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';

class MobileDrawerWidget extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabTitles;
  final List<IconData> tabIcons;
  final ValueChanged<int> onItemSelected;

  const MobileDrawerWidget({
    super.key,
    required this.selectedIndex,
    required this.tabTitles,
    required this.tabIcons,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkA = Color(0xFF06102A);
    const Color darkB = Color(0xFF0F2546);
    const Color accent = Color(0xFF6C5CE7);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark =
            themeState.themeMode == ThemeMode.dark ||
            (themeState.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white70 : Colors.black54;

        return Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [darkA, darkB],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF0F2F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.home, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rebtal',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final bool selected = selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: () {
                              onItemSelected(index);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? accent.withOpacity(0.18)
                                    : (isDark
                                          ? Colors.white.withOpacity(0.02)
                                          : Colors.black.withOpacity(0.03)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? accent
                                          : (isDark
                                                ? Colors.white.withOpacity(0.06)
                                                : Colors.white),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      tabIcons[index],
                                      color: selected
                                          ? Colors.white
                                          : (isDark
                                                ? accent
                                                : Colors.grey[600]),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    tabTitles[index],
                                    style: TextStyle(
                                      color: selected
                                          ? (isDark
                                                ? Colors.white
                                                : accent) // Highlight text color when selected
                                          : subTextColor,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemCount: tabTitles.length,
                    ),
                  ),
                  Divider(
                    color: isDark ? Colors.white24 : Colors.black12,
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: textColor),
                    ),
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final authCubit = context.read<AuthCubit>();

                      // Close the drawer immediately
                      navigator.pop();

                      // Perform logout
                      await authCubit.logout();

                      // Navigate to login screen
                      navigator.pushNamedAndRemoveUntil(
                        Routes.loginScreen,
                        (route) => false,
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: subTextColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'v1.0.0',
                            style: TextStyle(color: subTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
