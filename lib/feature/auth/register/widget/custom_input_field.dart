import 'package:flutter/material.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

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
    final showFloatingLabel = isFocused || _hasText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isFocused ? const Color(0xFFF0F7FF) : const Color(0xFFFAFAFA),
        border: Border.all(
          color: isFocused ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          width: isFocused ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFloatingLabel)
            Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isFocused
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            children: [
              Icon(
                widget.icon,
                color: isFocused
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
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
                    fontSize: 14.sp,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: showFloatingLabel ? null : widget.label,
                    hintStyle: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    suffixIcon: widget.suffixIcon,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
