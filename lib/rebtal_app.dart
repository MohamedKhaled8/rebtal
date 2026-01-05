import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:screen_go/screen_go.dart';
import 'package:rebtal/core/utils/theme/app_theme.dart';

import 'package:flutter/foundation.dart';

class RebtalApp extends StatelessWidget {
  final AppRouter appRouter;

  const RebtalApp({super.key, required this.appRouter});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ✅ SINGLE BlocProvider - provides AppCubit which coordinates all app state
    return ScreenGo(
      materialApp: true,
      builder: (context, deviceInfo) {
        // ✅ Listen to AppCubit for theme changes
        return BlocBuilder<AppCubit, AppState>(
          builder: (context, appState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(
                primaryColor: appState.primaryColor,
              ),
              darkTheme: AppTheme.getDarkTheme(
                primaryColor: appState.primaryColor,
              ),
              themeMode: appState.themeMode,
              // On web, go directly to login to avoid splash auth timing issues
              initialRoute: kIsWeb ? Routes.loginScreen : Routes.splashScreen,
              onGenerateRoute: appRouter.generateRoute,
            );
          },
        );
      },
    );
  }
}
