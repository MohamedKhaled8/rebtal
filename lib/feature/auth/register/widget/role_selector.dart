import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String>? onChanged;

  const RoleSelector({super.key, required this.selectedRole, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('auth_i_am'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark
                ? ColorsManager.white
                : ColorsManager.chaletTextPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                icon: Icons.person_rounded,
                label: context.tr('auth_role_user'),
                value: 'user',
                isSelected: selectedRole == 'user',
                color: ColorsManager.skyBlue0EA5E9,
                onTap: () => onChanged?.call('user'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleCard(
                icon: Icons.home_work_rounded,
                label: context.tr('auth_role_owner'),
                value: 'owner',
                isSelected: selectedRole == 'owner',
                color: ColorsManager.chaletActionDarkBlue,
                onTap: () => onChanged?.call('owner'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(isDark ? 0.15 : 0.1)
              : (isDark
                    ? ColorsManager.darkSurface1E1E1E
                    : ColorsManager.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                      ? ColorsManager.white.withOpacity(0.1)
                      : ColorsManager.grey300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? color
                  : (isDark ? ColorsManager.white70 : ColorsManager.grey600),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? color
                    : (isDark ? ColorsManager.white70 : ColorsManager.grey600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
