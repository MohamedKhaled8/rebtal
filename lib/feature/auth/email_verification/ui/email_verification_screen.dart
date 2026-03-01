import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/email_verification/logic/email_verification_cubit.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocListener<EmailVerificationCubit, EmailVerificationState>(
      listener: (context, state) {
        if (state is EmailVerificationVerified) {
          context.read<EmailVerificationCubit>().handleVerified(context);
        } else if (state is EmailVerificationEmailSent) {
          SnackBarHelper.showSuccess(context, 'تم إرسال بريد التحقق مرة أخرى.');
        } else if (state is EmailVerificationError) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      child: BlocBuilder<EmailVerificationCubit, EmailVerificationState>(
        builder: (context, state) {
          final cubit = context.read<EmailVerificationCubit>();
          final isVerified = state is EmailVerificationVerified;
          final canResend = state is EmailVerificationCanResend;
          final countdown = state is EmailVerificationResendCooldown
              ? state.countdown
              : 0;

          return Scaffold(
            backgroundColor: isDark
                ? ColorManager.darkBackground121212
                : ColorManager.grey50,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => cubit.logout(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: isDark
                                  ? ColorManager.white
                                  : ColorManager.chaletTextPrimaryLight,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isVerified ? 'تم التحقق!' : 'تحقق من بريدك',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? ColorManager.white
                                  : ColorManager.chaletTextPrimaryLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أرسلنا رابط التحقق إلى',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? ColorManager.white70
                                  : ColorManager.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? ColorManager.indigo6366F1
                                  : ColorManager.blue2563EB,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (isVerified)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تم التحقق بنجاح!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? const Color(0xFF667EEA)
                                          : const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'في انتظار التحقق...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 32),
                          TextButton(
                            onPressed: canResend
                                ? () => cubit.resendVerificationEmail()
                                : null,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              canResend
                                  ? 'إعادة إرسال البريد'
                                  : 'إعادة الإرسال خلال $countdown ثانية',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: canResend
                                    ? (isDark
                                          ? const Color(0xFF667EEA)
                                          : const Color(0xFF2563EB))
                                    : (isDark
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF667EEA)
                                    : const Color(0xFF2563EB),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => cubit.checkVerificationStatus(),
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'تم التفعيل - التحقق الآن',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF667EEA)
                                          : const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
