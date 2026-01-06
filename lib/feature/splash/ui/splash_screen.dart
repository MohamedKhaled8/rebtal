import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/firebase_index_creator.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/constant/image_assets_manger.dart';

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

      // Access AuthCubit through AppCubit
      final appCubit = context.read<AppCubit>();
      final authCubit = appCubit.authCubit;

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
        // Fallback: If no success/registration state, check if we need to go to login
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || authCubit.state is AuthFailure) {
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
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
    final authCubit = context.read<AppCubit>().authCubit;
    final size = MediaQuery.of(context).size;

    return BlocListener(
      bloc: authCubit,
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateBasedOnRole();
        } else if (state is AuthRegistrationSuccess) {
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
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: ColorManager.darkBackground0A0E27,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorManager.darkBackground0A0E27,
                ColorManager.darkBlue1A1A2E,
                Color(0xFF0F172A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 1. Ambient Background Glows (Glassmorphism backdrop)
              Positioned(
                top: -100,
                right: -50,
                child: ZoomIn(
                  duration: const Duration(seconds: 3),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ColorManager.purple764BA2.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -60,
                child: ZoomIn(
                  duration: const Duration(seconds: 4),
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ColorManager.blue2563EB.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Center Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Logo Container
                    ElasticIn(
                      duration: const Duration(seconds: 2),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              ColorManager.blue2563EB,
                              ColorManager.purple764BA2,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorManager.blue2563EB.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              ImageAssetsManger.logo,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.villa_rounded,
                                    size: 60,
                                    color: ColorManager.blue2563EB,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Brand Name
                    FadeInUp(
                      duration: const Duration(seconds: 1),
                      delay: const Duration(milliseconds: 500),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFE2E8F0)],
                        ).createShader(bounds),
                        child: const Text(
                          'REBTAL',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: Colors.white,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tagline
                    FadeIn(
                      duration: const Duration(seconds: 2),
                      delay: const Duration(seconds: 1),
                      child: Text(
                        'صيفك يبدأ من هنا',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bottom Loading/Status Segment
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    FadeIn(
                      delay: const Duration(seconds: 1),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(seconds: 2),
                      child: Text(
                        'PREMIUM CHALET EXPERIENCES',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 3,
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
}
