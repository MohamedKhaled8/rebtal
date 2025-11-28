import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/config/space.dart';

import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';

import 'package:rebtal/feature/auth/register/widget/role_selector.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

import 'custom_input_field.dart'; // الكومبوننت اللي عملناه قبل كده

/// GlassmorPhicCard بعد ما شيلنا زرار التسجيل من هنا
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
    final cubit = context.read<AuthCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header inside card
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join thousands of travelers finding their perfect chalet',
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),

        /// Form fields
        CustomInputField(
          controller: cubit.nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        verticalSpace(2),

        CustomInputField(
          controller: cubit.emailController,
          label: 'Email Address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        verticalSpace(2),

        CustomInputField(
          controller: cubit.phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        verticalSpace(2),

        CustomInputField(
          controller: cubit.passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: togglePasswordVisibility,
          ),
        ),
        verticalSpace(2),

        /// Role selector
        RoleSelector(
          selectedRole: cubit.selectedRole,
          onChanged: (role) => cubit.setRole(role),
        ),
        const SizedBox(height: 32),

        /// Terms and conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'By creating an account, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// Divider
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
