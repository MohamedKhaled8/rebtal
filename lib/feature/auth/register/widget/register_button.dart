import 'package:flutter/material.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rebtal/feature/auth/register/logic/register_cubit.dart';
import 'package:responsive_screen_master/responsive_screen_master.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';

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
    // We can rely on the Cubit validation instead,
    // or use the passed controllers if we really want to check here.
    // Given the props, we should use them.

    if (nameController.text.trim().isEmpty) {
      SnackBarHelper.showWarning(context, context.tr('auth_name_required'));
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      SnackBarHelper.showWarning(context, context.tr('auth_email_required'));
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      SnackBarHelper.showWarning(context, context.tr('auth_password_required'));
      return false;
    }
    return true;
  }
}

/// زر التحميل
class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 20.h,
      decoration: BoxDecoration(
        color: ColorManager.skyBlue0EA5E9,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.skyBlue0EA5E9.withOpacity(0.3),
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
            color: ColorManager.white,
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
    final registerCubit = context.read<RegisterCubit>();

    return Container(
      width: double.infinity,
      height: 20.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorManager.skyBlue0EA5E9, ColorManager.chaletActionBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorManager.skyBlue0EA5E9.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: ColorManager.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (validateForm(context)) {
              registerCubit.register();
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rocket_launch_rounded,
                  color: ColorManager.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  context.tr('auth_create_account_btn'),
                  style: TextStyle(
                    color: ColorManager.white,
                    fontSize: 15.sp,
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
