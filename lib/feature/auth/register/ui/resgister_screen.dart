import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'dart:io';
import 'package:rebtal/core/utils/helper/helper_image.dart';
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
                ? ColorsManager.darkBackground121212
                : ColorsManager.grey50,
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
                              ? ColorsManager.white
                              : ColorsManager.chaletActionDarkBlue,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<RegisterCubit, RegisterState>(
                        builder: (context, state) {
                          final cubit = context.read<RegisterCubit>();
                          return Center(
                            child: GestureDetector(
                              onTap: () => _showImageSourceDialog(context),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF333333)
                                          : const Color(0xFFF5F5F5),
                                      image: cubit.profileImage != null
                                          ? DecorationImage(
                                              image: FileImage(
                                                cubit.profileImage!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                    child: cubit.profileImage == null
                                        ? Icon(
                                            Icons.person_outline_rounded,
                                            size: 40,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF222222),
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark
                                              ? ColorsManager
                                                    .darkBackground121212
                                              : ColorsManager.grey50,
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      //const SizedBox(height: 32), // Remove duplicated sizedbox
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
                                          ? ColorsManager.bookingsAccentPrimary
                                          : ColorsManager.blue2563EB,
                                    ),
                                  ),
                                ),
                              )
                            : _PrimaryButton(
                                label: context.tr('auth_create_account'),
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

  void _showImageSourceDialog(BuildContext context) async {
    final image = await HelperImage().pickImageFile(context);
    if (image != null && context.mounted) {
      context.read<RegisterCubit>().setProfileImage(image);
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isDark,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? ColorsManager.bookingsAccentPrimary
            : ColorsManager.blue2563EB,
        borderRadius: BorderRadius.circular(14),
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
                color: ColorsManager.white,
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
