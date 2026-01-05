import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/forgot_password/logic/forgot_password_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/custom_input_field.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocProvider(
      create: (context) => ForgotPasswordCubit(),
      child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
        builder: (context, state) {
          final cubit = context.read<ForgotPasswordCubit>();
          final isLoading = state is ForgotPasswordLoading;

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
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? ColorManager.darkSurface1E1E1E
                                  : ColorManager.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: isDark
                                  ? ColorManager.white
                                  : ColorManager.chaletTextPrimaryLight,
                              size: 18,
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
                            'نسيت كلمة المرور',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: isDark ? ColorManager.white : Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أدخل بريدك الإلكتروني وسنرسل لك\nرابط إعادة تعيين كلمة المرور',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? ColorManager.white70
                                  : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomInputField(
                      controller: cubit.emailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorManager.bookingsAccentPrimary
                            : ColorManager.blue2563EB,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: ColorManager.transparent,
                        child: InkWell(
                          onTap: isLoading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  cubit.sendResetLink(context);
                                },
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorManager.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'إرسال رابط إعادة التعيين',
                                    style: TextStyle(
                                      color: ColorManager.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
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
