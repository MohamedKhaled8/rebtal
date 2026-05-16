import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';

/// Text field whose text stays in sync with [draftText] only when not focused —
/// avoids focus jumping to other inputs after routes/sheets rebuild the form.
class OwnerSyncedTextField extends StatefulWidget {
  const OwnerSyncedTextField({
    super.key,
    required this.fieldId,
    required this.draftText,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    required this.isDark,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final String fieldId;
  final String draftText;
  final String labelText;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<OwnerSyncedTextField> createState() => _OwnerSyncedTextFieldState();
}

class _OwnerSyncedTextFieldState extends State<OwnerSyncedTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draftText);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant OwnerSyncedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.draftText == oldWidget.draftText) return;
    if (_focusNode.hasFocus) return;
    _controller.value = TextEditingValue(
      text: widget.draftText,
      selection: TextSelection.collapsed(offset: widget.draftText.length),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      style: TextStyle(
        color: widget.isDark ? ColorsManager.white : ColorsManager.black,
        fontSize: 15.sp,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        labelStyle: TextStyle(
          color: widget.isDark ? ColorsManager.grey400 : ColorsManager.grey600,
          fontSize: 14.sp,
        ),
        hintStyle: TextStyle(
          color: widget.isDark ? ColorsManager.grey600 : ColorsManager.grey400,
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: widget.isDark ? ColorsManager.grey400 : ColorsManager.grey600,
          size: 22,
        ),
        filled: true,
        fillColor: widget.isDark
            ? ColorsManager.darkBlue2A2E4B.withOpacity(0.5)
            : ColorsManager.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: BorderSide(
            color: widget.isDark
                ? ColorsManager.grey800.withOpacity(0.3)
                : ColorsManager.grey300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.sp),
          borderSide: const BorderSide(
            color: ColorsManager.blue2563EB,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.sw,
          vertical: 16.sh,
        ),
      ),
    );
  }
}
