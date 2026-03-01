import 'package:flutter/material.dart';

class SnackBarHelper {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// عرض SnackBar بنجاح (أخضر)
  static void showSuccess(
    BuildContext? context,
    String message, {
    IconData? icon,
  }) {
    _showSnackBar(
      message: message,
      icon: icon ?? Icons.check_circle,
      backgroundColor: Colors.green.shade700,
    );
  }

  /// عرض SnackBar بخطأ (أحمر)
  static void showError(
    BuildContext? context,
    String message, {
    IconData? icon,
  }) {
    _showSnackBar(
      message: message,
      icon: icon ?? Icons.error_outline,
      backgroundColor: Colors.red.shade700,
    );
  }

  /// عرض SnackBar بتحذير (برتقالي)
  static void showWarning(
    BuildContext? context,
    String message, {
    IconData? icon,
  }) {
    _showSnackBar(
      message: message,
      icon: icon ?? Icons.warning_amber_rounded,
      backgroundColor: Colors.orange.shade600,
    );
  }

  /// عرض SnackBar بمعلومات (أزرق)
  static void showInfo(
    BuildContext? context,
    String message, {
    IconData? icon,
  }) {
    _showSnackBar(
      message: message,
      icon: icon ?? Icons.info_outline,
      backgroundColor: Colors.blue.shade700,
    );
  }

  static void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    // Dismiss existing snackbars to avoid queueing issues that lead to "off screen" errors
    messengerKey.currentState?.removeCurrentSnackBar();

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
