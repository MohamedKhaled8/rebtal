import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';

class DesktopSidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final List<String> tabTitles;
  final List<IconData> tabIcons;
  final ValueChanged<int> onItemSelected;

  const DesktopSidebarWidget({
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

        return Container(
          width: 260,
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [darkA, darkB],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF0F2F5)],
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.26 : 0.05),
                blurRadius: 8,
              ),
            ],
            border: isDark
                ? null
                : const Border(right: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      // logo box
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rebtal',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // menu
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemBuilder: (context, index) {
                      final bool selected = selectedIndex == index;
                      return InkWell(
                        onTap: () => onItemSelected(index),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? accent.withOpacity(0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? accent
                                      : (isDark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.grey.withOpacity(0.1)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  tabIcons[index],
                                  color: selected
                                      ? Colors.white
                                      : (isDark ? accent : Colors.grey[600]),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tabTitles[index],
                                  style: TextStyle(
                                    color: selected ? textColor : subTextColor,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (selected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white : accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: tabTitles.length,
                  ),
                ),

                // quick card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pie_chart, color: subTextColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Dashboard Overview',
                            style: TextStyle(
                              color: subTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark
                            ? Colors.white24
                            : Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          color: isDark ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Administrator',
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
