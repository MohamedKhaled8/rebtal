import 'package:rebtal/core/Router/app_router.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/theme/app_theme.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rebtal/core/utils/localization/app_localization.dart';
import 'package:rebtal/core/utils/widgets/force_update_gate.dart';

class RebtalApp extends StatelessWidget {
  final AppRouter appRouter;

  const RebtalApp({super.key, required this.appRouter});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // ✅ SINGLE BlocProvider - provides AppCubit which coordinates all app state
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.themeMode != current.themeMode ||
          previous.primaryColor != current.primaryColor ||
          previous.locale != current.locale,
      builder: (context, appState) {
        final isRTL = appState.locale.languageCode == 'ar';
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: ResponsiveMaster(
            // Global Configuration
            config: const ResponsiveMasterConfig(
              designWidth: 375, // Figma Design Width
              designHeight: 812, // Figma Design Height
              mobileBreakpoint: 600,
              tabletBreakpoint: 1100,
              enableCaching: true,
            ),
            builder: (BuildContext context, deviceInfo) {
              return MaterialApp(
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en'), Locale('ar')],
                locale: appState.locale,
                builder: (context, child) {
                  return Directionality(
                    textDirection: isRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: ForceUpdateGate(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
                scaffoldMessengerKey: SnackBarHelper.messengerKey,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.getLightTheme(
                  primaryColor: appState.primaryColor,
                ),
                darkTheme: AppTheme.getDarkTheme(
                  primaryColor: appState.primaryColor,
                ),
                themeMode: appState.themeMode,
                themeAnimationDuration: Duration.zero,
                themeAnimationCurve: Curves.linear,
                // Use splash for all platforms - it checks auth and navigates to home/login accordingly
                initialRoute: Routes.splashScreen,
                onGenerateRoute: appRouter.generateRoute,
              );
            },
          ),
        );
      },
    );
  }
}
