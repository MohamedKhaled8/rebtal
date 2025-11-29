import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UriLauncherService {
  UriLauncherService._();

  static Future<void> launchWhatsAppContact({
    required BuildContext context,
    required String phone,
    String message = 'السلام عليكم',
  }) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phone);
      if (cleanPhone.isEmpty) {
        _showSnackBar(context, 'رقم الهاتف غير صالح');
        return;
      }

      final waMeUrl =
          'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';

      final uri = Uri.parse(waMeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode:
              LaunchMode.externalApplication, // ✅ يفتح الواتس مباشرة
        );
      } else {
        _showSnackBar(context, 'لا يمكن فتح WhatsApp');
      }
    } catch (e) {
      _showSnackBar(context, 'خطأ: $e');
    }
  }


  static String _cleanPhoneNumber(String phone) {
    if (phone.isEmpty) return '';

    // إزالة كل شيء إلا الأرقام وعلامة +
    String clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // معالجة الأرقام المصرية
    if (clean.startsWith('0')) {
      clean = clean.replaceFirst('0', '+20');
    } else if (!clean.startsWith('+')) {
      clean = '+$clean';
    }

    // إزالة علامة + للروابط (الروابط لا تحتاج +)
    return clean.replaceFirst('+', '');
  }

  static Future<void> launchPhoneCall(
    BuildContext context,
    String phone,
  ) async {
    try {
      final cleanPhone = _cleanPhoneNumber(phone);
      if (cleanPhone.isEmpty) {
        _showSnackBar(context, 'رقم الهاتف غير صالح');
        return;
      }

      final uri = Uri.parse('tel:+$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar(context, 'لا يمكن إجراء المكالمة');
      }
    } catch (e) {
      _showSnackBar(context, 'خطأ في الاتصال: $e');
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}
