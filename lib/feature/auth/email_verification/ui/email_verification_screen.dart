import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  Timer? _timer;
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Start checking for email verification
    _startVerificationCheck();

    // Start resend cooldown
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        setState(() {
          _isEmailVerified = true;
        });

        if (mounted) {
          // ✅ Notify AuthCubit that email is verified
          await context.read<AuthCubit>().confirmEmailVerification();

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Verified!',
            text: 'Your email has been verified successfully.',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.bottomNavigationBarScreen, // Or homeScreen
              (route) => false,
            );
          });
        }
      }
    });
  }

  void _startResendTimer() {
    setState(() {
      _canResendEmail = false;
      _resendCountdown = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Email Sent',
        text: 'Verification email sent again.',
      );
      _startResendTimer();
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Failed to send verification email. Please try again later.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeIn,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    // Logout Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () async {
                          await context.read<AuthCubit>().logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.loginScreen,
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: _buildVerificationCard(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0EA5E9), Color(0xFF1D4ED8)],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withOpacity(0.1),
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              size: 40,
              color: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Check your email',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'We sent a verification link to',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 0.5.h),
          Text(
            widget.email,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          if (_isEmailVerified)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Verified!",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          else
            const CircularProgressIndicator(),

          SizedBox(height: 2.h),
          Text(
            'Waiting for verification...',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),

          SizedBox(height: 4.h),

          TextButton(
            onPressed: _canResendEmail ? _resendVerificationEmail : null,
            child: Text(
              _canResendEmail
                  ? 'Resend Email'
                  : 'Resend in $_resendCountdown s',
              style: TextStyle(
                color: _canResendEmail ? const Color(0xFF3B82F6) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
