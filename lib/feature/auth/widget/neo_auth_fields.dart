import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class NeoAuthField extends StatelessWidget {
  const NeoAuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: ColorsManager.grey6B7280),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ColorsManager.grey1F2937,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: ColorsManager.grey9CA3AF,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (suffix != null) ...[const SizedBox(width: 4), suffix!],
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class NeoPillButton extends StatelessWidget {
  const NeoPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.accent,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color accent;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        accent.withOpacity(0.98),
                        ColorsManager.cyan06B6D4.withOpacity(0.92),
                      ],
                    )
                  : null,
              color: enabled ? null : Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: enabled
                    ? accent.withOpacity(0.28)
                    : Colors.white.withOpacity(0.12),
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.25),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsManager.white,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: enabled
                            ? ColorsManager.white
                            : ColorsManager.white.withOpacity(0.55),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
