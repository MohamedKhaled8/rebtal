import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

/// Unsigned Cloudinary image upload (URLs only stored in Firestore).
///
/// Uses the official minimal unsigned flow: `upload_preset` + `file` only.
/// Sending `api_key` / custom `public_id` often breaks presets that disallow
/// unsigned overrides or extra fields on mobile.
class CloudinaryUploadHelper {
  CloudinaryUploadHelper._();

  static const String _cloudName = 'dwobtaa6a';
  static const String _uploadPreset = 'Mmkkkkk';

  static String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final i = normalized.lastIndexOf('/');
    return i >= 0 && i < normalized.length - 1
        ? normalized.substring(i + 1)
        : normalized;
  }

  static String _filenameForUpload(String path, String mimeType) {
    var name = _basename(path);
    if (name.isEmpty || name == '.' || name == '..') {
      name = mimeType.contains('png') ? 'upload.png' : 'upload.jpg';
    }
    return name;
  }

  /// Uploads [imageFile] and returns `secure_url` (or `url`).
  static Future<String> uploadImage(
    File imageFile, {
    int maxRetries = 3,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final bytes = await imageFile.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('ملف الصورة فارغ أو لا يمكن قراءته من الجهاز.');
        }

        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

        final request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = _uploadPreset
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: _filenameForUpload(imageFile.path, mimeType),
            ),
          );

        final streamed = await request.send().timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw TimeoutException('upload_timeout'),
        );

        final body = await streamed.stream.bytesToString();

        if (streamed.statusCode == 200) {
          final decoded = jsonDecode(body);
          if (decoded is! Map) {
            throw Exception('رد Cloudinary غير متوقع.');
          }
          final jsonResp = Map<String, dynamic>.from(decoded);
          final secure = jsonResp['secure_url'];
          final plain = jsonResp['url'];
          String? url;
          if (secure is String && secure.trim().isNotEmpty) {
            url = secure.trim();
          } else if (plain is String && plain.trim().isNotEmpty) {
            url = plain.trim();
          } else if (secure != null && '$secure'.trim().isNotEmpty) {
            url = '$secure'.trim();
          } else if (plain != null && '$plain'.trim().isNotEmpty) {
            url = '$plain'.trim();
          }
          if (url == null || url.isEmpty) {
            throw Exception('رد Cloudinary بدون رابط صورة.');
          }
          if (url.startsWith('//')) {
            url = 'https:$url';
          }
          return url;
        }

        String detail = body;
        try {
          final j = jsonDecode(body);
          if (j is Map) {
            final err = j['error'];
            if (err is Map && err['message'] != null) {
              detail = err['message'].toString();
            }
          }
        } catch (_) {}

        throw Exception(
          'Cloudinary رفض الرفع (${streamed.statusCode}): $detail',
        );
      } on SocketException catch (_) {
        if (attempt == maxRetries) {
          throw Exception(
            'فشل الاتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى.',
          );
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      } on TimeoutException catch (_) {
        if (attempt == maxRetries) {
          throw Exception(
            'انتهت مهلة رفع الصورة. تحقق من الشبكة وحاول مرة أخرى.',
          );
        }
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        if (attempt == maxRetries) rethrow;
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception('فشل الرفع بعد عدة محاولات.');
  }
}
