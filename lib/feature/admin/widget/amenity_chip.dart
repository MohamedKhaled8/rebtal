
// AmenityChip
import 'package:flutter/material.dart';

class AmenityChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final Color color;

  const AmenityChip({
    super.key,
    required this.label,
    required this.enabled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: enabled ? color.withOpacity(0.2) : Colors.grey[200],
      labelStyle: TextStyle(
        color: enabled ? color : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      avatar: Icon(
        enabled ? Icons.check : Icons.close,
        size: 16,
        color: enabled ? color : Colors.grey[600],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: enabled ? color.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
    );
  }
}