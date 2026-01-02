import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/glassmor_phic_card.dart';
import 'package:rebtal/feature/auth/register/widget/login_link_widget.dart';
import 'package:rebtal/feature/auth/widget/handwritten_animated_text.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = DynamicThemeManager.isDarkMode(context);

    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        context.read<RegisterCubit>().handleRegisterState(context, state);
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, registerState) {
          return Scaffold(
            backgroundColor: isDark
                ? ColorManager.darkBackground121212
                : ColorManager.grey50,
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
                              : ColorManager.chaletActionDarkBlue,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(height: 32),
                      BlocBuilder<RegisterCubit, RegisterState>(
                        builder: (context, registerState) {
                          final cubit = context.read<RegisterCubit>();
                          return GlassmorPhicCard(
                            obscurePassword: cubit.obscurePassword,
                            selectedRole: cubit.selectedRole,
                            togglePasswordVisibility:
                                cubit.togglePasswordVisibility,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: registerState is RegisterLoading
                            ? SizedBox(
                                height: 52,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? ColorManager.bookingsAccentPrimary
                                          : ColorManager.blue2563EB,
                                    ),
                                  ),
                                ),
                              )
                            : _PrimaryButton(
                                isDark: isDark,
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  context.read<RegisterCubit>().register();
                                },
                              ),
                      ),
                      const SizedBox(height: 24),
                      LoginLinkWidget(isDark: isDark),
                      const SizedBox(height: 40),
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

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.onPressed, required this.isDark});

  final VoidCallback onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: const Center(
            child: Text(
              'إنشاء حساب',
              style: TextStyle(
                color: ColorManager.white,
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
