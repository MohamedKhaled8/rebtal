import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/role_selector.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'custom_input_field.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';

class GlassmorPhicCard extends StatelessWidget {
  final bool obscurePassword;
  final String selectedRole;
  final VoidCallback? togglePasswordVisibility;

  const GlassmorPhicCard({
    super.key,
    required this.obscurePassword,
    required this.selectedRole,
    this.togglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final isDark = DynamicThemeManager.isDarkMode(context);
    final state = context.watch<RegisterCubit>().state;

    return Form(
      key: cubit.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.tr('auth_create_account_title'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? ColorsManager.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              textAlign: TextAlign.center,
              context.tr('auth_create_account_desc'),
              style: TextStyle(
                fontSize: 15,
                color: isDark ? ColorsManager.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 32),
          CustomInputField(
            controller: cubit.nameController,
            label: context.tr('auth_full_name'),
            icon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return ''; // Return empty string to trigger error color without text
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomInputField(
            controller: cubit.emailController,
            label: context.tr('auth_email'),
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return '';
              final emailRegExp =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegExp.hasMatch(value.trim())) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomInputField(
            controller: cubit.phoneController,
            label: context.tr('auth_phone'),
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return '';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomInputField(
            controller: cubit.passwordController,
            label: context.tr('auth_password'),
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) return '';
              if (value.length < 6) return 'Short password';
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey700,
                size: 20,
              ),
              onPressed: togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 24),
          _buildIdCardUploader(context, cubit, isDark, state),
          const SizedBox(height: 24),
          RoleSelector(
            selectedRole: cubit.selectedRole,
            onChanged: (role) => cubit.setRole(role),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بإنشاء حساب، أنت توافق على شروط الخدمة وسياسة الخصوصية',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? ColorsManager.white70 : ColorsManager.grey600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdCardUploader(
    BuildContext context,
    RegisterCubit cubit,
    bool isDark,
    RegisterState state,
  ) {
    final hasError = state is RegisterValidationError && cubit.idCardImage == null;

    return GestureDetector(
      onTap: () async {
        final image = await HelperImage().pickImageFile(context);
        if (image != null && context.mounted) {
          cubit.setIdCardImage(image);
        }
      },
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? ColorsManager.darkSurface1E1E1E : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError
                ? ColorsManager.red
                : cubit.idCardImage != null
                    ? ColorsManager.bookingsAccentPrimary
                    : (isDark ? Colors.white12 : Colors.black12),
            width: hasError ? 2 : 1.5,
          ),
          image: cubit.idCardImage != null
              ? DecorationImage(
                  image: FileImage(cubit.idCardImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              cubit.idCardImage != null
                  ? Icons.check_circle_rounded
                  : Icons.badge_outlined,
              size: 32,
              color: cubit.idCardImage != null
                  ? Colors.white
                  : ColorsManager.bookingsAccentPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              cubit.idCardImage != null
                  ? "تم إرفاق صورة البطاقة، اضغط للتغيير"
                  : "أرفق صورة البطاقة الشخصية (مطلوب)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: cubit.idCardImage != null
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: cubit.idCardImage != null
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
