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

  /// عرض SnackBar احترافي مع عنوان وزر إجراء
  static void showAction({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
    IconData icon = Icons.info_outline_rounded,
    Color? backgroundColor,
  }) {
    messengerKey.currentState?.removeCurrentSnackBar();

    final bg = backgroundColor ?? const Color(0xFF1E293B);

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        elevation: 12,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
        duration: const Duration(seconds: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        messengerKey.currentState?.hideCurrentSnackBar();
                        onAction();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
