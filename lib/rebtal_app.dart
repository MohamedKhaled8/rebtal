import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/booking/logic/booking_cubit.dart';
import 'package:screen_go/screen_go.dart';
import 'package:rebtal/core/utils/theme/cubit/theme_cubit.dart';
import 'package:rebtal/core/utils/theme/app_theme.dart';

import 'package:flutter/foundation.dart';

class RebtalApp extends StatelessWidget {
  final AppRouter appRouter;

  const RebtalApp({super.key, required this.appRouter});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => BookingCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: ScreenGo(
        materialApp: true,

        builder: (context, deviceInfo) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.getLightTheme(primaryColor: state.primaryColor),
                darkTheme: AppTheme.getDarkTheme(
                  primaryColor: state.primaryColor,
                ),
                themeMode: state.themeMode,
                // On web, go directly to login to avoid splash auth timing issues
                initialRoute: kIsWeb ? Routes.loginScreen : Routes.splashScreen,
                onGenerateRoute: appRouter.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
