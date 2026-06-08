import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rebtal/core/utils/helper/firebase_options.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/localization/static_translation.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/utils/services/onesignal_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _loadEnv();
    _configureFonts();
    await _initFirebase();
    await _activateAppCheck();
    await _initDependencies();
    await _initNotifications();
  }

  static Future<void> _loadEnv() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Ignore if .env is missing
    }
  }

  static void _configureFonts() {
    GoogleFonts.config.allowRuntimeFetching = true;
  }

  static Future<void> _initFirebase() async {
    if (kIsWeb) {
      await Firebase.initializeApp(options: firebaseWebOptions);
    } else {
      await Firebase.initializeApp();
    }
  }

  static Future<void> _activateAppCheck() async {
    unawaited(
      FirebaseAppCheck.instance
          .activate(
            androidProvider: kDebugMode
                ? AndroidProvider.debug
                : AndroidProvider.playIntegrity,
            appleProvider: kDebugMode
                ? AppleProvider.debug
                : AppleProvider.deviceCheck,
          )
          .then((_) {
        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      }).catchError((e) {
        // Handle error silently
      }),
    );
  }

  static Future<void> _initDependencies() async {
    setupGetIt();
    await getIt<CacheHelper>().init();
    await StaticTranslation.load();
  }

  static Future<void> _initNotifications() async {
    final notificationService = NotificationService();
    await notificationService.initialize();

    try {
      await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // Ignore errors fetching FCM token
    }

    await OneSignalService().initialize();
  }
}
