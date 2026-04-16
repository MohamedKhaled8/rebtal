import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/models/notification_model.dart';
import 'package:rebtal/core/models/notification_type.dart';
import 'package:intl/intl.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.onMarkAsRead,
  });

  /// ترجم العنوان باستخدام المفتاح والمتغيرات
  String _getTranslatedTitle(BuildContext context) {
    // لو فيه مفتاح ترجمة، استخدمه
    if (notification.titleKey.isNotEmpty) {
      String translated = context.tr(notification.titleKey);
      final merged = <String, dynamic>{
        if (notification.data != null) ...notification.data!,
        if (notification.titleParams != null) ...notification.titleParams!,
      };
      merged.forEach((key, value) {
        translated = translated.replaceAll('{$key}', value.toString());
      });
      return translated;
    }
    // ترجمة ذكية للنصوص القديمة المخزنة
    return _translateOldTitle(context);
  }

  /// ترجم النصوص القديمة المخزنة مباشرة في Firestore
  String _translateOldTitle(BuildContext context) {
    final title = notification.title;

    // محاولة مطابقة النص العربي مع مفاتيح الترجمة
    if (title.contains('موافقة') || title.contains('🎉')) {
      return context.tr('notifications_booking_approved_title');
    } else if (title.contains('رفض') || title.contains('❌')) {
      return context.tr('notifications_booking_rejected_title');
    } else if (title.contains('إلغاء') || title.contains('⚠️')) {
      return context.tr('notifications_booking_cancelled_title');
    } else if (title.contains('طلب') && title.contains('جديد')) {
      return context.tr('notifications_booking_request_title');
    } else if (title.contains('دفع') || title.contains('✅')) {
      return context.tr('notifications_payment_confirmed_title');
    } else if (title.contains('شاليه') && title.contains('قبول')) {
      return context.tr('notifications_chalet_approved_title');
    } else if (title.contains('شاليه') && title.contains('رفض')) {
      return context.tr('notifications_chalet_rejected_title');
    }

    // لو مفيش تطابق، رجع النص الأصلي
    return title;
  }

  /// ترجم المحتوى باستخدام المفتاح والمتغيرات
  String _getTranslatedBody(BuildContext context) {
    // لو فيه مفتاح ترجمة، استخدمه
    if (notification.bodyKey.isNotEmpty) {
      String translated = context.tr(notification.bodyKey);
      final merged = <String, dynamic>{
        if (notification.data != null) ...notification.data!,
        if (notification.bodyParams != null) ...notification.bodyParams!,
      };
      merged.forEach((key, value) {
        translated = translated.replaceAll('{$key}', value.toString());
      });
      return translated;
    }
    // ترجمة ذكية للنصوص القديمة المخزنة
    return _translateOldBody(context);
  }

  /// ترجم نصوص body القديمة
  String _translateOldBody(BuildContext context) {
    final body = notification.body;

    // استخراج اسم الشاليه من النص العربي
    final chaletName = _extractChaletName(body);

    if (body.contains('وافق المالك') || body.contains('يمكنك الآن')) {
      String translated = context.tr('notifications_booking_approved_body');
      if (chaletName.isNotEmpty) {
        translated = translated.replaceAll('{chaletName}', chaletName);
      }
      return translated;
    } else if (body.contains('رفض') || body.contains('عذراً')) {
      String translated = context.tr('notifications_booking_rejected_body');
      if (chaletName.isNotEmpty) {
        translated = translated.replaceAll('{chaletName}', chaletName);
      }
      return translated;
    } else if (body.contains('إلغاء') ||
        body.contains('قام') && body.contains('بإلغاء')) {
      String translated = context.tr('notifications_booking_cancelled_body');
      // استخراج اسم المستخدم
      final userName = _extractUserName(body);
      if (userName.isNotEmpty) {
        translated = translated.replaceAll('{userName}', userName);
      }
      if (chaletName.isNotEmpty) {
        translated = translated.replaceAll('{chaletName}', chaletName);
      }
      return translated;
    } else if (body.contains('طلب حجز جديد') ||
        body.contains('يرجى المراجعة') ||
        body.contains('new booking request') ||
        body.toLowerCase().contains('booking request for')) {
      final parsed = _parseBookingRequestLegacyBody(body);
      String translated = context.tr('notifications_booking_request_body');
      final ch = parsed.$1.isNotEmpty ? parsed.$1 : chaletName;
      final un = parsed.$2.isNotEmpty
          ? parsed.$2
          : (notification.data?['userName']?.toString() ?? '');
      if (ch.isNotEmpty) {
        translated = translated.replaceAll('{chaletName}', ch);
      }
      if (un.isNotEmpty) {
        translated = translated.replaceAll('{userName}', un);
      }
      return translated;
    } else if (body.contains('تم تأكيد') || body.contains('الحجز مؤكد')) {
      String translated = context.tr('notifications_payment_confirmed_body');
      if (chaletName.isNotEmpty) {
        translated = translated.replaceAll('{chaletName}', chaletName);
      }
      return translated;
    }

    return body;
  }

  /// (chaletName, userName) من نص طلب الحجز القديم المخزن في Firestore
  (String, String) _parseBookingRequestLegacyBody(String text) {
    final ar = RegExp(
      r'لشاليه\s+(.+?)\s+من\s+([^.]+?)(?:\.\s*يرجى|\.\s*$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (ar != null) {
      return (
        ar.group(1)?.trim() ?? '',
        ar.group(2)?.trim() ?? '',
      );
    }
    final en = RegExp(
      r'(?:booking request|request)\s+for\s+(.+?)\s+from\s+([^.]+?)(?:\.|\s*Please)',
      caseSensitive: false,
    ).firstMatch(text);
    if (en != null) {
      return (
        en.group(1)?.trim() ?? '',
        en.group(2)?.trim() ?? '',
      );
    }
    return ('', '');
  }

  /// استخراج اسم الشاليه من النص العربي
  String _extractChaletName(String text) {
    // أحاول استخراج الاسم من بين علامات الاقتباس أو بعد "في"
    final regExp = RegExp(r'في\s+([^،.]+)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    // أو بعد اسم الشاليه مباشرة (توقف عند " من " إن وُجدت لتجنب ابتلاع اسم الضيف)
    final chaletExp = RegExp(r'شاليه\s+(.+?)(?:\s+من\s+|$)');
    final chaletMatch = chaletExp.firstMatch(text);
    if (chaletMatch != null) {
      return chaletMatch.group(1)?.trim() ?? '';
    }
    return '';
  }

  /// استخراج اسم المستخدم من النص العربي
  String _extractUserName(String text) {
    final regExp = RegExp(r'قام\s+([^\s]+)\s+بإلغاء');
    final match = regExp.firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    final iconData = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);

    // احصل على النصوص المترجمة
    final title = _getTranslatedTitle(context);
    final body = _getTranslatedBody(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ColorsManager.chaletActionRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: ColorsManager.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(
                  0xFF1A1F2E,
                ) // Dark blue-gray instead of almost black
              : ColorsManager.chaletCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? (isDark
                      ? ColorsManager.white.withOpacity(0.1)
                      : ColorsManager.black.withOpacity(0.05))
                : color.withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: ColorsManager.transparent,
          child: InkWell(
            onTap: () {
              if (!notification.isRead) {
                onMarkAsRead?.call();
              }
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: ColorsManager.white, size: 24),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title, // مترجم
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : ColorsManager.black,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          body, // مترجم
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : ColorsManager.grey700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: isDark
                                  ? ColorsManager.chaletTextSecondaryDark
                                  : ColorsManager.chaletTextSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(context, notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white60
                                    : ColorsManager.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingRequest:
        return Icons.calendar_today_rounded;
      case NotificationType.bookingApproved:
        return Icons.check_circle_rounded;
      case NotificationType.bookingRejected:
        return Icons.cancel_rounded;
      case NotificationType.paymentConfirmed:
        return Icons.payment_rounded;
      case NotificationType.chaletApproved:
        return Icons.home_rounded;
      case NotificationType.chaletRejected:
        return Icons.home_outlined;
      case NotificationType.chaletSubmission:
        return Icons.add_home_work_rounded;
      case NotificationType.transferTicket:
        return Icons.swap_horiz_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingRequest:
        return ColorsManager.chaletActionBlue;
      case NotificationType.bookingApproved:
        return ColorsManager.chaletActionGreen;
      case NotificationType.bookingRejected:
        return ColorsManager.chaletActionRed;
      case NotificationType.paymentConfirmed:
        return ColorsManager.chaletActionGreen;
      case NotificationType.chaletApproved:
        return ColorsManager.chaletActionGreen;
      case NotificationType.chaletRejected:
        return ColorsManager.chaletActionRed;
      case NotificationType.chaletSubmission:
        return ColorsManager.chaletActionBlue;
      case NotificationType.transferTicket:
        return ColorsManager.chaletActionBlue;
      case NotificationType.general:
        return ColorsManager.chaletGalleryBlue;
    }
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return context.tr('common_now');
    } else if (difference.inHours < 1) {
      return '${context.tr('notifications_since')} ${difference.inMinutes} ${context.tr('booking_minute')}';
    } else if (difference.inDays < 1) {
      return '${context.tr('notifications_since')} ${difference.inHours} ${context.tr('booking_hour')}';
    } else if (difference.inDays < 7) {
      return '${context.tr('notifications_since')} ${difference.inDays} ${context.tr('booking_day')}';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
