import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
  } catch (_) {}

  // Cairo / Google Fonts: keep runtime fetch; first paint may still fetch glyphs.
  GoogleFonts.config.allowRuntimeFetching = true;

  if (kIsWeb) {
    // للويب لازم تبعت الـ options
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else {
    // للموبايل بيقرأ من google-services.json / plist
    await Firebase.initializeApp();
  }

  // Check Storage Configuration
  try {
    if (kDebugMode) {}
  } catch (e) {}

  // Activate App Check
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
        })
        .catchError((e) {}),
  );

  setupGetIt();
  await getIt<CacheHelper>().init();
  await StaticTranslation.load();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Get FCM Token
  try {
    await FirebaseMessaging.instance.getToken();
  // ignore: empty_catches
  } catch (e) {}

  // Initialize OneSignal
  await OneSignalService().initialize();

  runApp(
    BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>(),
      child: RebtalApp(appRouter: AppRouter()),
    ),
  );
}
