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
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                icon: Icons.person_rounded,
                label: context.tr('auth_role_user'),
                value: 'user',
                isSelected: selectedRole == 'user',
                color: ColorsManager.blue2563EB,
                onTap: () => onChanged?.call('user'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleCard(
                icon: Icons.home_work_rounded,
                label: context.tr('auth_role_owner'),
                value: 'owner',
                isSelected: selectedRole == 'owner',
                color: ColorsManager.blue2563EB,
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
    final activeColor = isDark ? ColorsManager.skyBlue38BDF8 : ColorsManager.blue2563EB;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(isDark ? 0.08 : 0.05)
              : (isDark ? ColorsManager.darkSurface1E1E1E : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.white.withOpacity(0.12) : ColorsManager.greyE5E7EB),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withOpacity(isDark ? 0.2 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? activeColor.withOpacity(0.12)
                        : (isDark ? Colors.white.withOpacity(0.05) : ColorsManager.greyF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected
                        ? activeColor
                        : (isDark ? Colors.white54 : ColorsManager.grey6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.white : activeColor)
                        : (isDark ? Colors.white60 : ColorsManager.grey6B7280),
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -30,
                right: -22,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
