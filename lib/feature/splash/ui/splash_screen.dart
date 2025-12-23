import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/firebase_index_creator.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _sunController;
  late AnimationController _cloudController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Dark icons for light background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _checkAuthState();
  }

  @override
  void dispose() {
    _sunController.dispose();
    _cloudController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _checkAuthState() async {
    try {
      await FirebaseIndexCreator.createCompositeIndexes();
    } catch (e) {
      debugPrint('🔍 DEBUG - Error initializing indexes in splash: $e');
    }

    // Minimum splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Check if onboarding is completed
      final onboardingRepo = getIt<OnboardingRepository>();
      final isOnboardingCompleted = await onboardingRepo
          .isOnboardingCompleted();

      // If onboarding not completed, navigate to onboarding
      if (!isOnboardingCompleted) {
        Navigator.pushReplacementNamed(context, Routes.onBardingScreen);
        return;
      }

      // Otherwise check auth state
      final authCubit = context.read<AuthCubit>();

      if (authCubit.state is AuthSuccess) {
        _navigateBasedOnRole();
      } else if (authCubit.state is AuthRegistrationSuccess) {
        final state = authCubit.state as AuthRegistrationSuccess;
        Navigator.pushReplacementNamed(
          context,
          Routes.emailVerification,
          arguments: state.user.email,
        );
      } else {
        // Init logic will trigger listener automatically when state changes
        // But if already logged in (from _checkCurrentUser in constructor), we can check logic
        // We rely on the BlocListener above for async state changes.
        // However, if we need to force check:
        // _checkCurrentUser runs in constructor, so listener usually catches it.
        // If it's already done (rare race condition):
        // Fallback manual check:
        final user = FirebaseAuth.instance.currentUser;
        if (user == null && authCubit.state is AuthInitial) {
          // Likely not logged in yet or check is running
        }
      }
    }
  }

  void _navigateBasedOnRole() {
    final String? role = getIt<CacheHelper>().getDataString(key: 'userRole');
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
    } else if (role == 'owner') {
      Navigator.pushReplacementNamed(context, Routes.bottomNavigationBarScreen);
    } else {
      Navigator.pushReplacementNamed(context, Routes.bottomNavigationBarScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateBasedOnRole();
        } else if (state is AuthRegistrationSuccess) {
          // Redirect to Email Verification if not verified
          Navigator.pushReplacementNamed(
            context,
            Routes.emailVerification,
            arguments: state.user.email,
          );
        } else if (state is AuthFailure) {
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4FA8C5), // Sky Blue
                Color(0xFF87CEEB), // Lighter Sky
                Colors.white,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // 1. The Sun (Pulsing)
              Positioned(
                top: -60,
                right: -60,
                child: AnimatedBuilder(
                  animation: _sunController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_sunController.value * 0.1),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD54F).withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withOpacity(0.4),
                              blurRadius: 50 + (_sunController.value * 20),
                              spreadRadius: 10 + (_sunController.value * 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. Moving Clouds
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                height: 200,
                child: AnimatedBuilder(
                  animation: _cloudController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        _buildCloud(
                          context,
                          top: 20,
                          left:
                              -100 +
                              (MediaQuery.of(context).size.width + 200) *
                                  _cloudController.value,
                          scale: 1.0,
                        ),
                        _buildCloud(
                          context,
                          top: 80,
                          left:
                              -150 +
                              (MediaQuery.of(context).size.width + 300) *
                                  ((_cloudController.value + 0.5) % 1.0),
                          scale: 0.8,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 3. The Sea (Waves)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 150,
                child: FadeInUp(
                  duration: const Duration(seconds: 1),
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: SeaWavePainter(
                          animationValue: _waveController.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),

              // 4. Main Content (Center)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    ZoomIn(
                      duration: const Duration(milliseconds: 1000),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.beach_access_rounded,
                          size: 64,
                          color: Color(0xFF006994), // Sea Blue
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Text
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: const Text(
                        'Rebtal',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF006994), // Sea Blue
                          letterSpacing: 1.5,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        'صيفك يبدأ من هنا',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF006994).withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloud(
    BuildContext context, {
    required double top,
    required double left,
    required double scale,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}

class SeaWavePainter extends CustomPainter {
  final double animationValue;

  SeaWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006994).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Animate the wave by shifting the phase
    // We'll use a simple sine-like movement by shifting control points
    // Since we don't want to use dart:math, we can just linearly interpolate the control points

    double shift =
        size.width *
        animationValue; // Shift by full width over the animation cycle

    // We need to draw a wider wave so we can shift it
    path.moveTo(-size.width + shift, size.height * 0.4);

    // Draw multiple wave segments to cover the shift
    for (int i = -1; i < 2; i++) {
      double startX = (i * size.width) + shift;
      path.quadraticBezierTo(
        startX + size.width * 0.25,
        size.height * 0.3,
        startX + size.width * 0.5,
        size.height * 0.4,
      );
      path.quadraticBezierTo(
        startX + size.width * 0.75,
        size.height * 0.5,
        startX + size.width,
        size.height * 0.4,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second layer (slower or different phase)
    final paint2 = Paint()
      ..color = const Color(0xFF006994).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    double shift2 =
        size.width * ((animationValue + 0.5) % 1.0); // Different phase

    path2.moveTo(-size.width + shift2, size.height * 0.5);

    for (int i = -1; i < 2; i++) {
      double startX = (i * size.width) + shift2;
      path2.quadraticBezierTo(
        startX + size.width * 0.25,
        size.height * 0.6,
        startX + size.width * 0.5,
        size.height * 0.5,
      );
      path2.quadraticBezierTo(
        startX + size.width * 0.75,
        size.height * 0.4,
        startX + size.width,
        size.height * 0.5,
      );
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant SeaWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
