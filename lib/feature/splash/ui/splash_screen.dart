import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/core/utils/firebase_index_creator.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:flutter/services.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _waveController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _waveAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // شريط الحالة شفاف
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _checkAuthState();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_shimmerController);

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });
  }

  void _checkAuthState() async {
    try {
      await FirebaseIndexCreator.createCompositeIndexes();
    } catch (e) {
      print('🔍 DEBUG - Error initializing indexes in splash: $e');
    }

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
        final currentUser = authCubit.getCurrentUser();
        if (currentUser != null) {
          // ✅ Read stored role
          final String? role = getIt<CacheHelper>().getDataString(
            key: 'userRole',
          );

          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
          } else if (role == 'owner') {
            Navigator.pushReplacementNamed(
              context,
              Routes.bottomNavigationBarScreen,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              Routes.bottomNavigationBarScreen,
            );
          }
        } else {
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
        }
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _waveController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // ✅ Read stored role
          final String? role = getIt<CacheHelper>().getDataString(
            key: 'userRole',
          );

          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
          } else if (role == 'owner') {
            Navigator.pushReplacementNamed(
              context,
              Routes.bottomNavigationBarScreen,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              Routes.bottomNavigationBarScreen,
            );
          }
        } else if (state is AuthFailure) {
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
        }
      },
      child: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 4)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted) {
                // Check onboarding first
                final onboardingRepo = getIt<OnboardingRepository>();
                final isOnboardingCompleted = await onboardingRepo
                    .isOnboardingCompleted();

                if (!isOnboardingCompleted) {
                  Navigator.pushReplacementNamed(
                    context,
                    Routes.onBardingScreen,
                  );
                  return;
                }

                // Then check auth
                final authCubit = context.read<AuthCubit>();
                if (authCubit.state is AuthInitial) {
                  Navigator.pushReplacementNamed(context, Routes.loginScreen);
                }
              }
            });
          }

          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B1021),
                    Color(0xFF0E1C34),
                    Color(0xFF0F2A47),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated waves background
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WavePainter(
                          animation: _waveAnimation.value,
                          waveColor: Colors.white.withOpacity(0.1),
                        ),
                        size: Size.infinite,
                      );
                    },
                  ),

                  // Subtle background decoration (circles)
                  Positioned(
                    bottom: -50,
                    right: -50,
                    child: AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoScale.value.clamp(0.0, 1.0),
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: -30,
                    child: AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoScale.value.clamp(0.0, 1.0),
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.035),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScale.value.clamp(0.0, 1.0),
                              child: Transform.rotate(
                                angle: _logoRotation.value,
                                child: Container(
                                  width: 132,
                                  height: 132,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF0EA5E9),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _shimmerAnimation,
                                        builder: (context, child) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: SweepGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.0),
                                                  Colors.white.withOpacity(
                                                    0.20,
                                                  ),
                                                  Colors.white.withOpacity(0.0),
                                                ],
                                                stops: const [0.2, 0.5, 0.8],
                                                transform: GradientRotation(
                                                  _shimmerAnimation.value *
                                                      2 *
                                                      math.pi,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const Icon(
                                        Icons.holiday_village,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Animated app name
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textOpacity,
                                child: Column(
                                  children: [
                                    const Text(
                                      'Rebtal',
                                      style: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 3),
                                            blurRadius: 10,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.18),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'احجز شاليهك بسهولة وأمان',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 60),

                        // Premium loading indicator
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _textOpacity,
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white.withOpacity(0.9),
                                              ),
                                          backgroundColor: Colors.white
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'جاري التحميل...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom decoration
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textOpacity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 16,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'حجوزات شاليهات بسهولة وأمان',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Wave Painter for animated background
class WavePainter extends CustomPainter {
  final double animation;
  final Color waveColor;

  WavePainter({required this.animation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();

    // First wave
    path.moveTo(0, size.height * 0.75);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.75 +
            20 * math.sin((i / size.width * 2 * math.pi) + animation),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final path2 = Path();
    paint.color = waveColor.withOpacity(0.5);

    path2.moveTo(0, size.height * 0.8);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.8 +
            15 *
                math.sin(
                  (i / size.width * 2 * math.pi) + animation + math.pi / 2,
                ),
      );
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
