import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/export_routes.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_contract.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/custom_input_field.dart';
import 'package:rebtal/feature/auth/register/widget/login_link_widget.dart';
import 'package:rebtal/feature/auth/register/widget/role_selector.dart';
import 'package:rebtal/feature/auth/widget/auth_wanderly_scaffold.dart';
import 'package:rebtal/feature/auth/widget/wanderly_fields.dart';
import 'package:rebtal/core/utils/validators/auth_validator.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showProfileImageError = false;
  bool _submittedOnce = false;

  String _trSafe(BuildContext context, String key, String fallback) {
    final value = context.tr(key);
    return value == key ? fallback : value;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) {
        // Ensure we always surface feedback for validation / errors,
        // even if the runtimeType stays the same between attempts.
        return current is RegisterFailure ||
            current is RegisterValidationError ||
            current is RegisterOfflineWarning ||
            current is RegisterSuccess;
      },
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
            form: Form(
              key: cubit.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AvatarPicker(
                    isDark: isDark,
                    image: cubit.profileImage,
                    hasError: _showProfileImageError && cubit.profileImage == null,
                    onTap: () async {
                      final image = await getIt<HelperImageContract>()
                          .pickImageFile(context);
                      if (image != null && context.mounted) {
                        cubit.setProfileImage(image);
                        setState(() => _showProfileImageError = false);
                      }
                    },
                  ),
                  if (_showProfileImageError && cubit.profileImage == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _trSafe(
                        context,
                        'auth_profile_image_required',
                        'يرجى إضافة الصورة الشخصية',
                      ),
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // —— Personal Info Section ——
                  _buildSectionTitle(context, 'المعلومات الشخصية', Icons.person_rounded, isDark),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: cubit.nameController,
                    label: context.tr('auth_full_name'),
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                    autovalidateMode: _submittedOnce
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return context.tr('auth_name_required');
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: cubit.emailController,
                    label: context.tr('auth_email'),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: _submittedOnce
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return context.tr('auth_email_required');
                      final errorKey = AuthValidator.validateEmail(v);
                      if (errorKey == null) return null;
                      return _trSafe(context, errorKey, 'يرجى إدخال بريد إلكتروني صحيح');
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: cubit.phoneController,
                    label: context.tr('auth_phone'),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: _submittedOnce
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return _trSafe(context, 'auth_phone_required', 'يرجى إدخال رقم الهاتف');
                      final errorKey = AuthValidator.validatePhone(v);
                      if (errorKey == null) return null;
                      return _trSafe(context, errorKey, 'يرجى إدخال رقم الهاتف');
                    },
                  ),
                  const SizedBox(height: 24),

                  // —— Security Section ——
                  _buildSectionTitle(context, 'الأمان والتحقق', Icons.security_rounded, isDark),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: cubit.passwordController,
                    label: context.tr('auth_password'),
                    icon: Icons.lock_outline_rounded,
                    obscureText: cubit.obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    autovalidateMode: _submittedOnce
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    suffixIcon: IconButton(
                      onPressed: cubit.togglePasswordVisibility,
                      icon: Icon(
                        cubit.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: isDark ? Colors.white54 : ColorsManager.grey6B7280,
                        size: 20,
                      ),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return context.tr('auth_password_required');
                      if (v.length < 6) return _trSafe(context, 'auth_password_too_short', 'كلمة المرور يجب ألا تقل عن 6 أحرف');
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? ColorsManager.skyBlue38BDF8.withOpacity(0.12)
                            : ColorsManager.blue2563EB.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('auth_id_card_optional'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? ColorsManager.skyBlue38BDF8
                              : ColorsManager.blue2563EB,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('auth_id_card_optional_hint'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : ColorsManager.grey6B7280,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _IdCardSelector(
                    isDark: isDark,
                    image: cubit.idCardImage,
                    hasError: false,
                    onTap: () async {
                      final image = await getIt<HelperImageContract>()
                          .pickImageFile(context);
                      if (image != null && context.mounted) {
                        cubit.setIdCardImage(image);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // —— Role Selection ——
                  _buildSectionTitle(context, 'نوع الحساب', Icons.supervised_user_circle_rounded, isDark),
                  const SizedBox(height: 12),
                  RoleSelector(
                    selectedRole: cubit.selectedRole,
                    onChanged: cubit.setRole,
                  ),
                  const SizedBox(height: 32),
                  
                  WanderlyPrimaryButton(
                    label: context.tr('auth_create_account'),
                    primaryColor: ColorsManager.blue2563EB,
                    isLoading: isLoading,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (!_submittedOnce) setState(() => _submittedOnce = true);
                      final isValid = cubit.formKey.currentState?.validate() ?? false;
                      final missingProfile = cubit.profileImage == null;

                      setState(() {
                        _showProfileImageError = missingProfile;
                      });

                      if (!isValid) {
                        SnackBarHelper.showWarning(context, context.tr('auth_fill_empty_fields'));
                        return;
                      }
                      if (missingProfile) return;
                      cubit.register();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            footer: LoginLinkWidget(isDark: isDark),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? ColorsManager.skyBlue38BDF8.withOpacity(0.1) : ColorsManager.blue2563EB.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: isDark ? ColorsManager.skyBlue38BDF8 : ColorsManager.blue2563EB,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white70 : ColorsManager.grey1F2937,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? Colors.white.withOpacity(0.1) : ColorsManager.greyE5E7EB,
                  isDark ? Colors.transparent : Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.isDark,
    this.image,
    required this.hasError,
    required this.onTap,
  });

  final bool isDark;
  final File? image;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: hasError ? ColorsManager.red : ColorsManager.blue2563EB.withOpacity(0.4),
              width: hasError ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipOval(
                  child: Container(
                    color: isDark
                        ? ColorsManager.darkSurface1E1E1E
                        : ColorsManager.blueEFF6FF,
                    child: image != null
                        ? Image.file(
                            image!,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.person_outline_rounded,
                            color: isDark ? Colors.white54 : ColorsManager.blue2563EB.withOpacity(0.7),
                            size: 44,
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: ColorsManager.blue2563EB,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 15,
                    color: Colors.white,
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

class _IdCardSelector extends StatelessWidget {
  const _IdCardSelector({
    required this.isDark,
    required this.hasError,
    required this.onTap,
    this.image,
  });

  final bool isDark;
  final bool hasError;
  final VoidCallback onTap;
  final File? image;

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;
    final borderColor = hasError
        ? ColorsManager.red
        : (isDark ? Colors.white.withOpacity(0.15) : ColorsManager.greyE5E7EB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: isDark ? ColorsManager.darkSurface1E1E1E : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? ColorsManager.red : borderColor,
            width: hasError ? 2 : 1.2,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (hasImage)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasImage) ...[
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('auth_id_card_uploaded'),
                        style: TextStyle(
                          color: isDark ? Colors.white : ColorsManager.grey1F2937,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'انقر لتغيير الصورة',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : ColorsManager.grey6B7280,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Icon(
                        Icons.badge_outlined,
                        color: isDark ? Colors.white54 : ColorsManager.grey6B7280,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('auth_upload_id_card'),
                        style: TextStyle(
                          color: isDark ? Colors.white : ColorsManager.grey1F2937,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'يرجى اختيار صورة واضحة للبطاقة',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : ColorsManager.grey6B7280,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (hasImage)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

