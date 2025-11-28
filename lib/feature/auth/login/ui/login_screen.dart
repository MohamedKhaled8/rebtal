import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/config/space.dart';
import 'package:rebtal/core/utils/function/snak_bar.dart';
import 'package:rebtal/core/utils/helper/extensions.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/auth/login/ui/forgot_password_screen.dart';
import 'package:rebtal/feature/auth/register/widget/custom_input_field.dart';

import 'package:screen_go/extensions/responsive_nums.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  Route _buildSlideRoute(Widget child, {bool fromBottom = false}) {
    final beginOffset = fromBottom ? const Offset(0, 1) : const Offset(1, 0);
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (context, animation, secondary, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            _showErrorDialog(
              context,
              state.error,
              isRetryable: state.isRetryable,
              onRetry: state.isRetryable
                  ? () {
                      final cubit = context.read<AuthCubit>();
                      cubit.login(
                        email: cubit.emailController.text.trim(),
                        password: cubit.passwordController.text.trim(),
                      );
                    }
                  : null,
            );
          } else if (state is AuthValidationError) {
            showMessage(context, state.message, QuickAlertType.warning);
          } else if (state is AuthOfflineWarning) {
            _showOfflineWarning(context, state.message);
          } else if (state is AuthSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!Navigator.of(context).mounted) return;
              if (state.user.role == "admin") {
                Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.bottomNavigationBarScreen,
                );
              }
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          final isLoading = state is AuthLoading;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                const _AuthBackground(),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            verticalSpace(50),
                            _Header(introAnimation: _fadeAnimation),
                            verticalSpace(50),
                            _AuthCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome back",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: const Color(0xFF0F172A),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  verticalSpace(0.8),
                                  Text(
                                    "Login to continue exploring handpicked stays.",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  verticalSpace(3),
                                  CustomInputField(
                                    controller: cubit.emailController,
                                    label: 'Email address',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  verticalSpace(2),
                                  CustomInputField(
                                    controller: cubit.passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: cubit.obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        cubit.obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: cubit.togglePasswordVisibility,
                                    ),
                                  ),
                                  verticalSpace(1.5),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          _buildSlideRoute(
                                            const ForgotPasswordScreen(),
                                            fromBottom: true,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Forgot password?",
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  verticalSpace(1),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    switchInCurve: Curves.easeInOut,
                                    child: isLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 46,
                                              height: 46,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            height: 6.5.h,
                                            child: _AnimatedPrimaryButton(
                                              onPressed: () {
                                                cubit.login(
                                                  password: cubit
                                                      .passwordController
                                                      .text
                                                      .trim(),
                                                  email: cubit
                                                      .emailController
                                                      .text
                                                      .trim(),
                                                );
                                              },
                                              label: "Sign in",
                                            ),
                                          ),
                                  ),
                                  verticalSpace(1.5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "New to Rebtal?",
                                        style: TextStyle(
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.pushNamed(
                                            Routes.registerScreen,
                                          );
                                        },
                                        child: const Text(
                                          "Create account",
                                          style: TextStyle(
                                            color: Color(0xFF111827),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows error dialog with retry option if applicable
  void _showErrorDialog(
    BuildContext context,
    String errorMessage, {
    bool isRetryable = false,
    VoidCallback? onRetry,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Error',
      text: errorMessage,
      confirmBtnText: isRetryable ? 'Retry' : 'OK',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        if (isRetryable && onRetry != null) {
          Future.delayed(const Duration(milliseconds: 300), onRetry);
        }
      },
      showCancelBtn: isRetryable,
      cancelBtnText: 'Cancel',
      confirmBtnColor: const Color(0xFF2563EB),
    );
  }

  /// Shows offline warning dialog
  void _showOfflineWarning(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'Connection Issue',
      text: message,
      confirmBtnText: 'OK',
      confirmBtnColor: const Color(0xFF2563EB),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.introAnimation});

  final Animation<double> introAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: introAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: "Rebtal",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  children: const [
                    TextSpan(
                      text: "  Auth",
                      style: TextStyle(
                        color: Color(0xFF93C5FD),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      "Secure",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(3),
          const Text(
            "Sign in to continue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          verticalSpace(1),
          Text(
            "Plan and manage your stays effortlessly.",
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatefulWidget {
  const _AuthBackground();

  @override
  State<_AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<_AuthBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = (_controller.value - 0.5) * 20;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 80 + slide,
                left: -30,
                child: _blurCircle(const Color(0xFF2563EB).withOpacity(0.35)),
              ),
              Positioned(
                bottom: -20 - slide,
                right: -40,
                child: _blurCircle(const Color(0xFF38BDF8).withOpacity(0.30)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blurCircle(Color color) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 120,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AnimatedPrimaryButton extends StatefulWidget {
  const _AnimatedPrimaryButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  State<_AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<_AnimatedPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
          ),
          onPressed: widget.onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 0.2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.white24, Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
