// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:mobile_device_identifier/mobile_device_identifier.dart';

// class DeviceIdHelper {
//   static Future<String> getDeviceId() async {
//     if (kIsWeb) {
//       // إذا كانت المنصة Web
//       return 'web_device';
//     } else if (Platform.isAndroid || Platform.isIOS) {
//       try {
//         // استدعاء مكتبة MobileDeviceIdentifier فقط على Android و iOS
//         return await MobileDeviceIdentifier().getDeviceId() ?? 'unknown_device';
//       } catch (e) {
//         return 'unknown_device';
//       }
//     } else {
//       // إذا كانت المنصة Windows، macOS، أو Linux
//       return 'unsupported_platform';
//     }
//   }
// }
