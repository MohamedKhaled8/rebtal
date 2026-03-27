import "package:rebtal/core/Router/export_routes.dart";
import "package:rebtal/core/Router/routes.dart";
import "package:rebtal/core/utils/dependency/get_it.dart";
import "package:rebtal/feature/auth/domain/usecases/login_usecase.dart";
import "package:rebtal/feature/auth/domain/usecases/register_usecase.dart";
import "package:rebtal/feature/auth/domain/usecases/resend_email_verification_usecase.dart";
import "package:rebtal/feature/auth/domain/usecases/save_user_usecase.dart";
import "package:rebtal/feature/auth/login/ui/login_screen.dart";
import "package:rebtal/feature/auth/login/logic/login_cubit.dart";
import "package:rebtal/feature/auth/email_verification/ui/email_verification_screen.dart";
import "package:rebtal/feature/auth/email_verification/logic/email_verification_cubit.dart";
import "package:rebtal/feature/auth/register/ui/resgister_screen.dart";
import "package:rebtal/feature/auth/register/logic/register_cubit.dart";
import "package:rebtal/feature/welcome/ui/welcome_screen.dart";
import "package:rebtal/feature/admin/presentation/pages/dashboard.dart";
import "package:rebtal/feature/home/ui/home_screen.dart";
import "package:rebtal/feature/navigation/ui/bottom_navigation_screen.dart";
import "package:rebtal/feature/onboarding/logic/cubit/onboarding_cubit.dart";
import "package:rebtal/feature/onboarding/logic/cubit/terms_cubit.dart";
import "package:rebtal/feature/onboarding/ui/onboarding_screen.dart";
import "package:rebtal/feature/onboarding/ui/terms_screen.dart";
import "package:rebtal/feature/owner/ui/owner_chalet_Add_screen.dart";
import "package:rebtal/feature/notifications/ui/notifications_page.dart";
import "package:rebtal/feature/splash/ui/splash_screen.dart";

// Payment System Imports
import "package:rebtal/feature/booking/models/booking.dart";
import "package:rebtal/feature/payment/ui/new_payment_method_page.dart";
import "package:rebtal/feature/booking/ui/booking_confirmation_page.dart";
import "package:rebtal/feature/admin/presentation/pages/admin_payments_page.dart";
import "package:rebtal/feature/booking/ui/cancellation_policy_page.dart";
import "package:rebtal/feature/booking/ui/refund_request_page.dart";
import "package:rebtal/feature/booking/ui/rating_page.dart";
import "package:rebtal/feature/booking/ui/transaction_history_page.dart";
import "package:rebtal/core/utils/model/user_model.dart";

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
          BlocProvider(
            create: (context) => RegisterCubit(getIt<RegisterUseCase>()),
            child: const RegisterScreen(),
          ),
          beginOffset: const Offset(0.1, 0),
        );
      case Routes.loginScreen:
        return _buildAnimatedRoute(
          BlocProvider(
            create: (context) => LoginCubit(getIt<LoginUseCase>()),
            child: const LoginScreen(),
          ),
          beginOffset: const Offset(-0.1, 0),
        );
      case Routes.emailVerification:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => EmailVerificationCubit(
              userModel: user,
              resendUseCase: getIt<ResendEmailVerificationUseCase>(),
              saveUserUseCase: getIt<SaveUserUseCase>(),
            ),
            child: EmailVerificationScreen(email: user.email),
          ),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.dashboardScreen:
        return MaterialPageRoute(builder: (_) => AdminDashboard());
      case Routes.bottomNavigationBarScreen:
        return MaterialPageRoute(builder: (_) => BottomNavigationScreen());
      case Routes.ownerScreen:
        return MaterialPageRoute(builder: (_) => OwnerChaletAddScreen());
      case Routes.notificationsPage:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());

      // Payment System Routes - New Modern Design
      case Routes.paymentMethodSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => NewPaymentMethodPage(
            booking: args['booking'] as Booking,
            totalAmount: args['totalAmount'] as double,
          ),
        );

      case Routes.bookingConfirmationPage:
        final booking = settings.arguments as Booking?;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmationPage(booking: booking),
        );

      case Routes.adminPayments:
        return MaterialPageRoute(builder: (_) => const AdminPaymentsPage());

      case Routes.cancellationPolicy:
        return MaterialPageRoute(
          builder: (_) => const CancellationPolicyPage(),
        );

      case Routes.refundRequest:
        final booking = settings.arguments as Booking;
        return MaterialPageRoute(
          builder: (_) => RefundRequestPage(booking: booking),
        );

      case Routes.ratingPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RatingPage(
            booking: args['booking'] as Booking,
            isOwnerRating: args['isOwnerRating'] as bool? ?? false,
          ),
        );

      case Routes.transactionHistory:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TransactionHistoryPage(
            userId: args['userId'] as String,
            isOwner: args['isOwner'] as bool? ?? false,
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
