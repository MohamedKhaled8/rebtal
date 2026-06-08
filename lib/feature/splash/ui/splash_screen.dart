import 'dart:async';
import 'dart:math' show sin, pi;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:rebtal/feature/onboarding/data/repository/onboarding_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fillController;
  late final Animation<double> _fillAnimation;
  AuthState? _pendingAuthState;
  bool _animationComplete = false;
  bool _hasNavigated = false;
  Timer? _maxWaitTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeInOut),
    );

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationComplete = true;
        _handlePendingNavigation();
        _startMaxWaitTimer();
      }
    });

    _fillController.forward();

    // Check current AuthCubit state after first frame (BlocListener misses existing state)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentAuthState();
    });
  }

  /// Check if AuthCubit already has a terminal state that BlocListener missed
  void _checkCurrentAuthState() {
    debugPrint('🔥 SplashScreen: Checking current auth state');
    if (!mounted || _hasNavigated) {
      debugPrint('🔥 SplashScreen: Not mounted or already navigated');
      return;
    }

    final authCubit = context.read<AppCubit>().authCubit;
    final currentState = authCubit.state;
    debugPrint(
      '🔥 SplashScreen: AuthCubit current state: ${currentState.runtimeType}',
    );

    // If AuthCubit already emitted a terminal state, capture it
    if (currentState is AuthSuccess ||
        currentState is AuthRegistrationSuccess ||
        currentState is AuthFailure ||
        currentState is AuthUnauthenticated ||
        currentState is AuthOfflineWarning) {
      debugPrint(
        '🔥 SplashScreen: Captured existing auth state: ${currentState.runtimeType}',
      );
      _pendingAuthState = currentState;
      _handlePendingNavigation();
    } else {
      debugPrint('🔥 SplashScreen: AuthCubit not in terminal state yet');
    }
  }

  /// إذا لم يصدر AuthCubit أي حالة خلال وقت إضافي ننتقل لشاشة تسجيل الدخول
  void _startMaxWaitTimer() {
    debugPrint('🔥 SplashScreen: Starting max wait timer (4 seconds)');
    _maxWaitTimer?.cancel();
    _maxWaitTimer = Timer(const Duration(seconds: 4), () {
      debugPrint('🔥 SplashScreen: Max wait timer fired');
      if (!mounted || _hasNavigated) return;
      if (_pendingAuthState == null) {
        // Firebase session may exist while AuthCubit is still loading Firestore.
        if (FirebaseAuth.instance.currentUser != null) {
          debugPrint(
            '🔥 SplashScreen: currentUser present, extending wait for AuthCubit',
          );
          _maxWaitTimer?.cancel();
          _maxWaitTimer = Timer(const Duration(seconds: 30), () async {
            if (!mounted || _hasNavigated) return;
            if (_pendingAuthState != null) return;
            if (FirebaseAuth.instance.currentUser != null) {
              try {
                await context.read<AppCubit>().authCubit.reloadUserData();
              } catch (_) {}
              await Future<void>.delayed(const Duration(seconds: 3));
            }
            if (!mounted || _hasNavigated) return;
            if (_pendingAuthState == null) {
              debugPrint(
                '🔥 SplashScreen: Still no auth state after extended wait',
              );
              _navigateToOnboardingOrLogin();
            }
          });
          return;
        }
        debugPrint(
          '🔥 SplashScreen: No auth state after timeout, going to login',
        );
        _navigateToOnboardingOrLogin();
      }
    });
  }

  @override
  void dispose() {
    _maxWaitTimer?.cancel();
    _fillController.dispose();
    super.dispose();
  }

  void _handlePendingNavigation() {
    debugPrint('🔥 SplashScreen: _handlePendingNavigation called');
    debugPrint(
      '🔥 SplashScreen: _animationComplete=$_animationComplete, _pendingAuthState=${_pendingAuthState?.runtimeType}, _hasNavigated=$_hasNavigated',
    );
    if (!_animationComplete || _pendingAuthState == null || _hasNavigated) {
      debugPrint('🔥 SplashScreen: Cannot navigate yet');
      return;
    }
    if (!mounted) return;

    _maxWaitTimer?.cancel();

    if (_pendingAuthState is AuthSuccess) {
      debugPrint('🔥 SplashScreen: Navigating based on role');
      _hasNavigated = true;
      _navigateBasedOnRole();
    } else if (_pendingAuthState is AuthRegistrationSuccess) {
      // Skip email verification - go directly to main screen
      debugPrint('🔥 SplashScreen: Registration success, navigating to main screen');
      _hasNavigated = true;
      _navigateBasedOnRole();
    } else if (_pendingAuthState is AuthOfflineWarning || 
              (_pendingAuthState is AuthFailure && FirebaseAuth.instance.currentUser != null)) {
      debugPrint('🔥 SplashScreen: Offline or Failure but user is logged in. Trying to let them in.');
      final role = getIt<CacheHelper>().getDataString(key: 'userRole');
      if (role != null && role.isNotEmpty) {
        _hasNavigated = true;
        _navigateBasedOnRole();
      } else {
        debugPrint('🔥 SplashScreen: No cached role, forcing login');
        _navigateToOnboardingOrLogin();
      }
    } else if (_pendingAuthState is AuthFailure ||
        _pendingAuthState is AuthUnauthenticated) {
      debugPrint('🔥 SplashScreen: Navigating to login');
      _navigateToOnboardingOrLogin();
    }
  }

  Future<void> _navigateToOnboardingOrLogin() async {
    final completed = await getIt<OnboardingRepository>()
        .isOnboardingCompleted();
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    if (!completed) {
      Navigator.pushReplacementNamed(context, Routes.travelOnboardingScreen);
    } else {
      Navigator.pushReplacementNamed(context, Routes.loginScreen);
    }
  }

  void _navigateBasedOnRole() {
    // Prefer role from the resolved Auth state to avoid timing issues where
    // CacheHelper hasn't persisted `userRole` yet.
    String? roleFromAuthState;
    final pending = _pendingAuthState;
    if (pending is AuthSuccess) {
      roleFromAuthState = pending.user.role;
    } else if (pending is AuthRegistrationSuccess) {
      roleFromAuthState = pending.user.role;
    }

    final String? role =
        roleFromAuthState ?? getIt<CacheHelper>().getDataString(key: 'userRole');
    final normalizedRole = role?.toLowerCase().trim();
    debugPrint('🔥 SplashScreen: Navigating with role: $normalizedRole');
    if (normalizedRole == 'admin') {
      Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
    } else if (normalizedRole == 'owner' || normalizedRole == 'user') {
      Navigator.pushReplacementNamed(context, Routes.bottomNavigationBarScreen);
    } else {
      debugPrint('🔥 SplashScreen: Unknown role, going to login');
      Navigator.pushReplacementNamed(context, Routes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AppCubit>().authCubit;

    return BlocProvider.value(
      value: authCubit,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess ||
              state is AuthRegistrationSuccess ||
              state is AuthFailure ||
              state is AuthUnauthenticated ||
              state is AuthOfflineWarning) {
            debugPrint(' SplashScreen: Received auth state change: ');
            _pendingAuthState = state;
            _handlePendingNavigation();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.holiday_village_rounded,
                    size: 80,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: _LiquidText(
                      fillAnimation: _fillAnimation,
                      text: 'REBTAL',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE0E0E0),
                        letterSpacing: 4,
                      ),
                      liquidColor: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidText extends StatelessWidget {
  final Animation<double> fillAnimation;
  final String text;
  final TextStyle style;
  final Color liquidColor;

  const _LiquidText({
    required this.fillAnimation,
    required this.text,
    required this.style,
    required this.liquidColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fillAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: text.split('').asMap().entries.map((entry) {
            final index = entry.key;
            final letter = entry.value;
            final delay = index * 0.14;
            final durationPerLetter = 0.30;
            final letterProgress =
                ((fillAnimation.value - delay) / durationPerLetter).clamp(
                  0.0,
                  1.0,
                );

            if (fillAnimation.value < delay) {
              return Text(letter, style: style);
            }

            return _LiquidLetter(
              letter: letter,
              fillProgress: letterProgress,
              style: style,
              liquidColor: liquidColor,
            );
          }).toList(),
        );
      },
    );
  }
}

class _LiquidLetter extends StatefulWidget {
  final String letter;
  final double fillProgress;
  final TextStyle style;
  final Color liquidColor;

  const _LiquidLetter({
    required this.letter,
    required this.fillProgress,
    required this.style,
    required this.liquidColor,
  });

  @override
  State<_LiquidLetter> createState() => _LiquidLetterState();
}

class _LiquidLetterState extends State<_LiquidLetter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Text(widget.letter, style: widget.style),
            ClipPath(
              clipper: _WaveClipper(
                fillProgress: widget.fillProgress,
                waveAnimation: _waveController.value,
              ),
              child: Text(
                widget.letter,
                style: widget.style.copyWith(color: widget.liquidColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double fillProgress;
  final double waveAnimation;

  _WaveClipper({required this.fillProgress, required this.waveAnimation});

  @override
  Path getClip(Size size) {
    final path = Path();
    final fillHeight = size.height * (1 - fillProgress);

    path.moveTo(0, fillHeight);

    for (double x = 0; x <= size.width; x++) {
      final waveHeight = 4.0;
      final waveCount = 2.0;
      final y =
          fillHeight +
          sin((x / size.width) * waveCount * 2 * pi + waveAnimation * 2 * pi) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) {
    return oldClipper.fillProgress != fillProgress ||
        oldClipper.waveAnimation != waveAnimation;
  }
}
