import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/auth/repository/auth_repository.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  final AuthRepository _repository = AuthRepository();
  final TextEditingController emailController = TextEditingController();

  Future<void> sendResetLink(BuildContext context) async {
    if (emailController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, context.tr('auth_email_required'));
      return;
    }

    emit(ForgotPasswordLoading());
    final result = await _repository.sendPasswordResetEmail(
      emailController.text.trim(),
    );

    result.fold(
      (failure) {
        emit(ForgotPasswordInitial());
        SnackBarHelper.showError(context, context.tr(failure.message));
      },
      (_) {
        emit(ForgotPasswordSuccess());
        SnackBarHelper.showSuccess(
          context,
          context.tr('auth_forgot_password_link_sent'),
        );
        // العودة لصفحة تسجيل الدخول
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
