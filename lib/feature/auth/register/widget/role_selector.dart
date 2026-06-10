import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String>? onChanged;
  final String? selectedOwnerType;
  final ValueChanged<String>? onOwnerTypeChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    this.onChanged,
    this.selectedOwnerType,
    this.onOwnerTypeChanged,
  });

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
        // Owner type sub-selection — animated, only visible when owner is selected
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: selectedRole == 'owner'
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _OwnerTypeSelector(
                    isDark: isDark,
                    selectedOwnerType: selectedOwnerType,
                    onChanged: onOwnerTypeChanged,
                    directLabel: context.tr('auth_owner_type_direct'),
                    brokerLabel: context.tr('auth_owner_type_broker'),
                    sectionLabel: context.tr('auth_owner_type_label'),
                    hasError: selectedOwnerType == null,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Owner type sub-selector ────────────────────────────────────────────────

class _OwnerTypeSelector extends StatelessWidget {
  const _OwnerTypeSelector({
    required this.isDark,
    required this.selectedOwnerType,
    required this.onChanged,
    required this.directLabel,
    required this.brokerLabel,
    required this.sectionLabel,
    required this.hasError,
  });

  final bool isDark;
  final String? selectedOwnerType;
  final ValueChanged<String>? onChanged;
  final String directLabel;
  final String brokerLabel;
  final String sectionLabel;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? ColorsManager.skyBlue38BDF8 : ColorsManager.blue2563EB;
    final borderColor = hasError
        ? Colors.orange.withOpacity(0.6)
        : (isDark ? Colors.white.withOpacity(0.1) : ColorsManager.greyE5E7EB);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.blue2563EB.withOpacity(0.06)
            : ColorsManager.blue2563EB.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError ? Colors.orange.withOpacity(0.5) : borderColor,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 15,
                color: activeColor,
              ),
              const SizedBox(width: 6),
              Text(
                sectionLabel,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '*',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _OwnerTypeChip(
                  icon: Icons.home_rounded,
                  label: directLabel,
                  value: 'direct_owner',
                  isSelected: selectedOwnerType == 'direct_owner',
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () => onChanged?.call('direct_owner'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OwnerTypeChip(
                  icon: Icons.handshake_rounded,
                  label: brokerLabel,
                  value: 'broker',
                  isSelected: selectedOwnerType == 'broker',
                  activeColor: activeColor,
                  isDark: isDark,
                  onTap: () => onChanged?.call('broker'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OwnerTypeChip extends StatelessWidget {
  const _OwnerTypeChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.activeColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(isDark ? 0.15 : 0.08)
              : (isDark ? ColorsManager.darkSurface1E1E1E : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.white.withOpacity(0.1) : ColorsManager.greyE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.white54 : ColorsManager.grey6B7280),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : activeColor)
                      : (isDark ? Colors.white60 : ColorsManager.grey6B7280),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle_rounded, size: 14, color: activeColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Main role card (unchanged design) ──────────────────────────────────────

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
