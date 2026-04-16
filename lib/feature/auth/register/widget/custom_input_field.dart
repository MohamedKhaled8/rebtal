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
  final AutovalidateMode autovalidateMode;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
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

    final baseColor = isDark ? ColorsManager.darkSurface1E1E1E : Colors.white;
    final accentColor = isDark ? ColorsManager.skyBlue38BDF8 : ColorsManager.blue2563EB;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 60,
          decoration: BoxDecoration(
            color: isFocused 
                ? (isDark ? Colors.white.withOpacity(0.03) : Colors.white)
                : baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? ColorsManager.red
                  : isFocused
                      ? accentColor
                      : (isDark
                          ? Colors.white.withOpacity(0.12)
                          : ColorsManager.greyE5E7EB),
              width: isFocused ? 1.8 : 1.2,
            ),
            boxShadow: [
              if (isFocused && !hasError)
                BoxShadow(
                  color: accentColor.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              if (hasError)
                BoxShadow(
                  color: ColorsManager.red.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFocused 
                      ? accentColor.withOpacity(0.1) 
                      : (isDark ? Colors.white.withOpacity(0.05) : ColorsManager.greyF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: hasError
                      ? ColorsManager.red
                      : isFocused
                          ? accentColor
                          : (isDark ? Colors.white54 : ColorsManager.grey6B7280),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  autovalidateMode: widget.autovalidateMode,
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    if (error != _errorText) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _errorText = error);
                      });
                    }
                    return error;
                  },
                  textInputAction: widget.keyboardType == TextInputType.visiblePassword
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onFieldSubmitted: (_) {
                    if (widget.keyboardType == TextInputType.visiblePassword) {
                      FocusScope.of(context).unfocus();
                    } else {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : ColorsManager.grey1F2937,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.label,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : ColorsManager.grey400,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    isDense: true,
                  ),
                ),
              ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
              const SizedBox(width: 12),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: ColorsManager.red, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      color: ColorsManager.red,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
