import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';
import 'package:rebtal/feature/auth/forgot_password/logic/forgot_password_cubit.dart';
import 'package:rebtal/feature/auth/widget/auth_wanderly_scaffold.dart';
import 'package:rebtal/feature/auth/widget/wanderly_fields.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(),
      child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
        builder: (context, state) {
          final cubit = context.read<ForgotPasswordCubit>();
          final isLoading = state is ForgotPasswordLoading;

          return AuthWanderlyScaffold(
            appName: 'Rebtal',
            brandSubtitle: context.tr('auth_brand_subtitle'),
            primaryColor: ColorsManager.blue2563EB,
            title: context.tr('auth_forgot_password_title'),
            subtitle: context.tr('auth_forgot_password_desc'),
            form: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WanderlyField(
                  controller: cubit.emailController,
                  label: context.tr('auth_email'),
                  hint: context.tr('auth_enter_email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                WanderlyPrimaryButton(
                  label: context.tr('auth_send_code'),
                  primaryColor: ColorsManager.blue2563EB,
                  isLoading: isLoading,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    cubit.sendResetLink(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
