import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';

class WanderlyField extends StatelessWidget {
  const WanderlyField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final labelColor =
        isDark ? Colors.white70 : ColorsManager.grey6B7280;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.12) : ColorsManager.greyE5E7EB;
    final fillColor =
        isDark ? ColorsManager.darkBackground121212 : Colors.white;
    final textColor = isDark ? Colors.white : ColorsManager.grey1F2937;
    final hintColor =
        isDark ? Colors.white54 : ColorsManager.grey9CA3AF;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
            color: fillColor,
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hintColor,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (suffix != null) ...[suffix!, const SizedBox(width: 6)],
            ],
          ),
        ),
      ],
    );
  }
}

class WanderlyPrimaryButton extends StatelessWidget {
  const WanderlyPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.primaryColor,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: ColorsManager.grey300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
