import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/feature/auth/repository/auth_repository.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  final AuthRepository _repository = AuthRepository();
  final TextEditingController emailController = TextEditingController();

  Future<void> sendResetLink(BuildContext context) async {
    if (emailController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'يرجى إدخال البريد الإلكتروني');
      return;
    }

    emit(ForgotPasswordLoading());
    final result = await _repository.sendPasswordResetEmail(
      emailController.text.trim(),
    );

    result.fold(
      (failure) {
        emit(ForgotPasswordInitial());
        SnackBarHelper.showError(context, failure.message);
      },
      (_) {
        emit(ForgotPasswordSuccess());
        SnackBarHelper.showInfo(
          context,
          'إذا كان هذا البريد موجوداً، سنرسل لك رابط إعادة التعيين.',
        );
      },
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
