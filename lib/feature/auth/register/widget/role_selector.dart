import 'package:flutter/material.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String>? onChanged;

  const RoleSelector({super.key, required this.selectedRole, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h, // ⬅️ ارتفاع أنسب زي TextFieldش
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20.sp,
          color: Color(0xFF64748B),
        ),
        decoration: InputDecoration(
          labelText: "I am a...",
          labelStyle: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFF64748B),
          ),
          prefixIcon: Icon(
            Icons.badge_outlined,
            color: const Color(0xFF0EA5E9),
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.2.h,
          ),
        ),
        items: [
          // --- User ---
          DropdownMenuItem(
            value: "user",
            child: Row(
              children: [
                _iconBox(Icons.person_rounded, const Color(0xFF0EA5E9)),
                SizedBox(width: 5.w),
                Text(
                  "User",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // --- Owner ---
          DropdownMenuItem(
            value: "owner",
            child: Row(
              children: [
                _iconBox(Icons.home_work_rounded, const Color(0xFF059669)),
                SizedBox(width: 2.w),
                Text(
                  "Property Owner",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) onChanged?.call(value);
        },
      ),
    );
  }

  /// 🔹 صندوق أيقونة صغير وموحد الشكل
  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
