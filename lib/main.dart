import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // ✅ Import App Check
import 'package:firebase_storage/firebase_storage.dart'; // ✅ Import Storage
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/firebase_options.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/localization/static_translation.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/rebtal_app.dart';
import 'package:rebtal/core/utils/services/onesignal_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional file — OneSignal has code fallback)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('⚠️ .env not found or empty — using OneSignal defaults in code.');
  }

  // Cairo / Google Fonts: keep runtime fetch; first paint may still fetch glyphs.
  GoogleFonts.config.allowRuntimeFetching = true;

  if (kIsWeb) {
    // للويب لازم تبعت الـ options
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else {
    // للموبايل بيقرأ من google-services.json / plist
    await Firebase.initializeApp();
  }

  // ✅ 1. Check Storage Configuration
  try {
    if (kDebugMode) {
      debugPrint('\n📦 ========================================');
      debugPrint('📦 Storage Bucket: ${FirebaseStorage.instance.bucket}');
      debugPrint('📦 ========================================\n');
    }
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ Failed to get storage bucket: $e');
  }

  // ✅ 2. Activate App Check
  // We wrap this in a non-awaited future to prevent it from blocking runApp if it stalls in release mode
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
          if (kDebugMode) debugPrint('✅ Firebase App Check Activated');
        })
        .catchError((e) {
          if (kDebugMode) debugPrint('⚠️ Firebase App Check Failed: $e');
        }),
  );

  setupGetIt();
  await getIt<CacheHelper>().init();
  await StaticTranslation.load();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Print Token for testing
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      debugPrint('\n==================================================');
      debugPrint('🔥 FCM TOKEN FOR TESTING:');
      debugPrint(token);
      debugPrint('==================================================\n');
    }
  } catch (e) {
    if (kDebugMode) debugPrint('Error getting token: $e');
  }

  // Initialize OneSignal
  await OneSignalService().initialize();

  runApp(
    BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>(),
      child: RebtalApp(appRouter: AppRouter()),
    ),
  );
}
