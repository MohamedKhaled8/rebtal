import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    widget.controller.addListener(_handleTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
  }

  void _handleTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final isDark = DynamicThemeManager.isDarkMode(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? ColorManager.darkSurface1E1E1E : ColorManager.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused
              ? (isDark ? ColorManager.bookingsAccentPrimary : ColorManager.blue2563EB)
              : (isDark
                  ? ColorManager.white.withOpacity(0.1)
                  : ColorManager.grey300),
          width: isFocused ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            widget.icon,
            size: 20,
            color: isFocused
                ? (isDark ? ColorManager.bookingsAccentPrimary : ColorManager.blue2563EB)
                : (isDark ? ColorManager.white70 : ColorManager.grey700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.keyboardType ==
                          TextInputType.emailAddress ||
                      widget.keyboardType == TextInputType.phone ||
                      widget.keyboardType == TextInputType.name
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (_) {
                if (widget.keyboardType != null &&
                    widget.keyboardType != TextInputType.visiblePassword) {
                  FocusScope.of(context).nextFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              style: TextStyle(
                fontSize: 15,
                color: isDark ? ColorManager.white : ColorManager.chaletTextPrimaryLight,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.label,
                hintStyle: TextStyle(
                  color: isDark ? ColorManager.white.withOpacity(0.4) : ColorManager.grey400,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (widget.suffixIcon != null) widget.suffixIcon!,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
