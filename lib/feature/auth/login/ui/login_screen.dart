import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/auth/login/logic/login_cubit.dart';
import 'package:rebtal/feature/auth/login/ui/forgot_password_screen.dart';
import 'package:rebtal/feature/auth/widget/auth_wanderly_scaffold.dart';
import 'package:rebtal/feature/auth/widget/wanderly_fields.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) {
        // Always surface feedback for these states.
        // This prevents "button seems stuck" when runtimeType stays the same
        // but the error message changes on retry.
        return current is LoginFailure ||
            current is LoginValidationError ||
            current is LoginOfflineWarning ||
            current is LoginSuccess;
      },
      listener: (context, state) {
        context.read<LoginCubit>().handleLoginState(context, state);
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          final isLoading = state is LoginLoading;

          return AuthWanderlyScaffold(
            appName: 'Rebtal',
            brandSubtitle: context.tr('auth_brand_subtitle'),
            primaryColor: ColorsManager.blue2563EB,
            title: context.tr('auth_login'),
            subtitle: context.tr('auth_login_subtitle'),
            form: _LoginForm(cubit: cubit, isLoading: isLoading),
            footer: const _SignUpLink(),
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.cubit, required this.isLoading});

  final LoginCubit cubit;
  final bool isLoading;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    final primary = ColorsManager.blue2563EB;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WanderlyField(
          controller: widget.cubit.emailController,
          label: context.tr('auth_email'),
          hint: context.tr('auth_enter_email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        WanderlyField(
          controller: widget.cubit.passwordController,
          label: context.tr('auth_password'),
          hint: context.tr('auth_enter_password'),
          obscureText: widget.cubit.obscurePassword,
          suffix: IconButton(
            onPressed: widget.cubit.togglePasswordVisibility,
            icon: Icon(
              widget.cubit.obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: DynamicThemeManager.isDarkMode(context)
                  ? Colors.white54
                  : ColorsManager.grey6B7280,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: Checkbox(
                    value: _termsAccepted,
                    onChanged: (v) =>
                        setState(() => _termsAccepted = v ?? false),
                    activeColor: primary,
                    checkColor: Colors.white,
                    side: BorderSide(
                      color: DynamicThemeManager.isDarkMode(context)
                          ? Colors.white38
                          : Colors.grey.shade400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.termsScreen),
                  child: Text(
                    context.tr('auth_terms'),
                    style: TextStyle(
                      fontSize: 12,
                      color: DynamicThemeManager.isDarkMode(context)
                          ? Colors.white70
                          : ColorsManager.grey6B7280,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          (DynamicThemeManager.isDarkMode(context)
                                  ? Colors.white70
                                  : ColorsManager.grey6B7280)
                              .withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: Text(
                context.tr('auth_forgot_password'),
                style: TextStyle(color: primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        if (!_termsAccepted)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.tr('auth_must_agree'),
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 12),
        WanderlyPrimaryButton(
          label: context.tr('auth_login'),
          primaryColor: primary,
          isLoading: widget.isLoading,
          onPressed: _termsAccepted ? () => loginCubit.login() : null,
        ),
      ],
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink();

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('auth_no_account'),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : ColorsManager.grey6B7280,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(Routes.registerScreen),
          child: Text(
            context.tr('auth_create_account'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark
                  ? ColorsManager.skyBlue38BDF8
                  : ColorsManager.blue2563EB,
            ),
          ),
        ),
      ],
    );
  }
}
