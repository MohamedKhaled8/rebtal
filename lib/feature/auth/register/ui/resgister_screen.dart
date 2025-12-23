import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/function/snak_bar.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/glassmor_phic_card.dart';
import 'package:rebtal/feature/auth/register/widget/login_link_widget.dart';

import 'package:screen_go/extensions/responsive_nums.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                      cubit.register(
                        name: cubit.nameController.text.trim(),
                        email: cubit.emailController.text.trim(),
                        password: cubit.passwordController.text.trim(),
                        phone: cubit.phoneController.text.trim(),
                        role: cubit.selectedRole,
                      );
                    }
                  : null,
            );
          } else if (state is AuthValidationError) {
            showMessage(context, state.message, QuickAlertType.warning);
          } else if (state is AuthOfflineWarning) {
            _showOfflineWarning(context, state.message);
          } else if (state is AuthRegistrationSuccess) {
            // Navigate to Email Verification Screen
            Navigator.of(
              context,
            ).pushNamed(Routes.emailVerification, arguments: state.user.email);
          } else if (state is AuthSuccess) {
            showMessage(
              context,
              "Welcome aboard, ${state.user.name}!",
              QuickAlertType.success,
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (Navigator.of(context).mounted) {
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
                const _RegisterBackground(),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _introController,
                                curve: Curves.easeIn,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 2.h),

                                  // Header
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Create your account",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        SizedBox(height: 0.8.h),
                                        Text(
                                          "Set up your profile to start booking effortless stays.",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 3.h),

                                  // Centered Card
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 1.w,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 40,
                                              offset: const Offset(0, 20),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GlassmorPhicCard(
                                              obscurePassword:
                                                  cubit.obscurePassword,
                                              selectedRole: cubit.selectedRole,
                                              togglePasswordVisibility: cubit
                                                  .togglePasswordVisibility,
                                            ),

                                            SizedBox(height: 3.h),

                                            // Register Button
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              child: isLoading
                                                  ? const SizedBox(
                                                      height: 56,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: double.infinity,
                                                      height: 56,
                                                      child: _RegisterPrimaryButton(
                                                        onPressed: () {
                                                          FocusScope.of(
                                                            context,
                                                          ).unfocus();
                                                          cubit.register(
                                                            name: cubit
                                                                .nameController
                                                                .text
                                                                .trim(),
                                                            email: cubit
                                                                .emailController
                                                                .text
                                                                .trim(),
                                                            phone: cubit
                                                                .phoneController
                                                                .text
                                                                .trim(),
                                                            password: cubit
                                                                .passwordController
                                                                .text
                                                                .trim(),
                                                            role: cubit
                                                                .selectedRole,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                            ),

                                            SizedBox(height: 2.5.h),

                                            const LoginLinkWidget(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

class _RegisterBackground extends StatefulWidget {
  const _RegisterBackground();

  @override
  State<_RegisterBackground> createState() => _RegisterBackgroundState();
}

class _RegisterPrimaryButton extends StatefulWidget {
  const _RegisterPrimaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_RegisterPrimaryButton> createState() => _RegisterPrimaryButtonState();
}

class _RegisterPrimaryButtonState extends State<_RegisterPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0,
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
            padding: EdgeInsets.zero,
            elevation: 6,
            backgroundColor: Colors.transparent,
            shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
          ),
          onPressed: widget.onPressed,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                "Create account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterBackgroundState extends State<_RegisterBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
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
        final offset = (_controller.value - 0.5) * 30;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF0EA5E9), Color(0xFF1D4ED8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 120 - offset,
                right: -60,
                child: _blurCircle(const Color(0xFF38BDF8).withOpacity(0.35)),
              ),
              Positioned(
                bottom: 30 + offset,
                left: -40,
                child: _blurCircle(const Color(0xFF2563EB).withOpacity(0.25)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blurCircle(Color color) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 140,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
