import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/function/snak_bar.dart';
import 'package:rebtal/core/utils/validators/phone_validator.dart';
import 'package:rebtal/feature/auth/otp/cubit/otp_cubit.dart';
import 'package:rebtal/feature/auth/otp/widget/otp_input_widget.dart';
import 'package:rebtal/feature/auth/otp/widget/resend_otp_button.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String userName;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.userName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  final GlobalKey<OtpInputWidgetState> _otpInputKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtpCubit>().sendOtp(widget.phoneNumber);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpSent) {
            showMessage(
              context,
              'OTP sent successfully',
              QuickAlertType.success,
            );
          } else if (state is OtpVerified || state is OtpAutoVerified) {
            showMessage(
              context,
              'Phone verified successfully!',
              QuickAlertType.success,
            );

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.bottomNavigationBarScreen,
                  (route) => false,
                );
              }
            });
          } else if (state is OtpError) {
            showMessage(context, state.message, QuickAlertType.error);
            _otpInputKey.currentState?.clear();
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpSending || state is OtpVerifying;

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                _buildBackground(),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
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
                                parent: _fadeController,
                                curve: Curves.easeIn,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 2.h),

                                  // Back Button
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 1.w),
                                      child: IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.white,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withOpacity(0.2),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ),

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
                                          'Verify your phone',
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
                                          'Enter the code sent to ${PhoneValidator.formatForDisplay(widget.phoneNumber)}',
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

                                  SizedBox(height: 4.h),

                                  // Centered Card
                                  Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 1.w,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 3.5.h,
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
                                            // Icon
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(
                                                  0xFF3B82F6,
                                                ).withOpacity(0.1),
                                              ),
                                              child: const Icon(
                                                Icons.phone_android_rounded,
                                                size: 36,
                                                color: Color(0xFF3B82F6),
                                              ),
                                            ),

                                            SizedBox(height: 2.h),

                                            Text(
                                              'Enter verification code',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),

                                            SizedBox(height: 0.5.h),

                                            Text(
                                              'We sent a 6-digit code',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),

                                            SizedBox(height: 3.h),

                                            // OTP Input
                                            OtpInputWidget(
                                              key: _otpInputKey,
                                              onCompleted: (otp) {
                                                context
                                                    .read<OtpCubit>()
                                                    .verifyOtp(otp);
                                              },
                                              onChanged: () {
                                                setState(() {});
                                              },
                                            ),

                                            SizedBox(height: 3.h),

                                            // Loading or Resend button
                                            if (isLoading)
                                              const SizedBox(
                                                height: 50,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            else
                                              ResendOtpButton(
                                                phoneNumber: widget.phoneNumber,
                                              ),

                                            SizedBox(height: 2.h),

                                            // Help text
                                            Text(
                                              'Didn\'t receive the code?',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              'Check your phone or request a new code',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
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
}
