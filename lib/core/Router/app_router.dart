import "package:rebtal/core/Router/export_routes.dart";
import "package:rebtal/core/Router/routes.dart";
import "package:rebtal/core/utils/dependency/get_it.dart";
import "package:rebtal/feature/auth/login/ui/login_screen.dart";
import "package:rebtal/feature/auth/register/ui/resgister_screen.dart";
import "package:rebtal/feature/auth/welcome/ui/welcome_screen.dart";
import "package:rebtal/feature/admin/ui/dashboard.dart";
import "package:rebtal/feature/home/ui/home_screen.dart";
import "package:rebtal/feature/navigation/ui/bottom_navigation_screen.dart";
import "package:rebtal/feature/onboarding/logic/cubit/onboarding_cubit.dart";
import "package:rebtal/feature/onboarding/logic/cubit/terms_cubit.dart";
import "package:rebtal/feature/onboarding/ui/onboarding_screen.dart";
import "package:rebtal/feature/onboarding/ui/terms_screen.dart";
import "package:rebtal/feature/owner/logic/cubit/owner_cubit.dart";
import "package:rebtal/feature/owner/ui/owner_screen.dart";
import "package:rebtal/feature/splash/ui/splash_screen.dart";

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    // final argument = settings.arguments; // currently unused

    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.welcomeScreen:
        return _buildAnimatedRoute(
          const WelcomeScreen(),
          beginOffset: const Offset(0, 0.08),
        );
      case Routes.onBardingScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => OnboardingCubit(),
            child: OnboardingScreen(),
          ),
        );
      case Routes.termsScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => TermsCubit(getIt()),
            child: const TermsScreen(),
          ),
        );
      case Routes.registerScreen:
        return _buildAnimatedRoute(
          const RegisterScreen(),
          beginOffset: const Offset(0.1, 0),
        );
      case Routes.loginScreen:
        return _buildAnimatedRoute(
          const LoginScreen(),
          beginOffset: const Offset(-0.1, 0),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.dashboardScreen:
        return MaterialPageRoute(builder: (_) => AdminDashboard());
      case Routes.bottomNavigationBarScreen:
        return MaterialPageRoute(builder: (_) => BottomNavigationScreen());
      case Routes.ownerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => OwnerCubit(),
            child: OwnerChaletAddScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("No route defined"))),
        );
    }
  }

  PageRouteBuilder _buildAnimatedRoute(
    Widget child, {
    Offset beginOffset = const Offset(0.0, 0.1),
  }) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.1, 1, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
