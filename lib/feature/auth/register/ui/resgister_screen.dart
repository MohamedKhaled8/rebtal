import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/login_link_widget.dart';
import 'package:rebtal/feature/auth/register/widget/role_selector.dart';
import 'package:rebtal/feature/auth/widget/auth_wanderly_scaffold.dart';
import 'package:rebtal/feature/auth/widget/wanderly_fields.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        context.read<RegisterCubit>().handleRegisterState(context, state);
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          final cubit = context.read<RegisterCubit>();
          final isLoading = state is RegisterLoading;
          final isDark = DynamicThemeManager.isDarkMode(context);

          return AuthWanderlyScaffold(
            appName: 'Rebtal',
            brandSubtitle: context.tr('auth_brand_subtitle'),
            primaryColor: ColorsManager.blue2563EB,
            title: context.tr('auth_create_account'),
            subtitle: context.tr('auth_create_account_desc'),
            maxWidth: 560,
            form: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AvatarPicker(
                  isDark: isDark,
                  hasImage: cubit.profileImage != null,
                  onTap: () async {
                    final image = await HelperImage().pickImageFile(context);
                    if (image != null && context.mounted) {
                      cubit.setProfileImage(image);
                    }
                  },
                ),
                const SizedBox(height: 12),
                WanderlyField(
                  controller: cubit.nameController,
                  label: context.tr('auth_full_name'),
                  hint: context.tr('auth_enter_full_name'),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 10),
                WanderlyField(
                  controller: cubit.emailController,
                  label: context.tr('auth_email'),
                  hint: context.tr('auth_enter_email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                WanderlyField(
                  controller: cubit.phoneController,
                  label: context.tr('auth_phone'),
                  hint: context.tr('auth_enter_phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                WanderlyField(
                  controller: cubit.passwordController,
                  label: context.tr('auth_password'),
                  hint: context.tr('auth_enter_password'),
                  obscureText: cubit.obscurePassword,
                  suffix: IconButton(
                    onPressed: cubit.togglePasswordVisibility,
                    icon: Icon(
                      cubit.obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isDark
                          ? Colors.white54
                          : ColorsManager.grey6B7280,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _UploadRow(
                  isDark: isDark,
                  onTap: () async {
                    final image = await HelperImage().pickImageFile(context);
                    if (image != null && context.mounted) {
                      cubit.setIdCardImage(image);
                    }
                  },
                  label: cubit.idCardImage == null
                      ? context.tr('auth_upload_id_card')
                      : context.tr('auth_id_card_uploaded'),
                ),
                const SizedBox(height: 12),
                RoleSelector(
                  selectedRole: cubit.selectedRole,
                  onChanged: cubit.setRole,
                ),
                const SizedBox(height: 14),
                WanderlyPrimaryButton(
                  label: context.tr('auth_create_account'),
                  primaryColor: ColorsManager.blue2563EB,
                  isLoading: isLoading,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    cubit.register();
                  },
                ),
              ],
            ),
            footer: LoginLinkWidget(isDark: isDark),
          );
        },
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.isDark,
    required this.hasImage,
    required this.onTap,
  });

  final bool isDark;
  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = hasImage
        ? ColorsManager.blue2563EB
        : (isDark ? Colors.white54 : ColorsManager.grey6B7280);
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 74,
          height: 74,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? ColorsManager.darkSurface1E1E1E
                        : ColorsManager.blueEFF6FF,
                    border: Border.all(
                      color: ColorsManager.blue2563EB.withOpacity(
                        isDark ? 0.45 : 0.2,
                      ),
                    ),
                  ),
                  child: Icon(
                    hasImage
                        ? Icons.check_circle_rounded
                        : Icons.person_outline_rounded,
                    color: ring,
                    size: 34,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark
                        ? ColorsManager.darkSurface1E1E1E
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white24
                          : ColorsManager.greyE5E7EB,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: isDark
                        ? ColorsManager.skyBlue38BDF8
                        : ColorsManager.blue2563EB,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    required this.isDark,
    required this.onTap,
    required this.label,
  });

  final bool isDark;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final border =
        isDark ? Colors.white.withOpacity(0.12) : ColorsManager.greyE5E7EB;
    final fill =
        isDark ? ColorsManager.darkBackground121212 : ColorsManager.greyF9FAFB;
    final text = isDark ? Colors.white70 : ColorsManager.grey6B7280;
    final accent =
        isDark ? ColorsManager.skyBlue38BDF8 : ColorsManager.blue2563EB;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.badge_outlined, color: text),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
            Icon(Icons.edit_rounded, color: accent),
          ],
        ),
      ),
    );
  }
}
