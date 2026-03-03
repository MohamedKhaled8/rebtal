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
  }

  /// إذا لم يصدر AuthCubit أي حالة خلال وقت إضافي، ننتقل لشاشة تسجيل الدخول
  void _startMaxWaitTimer() {
    _maxWaitTimer?.cancel();
    _maxWaitTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _hasNavigated) return;
      if (_pendingAuthState == null) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(context, Routes.loginScreen);
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
    if (!_animationComplete || _pendingAuthState == null || _hasNavigated)
      return;
    if (!mounted) return;

    _maxWaitTimer?.cancel();
    _hasNavigated = true;

    if (_pendingAuthState is AuthSuccess) {
      _navigateBasedOnRole();
    } else if (_pendingAuthState is AuthRegistrationSuccess) {
      final state = _pendingAuthState as AuthRegistrationSuccess;
      Navigator.pushReplacementNamed(
        context,
        Routes.emailVerification,
        arguments: state.user,
      );
    } else if (_pendingAuthState is AuthFailure ||
        _pendingAuthState is AuthUnauthenticated ||
        _pendingAuthState is AuthOfflineWarning) {
      Navigator.pushReplacementNamed(context, Routes.loginScreen);
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

    return BlocListener(
      bloc: authCubit,
      listener: (context, state) {
        if (state is AuthSuccess ||
            state is AuthRegistrationSuccess ||
            state is AuthFailure ||
            state is AuthUnauthenticated ||
            state is AuthOfflineWarning) {
          _pendingAuthState = state as AuthState;
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
                  Icons.villa_rounded,
                  size: 80,
                  color: const Color(0xFFFF5A5F),
                ),
                const SizedBox(height: 16),
                _LiquidText(
                  fillAnimation: _fillAnimation,
                  text: 'REBTAL',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE0E0E0),
                    letterSpacing: 4,
                  ),
                  liquidColor: const Color(0xFFFF5A5F),
                ),
              ],
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
