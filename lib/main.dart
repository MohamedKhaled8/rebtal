import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/utils/helper/firebase_options.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/rebtal_app.dart';

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

  // If onboarding is needed later, read from cache here
  // final bool onboardingCompleted =
  //     getIt<CacheHelper>().getData(key: 'onboardingCompleted') ?? false;

  runApp(RebtalApp(appRouter: AppRouter()));
}
