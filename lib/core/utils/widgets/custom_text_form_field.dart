import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType inputType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? labelColor;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.labelColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: labelColor ?? Colors.blueGrey,
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        filled: true,
        fillColor: fillColor ?? Colors.blueGrey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(prefixIcon, color: labelColor ?? Colors.blueGrey),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
