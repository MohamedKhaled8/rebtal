import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/theme/dynamic_theme_manager.dart';
import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'package:rebtal/feature/auth/register/widget/role_selector.dart';
import 'package:screen_go/extensions/responsive_nums.dart';
import 'custom_input_field.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? ColorManager.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            textAlign: TextAlign.center,
            "Create an account so you can start your journey with us",
            style: TextStyle(
              fontSize: 15,
              color: isDark ? ColorManager.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 32),
        CustomInputField(
          controller: cubit.nameController,
          label: 'الاسم الكامل',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 20),
        CustomInputField(
          controller: cubit.emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        CustomInputField(
          controller: cubit.phoneController,
          label: 'رقم الهاتف',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        CustomInputField(
          controller: cubit.passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: isDark ? ColorManager.white70 : ColorManager.grey700,
              size: 20,
            ),
            onPressed: togglePasswordVisibility,
          ),
        ),
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
              color: isDark ? ColorManager.white70 : ColorManager.grey600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'بإنشاء حساب، أنت توافق على شروط الخدمة وسياسة الخصوصية',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? ColorManager.white70 : ColorManager.grey600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
