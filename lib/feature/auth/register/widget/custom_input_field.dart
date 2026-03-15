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
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool _hasText = false;
  String? _errorText;

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
    if (_errorText != null) {
      setState(() => _errorText = null);
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
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? ColorsManager.darkSurface1E1E1E : ColorsManager.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? ColorsManager.red
                  : isFocused
                      ? (isDark
                          ? ColorsManager.bookingsAccentPrimary
                          : ColorsManager.blue2563EB)
                      : (isDark
                          ? ColorsManager.white.withOpacity(0.1)
                          : ColorsManager.grey300),
              width: (isFocused || hasError) ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                widget.icon,
                size: 20,
                color: hasError
                    ? ColorsManager.red
                    : isFocused
                        ? (isDark
                            ? ColorsManager.bookingsAccentPrimary
                            : ColorsManager.blue2563EB)
                        : (isDark ? ColorsManager.white70 : ColorsManager.grey700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    setState(() => _errorText = error);
                    return error;
                  },
                  textInputAction:
                      widget.keyboardType == TextInputType.emailAddress ||
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
                    color: isDark
                        ? ColorsManager.white
                        : ColorsManager.chaletTextPrimaryLight,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.label,
                    hintStyle: TextStyle(
                      color: isDark
                          ? ColorsManager.white.withOpacity(0.4)
                          : ColorsManager.grey400,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }
}
