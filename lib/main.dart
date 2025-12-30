import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/utils/helper/firebase_options.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/rebtal_app.dart';
import 'package:rebtal/core/utils/services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    // للويب لازم تبعت الـ options
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else {
    // للموبايل بيقرأ من google-services.json / plist
    await Firebase.initializeApp();
  }

  // );

  setupGetIt();
  await getIt<CacheHelper>().init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Print Token for testing
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print('\n==================================================');
    print('🔥 FCM TOKEN FOR TESTING:');
    print(token);
    print('==================================================\n');
  } catch (e) {
    print('Error getting token: $e');
  }

  // Initialize OneSignal
  await OneSignalService().initialize();

  // If onboarding is needed later, read from cache here
  // final bool onboardingCompleted =
  //     getIt<CacheHelper>().getData(key: 'onboardingCompleted') ?? false;

  runApp(RebtalApp(appRouter: AppRouter()));
}
