import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/feature/auth/login/logic/login_cubit.dart';
import 'package:rebtal/feature/auth/login/ui/forgot_password_screen.dart';
import 'package:rebtal/feature/auth/register/widget/custom_input_field.dart';
import 'package:rebtal/feature/auth/widget/handwritten_animated_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) {
        // Only listen if state type changed AND previous wasn't LoginSuccess
        // This prevents duplicate navigation
        return previous.runtimeType != current.runtimeType &&
            previous is! LoginSuccess;
      },
      listener: (context, state) {
        context.read<LoginCubit>().handleLoginState(context, state);
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          final isLoading = state is LoginLoading;

          return Scaffold(
            backgroundColor: isDark
                ? ColorManager.scaffolColor
                : ColorManager.profileBackgroundLight,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: HandwrittenAnimatedText(
                          text: 'Rebtal',
                          fontSize: 64,
                          color: isDark
                              ? ColorManager.white
                              : ColorManager.chaletActionBlue,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _LogoSection(isDark: isDark),
                      const SizedBox(height: 48),
                      _LoginForm(
                        isDark: isDark,
                        cubit: cubit,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 24),
                      _SignUpLink(isDark: isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Login herer',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? ColorManager.white
                  : ColorManager.chaletActionBlue,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back you\'ve been missed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? ColorManager.white
                  : ColorManager.chaletActionBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.isDark,
    required this.cubit,
    required this.isLoading,
  });

  final bool isDark;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomInputField(
          controller: widget.cubit.emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        CustomInputField(
          controller: widget.cubit.passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: widget.cubit.obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              widget.cubit.obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: widget.isDark
                  ? ColorManager.white70.withOpacity(0.6)
                  : ColorManager.chaletGrey500,
              size: 20,
            ),
            onPressed: widget.cubit.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? ColorManager.bookingsAccentPrimary
                    : ColorManager.chaletActionBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Terms and Conditions Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _termsAccepted,
              onChanged: (value) {
                setState(() {
                  _termsAccepted = value ?? false;
                });
              },
              activeColor: widget.isDark
                  ? ColorManager.bookingsAccentPrimary
                  : ColorManager.blue2563EB,
              checkColor: ColorManager.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _termsAccepted = !_termsAccepted;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.isDark
                            ? ColorManager.white70
                            : ColorManager.chaletGrey800,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'أوافق على '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.termsScreen);
                            },
                            child: Text(
                              'الشروط والأحكام',
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.isDark
                                    ? ColorManager.bookingsAccentPrimary
                                    : ColorManager.blue2563EB,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' وسياسة الخصوصية'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_termsAccepted)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Text(
              'يجب الموافقة على الشروط والأحكام للمتابعة',
              style: TextStyle(
                fontSize: 11,
                color: ColorManager.chaletUnavailableRed,
              ),
            ),
          ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isLoading
              ? SizedBox(
                  height: 52,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isDark
                            ? ColorManager.bookingsAccentPrimary
                            : ColorManager.blue2563EB,
                      ),
                    ),
                  ),
                )
              : _PrimaryButton(
                  isDark: widget.isDark,
                  label: 'تسجيل الدخول',
                  onPressed: _termsAccepted ? () => loginCubit.login() : null,
                ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isDark,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isEnabled
            ? (isDark
                  ? ColorManager.bookingsAccentPrimary
                  : ColorManager.blue2563EB)
            : (isDark
                  ? ColorManager.chaletGrey800
                  : ColorManager.chaletGrey400),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: ColorManager.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isEnabled
                    ? ColorManager.white
                    : ColorManager.white.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpLink extends StatelessWidget {
  const _SignUpLink({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? ColorManager.white70 : ColorManager.chaletGrey500,
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.registerScreen);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: Text(
            'إنشاء حساب',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? ColorManager.bookingsAccentPrimary
                  : ColorManager.blue2563EB,
            ),
          ),
        ),
      ],
    );
  }
}
