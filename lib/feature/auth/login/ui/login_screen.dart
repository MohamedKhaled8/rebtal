import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
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
                ? Colors.black
                : ColorsManager.profileBackgroundLight,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1518780664697-55e3ad937233?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          isDark ? Colors.black.withOpacity(0.95) : Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          const Icon(
                            Icons.holiday_village_outlined,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: HandwrittenAnimatedText(
                              text: 'Rebtal',
                              fontSize: 72,
                              color: Colors.white,
                              isDark: true,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Center(
                            child: Container(
                              height: 1.5,
                              width: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.5),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _LogoSection(isDark: isDark),
                          const SizedBox(height: 40),
                          _LoginForm(
                            isDark: isDark,
                            cubit: cubit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 32),
                          _SignUpLink(isDark: isDark),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
            context.tr('auth_login_title'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('auth_login_subtitle'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 0.2,
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
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E1E24).withOpacity(0.6)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomInputField(
                controller: widget.cubit.emailController,
                label: context.tr('auth_email'),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: widget.cubit.passwordController,
                label: context.tr('auth_password'),
                icon: Icons.lock_outline_rounded,
                obscureText: widget.cubit.obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.cubit.obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: widget.isDark
                        ? ColorsManager.white70.withOpacity(0.6)
                        : ColorsManager.chaletGrey500,
                    size: 20,
                  ),
                  onPressed: widget.cubit.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight, // Changed to Right for Arabic / usually better
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    context.tr('auth_forgot_password'),
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark
                          ? const Color(0xFF60A5FA)
                          : ColorsManager.chaletActionBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Terms and Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      activeColor: widget.isDark
                          ? const Color(0xFF3B82F6)
                          : ColorsManager.blue2563EB,
                      checkColor: ColorsManager.white,
                      side: BorderSide(
                        color: widget.isDark ? Colors.white30 : Colors.grey.shade400,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _termsAccepted = !_termsAccepted;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.isDark
                                  ? ColorsManager.white70
                                  : ColorsManager.chaletGrey800,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(text: context.tr('auth_agree_terms')),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(Routes.termsScreen);
                                  },
                                  child: Text(
                                    context.tr('auth_terms'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: widget.isDark
                                          ? const Color(0xFF60A5FA)
                                          : ColorsManager.blue2563EB,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(text: context.tr('auth_and_privacy')),
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
                  padding: const EdgeInsets.only(left: 36, top: 8),
                  child: Text(
                    context.tr('auth_must_agree'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.isLoading
                    ? SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isDark
                                  ? const Color(0xFF3B82F6)
                                  : ColorsManager.blue2563EB,
                            ),
                          ),
                        ),
                      )
                    : _PrimaryButton(
                        isDark: widget.isDark,
                        label: context.tr('auth_login'),
                        onPressed: _termsAccepted ? () => loginCubit.login() : null,
                      ),
              ),
            ],
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
      height: 56,
      decoration: BoxDecoration(
        color: isEnabled
            ? (isDark
                  ? const Color(0xFF3B82F6) // Brighter premium blue
                  : const Color(0xFF2563EB))
            : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : ColorsManager.grey300),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: (isDark
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF2563EB))
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: ColorsManager.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isEnabled
                    ? ColorsManager.white
                    : ColorsManager.white.withOpacity(0.6),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.tr('auth_no_account'),
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.registerScreen);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                context.tr('auth_create_account'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

