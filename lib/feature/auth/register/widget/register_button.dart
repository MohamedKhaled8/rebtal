import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rebtal/feature/auth/cubit/auth_cubit.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class RegisterActionButton extends StatelessWidget {
  final bool isTablet;
  final bool isLoading;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final String selectedRole;

  const RegisterActionButton({
    super.key,
    required this.isTablet,
    required this.isLoading,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingButton()
        : RegisterButton(
          

            selectedRole: selectedRole,
            validateForm: _validateForm,
          );
  }

  /// التحقق من الفورم
  bool _validateForm(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    if (authCubit.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    if (authCubit.emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    if (authCubit.passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    return true;
  }
}

/// زر التحميل
class LoadingButton extends StatelessWidget {

  const LoadingButton({super.key,});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height:20.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}

class RegisterButton extends StatelessWidget {
  final String selectedRole;
  final bool Function(BuildContext) validateForm;

  const RegisterButton({
    super.key,
    required this.selectedRole,
    required this.validateForm,
  });

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return Container(
      width: double.infinity,
      height:20.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (validateForm(context)) {
              authCubit.register(
                email: authCubit.emailController.text.trim(),
                password: authCubit.passwordController.text.trim(),
                name: authCubit.nameController.text.trim(),
                phone: authCubit.phoneController.text.trim(),
                role: selectedRole.toLowerCase(),
              );
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Create My Account',
                  style: TextStyle(
                    color: Colors.white,
                  fontSize:15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
