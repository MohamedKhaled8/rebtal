import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/constant/color_manager.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/validation/auth_validator.dart';
import 'package:rebtal/core/utils/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';

import 'package:rebtal/feature/auth/domain/usecases/register_usecase.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerUseCase) : super(RegisterInitial());

  final RegisterUseCase _registerUseCase;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool obscurePassword = true;
  String selectedRole = "user";

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(RegisterInitial()); // Rebuild UI to show/hide password
  }

  void setRole(String role) {
    selectedRole = role;
    emit(RegisterRoleChanged(role));
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final role = selectedRole;

    // Input validation
    final nameError = AuthValidator.validateName(name);
    if (nameError != null) {
      emit(RegisterValidationError(nameError));
      return;
    }

    final emailError = AuthValidator.validateEmail(email);
    if (emailError != null) {
      emit(RegisterValidationError(emailError));
      return;
    }

    final passwordError = AuthValidator.validatePassword(password);
    if (passwordError != null) {
      emit(RegisterValidationError(passwordError));
      return;
    }

    final phoneError = AuthValidator.validatePhone(phone);
    if (phoneError != null) {
      emit(RegisterValidationError(phoneError));
      return;
    }

    emit(RegisterLoading());

    final result = await _registerUseCase.call(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
    );

    result.fold(
      (failure) {
        final isOffline = failure is NetworkFailure;
        emit(
          RegisterFailure(
            failure.message,
            errorCode: failure.code,
            isRetryable: !isOffline,
            isOffline: isOffline,
          ),
        );
      },
      (user) async {
        // Store user data temporarily until email is verified (handled by AuthCubit essentially via shared prefs or similar mechanism if needed across app restart)
        // But here, we just need to pass user to success state so we can navigate to verification
        // Logic for "justRegistered" was in AuthCubit. We should duplicate it here or move it to a shared helper?
        // CacheHelper is fine.
        await getIt<CacheHelper>().saveData(
          key: 'justRegistered',
          value: 'true',
        );

        // We might want to let AuthCubit know about the pending user if it needs to hold it?
        // AuthCubit had `_pendingUserData`. This is important for "confirmEmailVerification" which saves to Firestore.
        // If we move confirm logic to EmailVerificationCubit, we need to pass this user data there.
        // Or we save it in AuthRepository? Or pass it via arguments?
        // AuthCubit typically held it in memory.
        // If we navigate to EmailVerificationScreen, we can pass the user object.

        emit(RegisterSuccess(user: user, phoneNumber: phone));
      },
    );
  }

  bool _isDialogShowing = false;

  void handleRegisterState(BuildContext context, RegisterState state) {
    if (_isDialogShowing) return;

    if (state is RegisterFailure) {
      _isDialogShowing = true;
      _showErrorDialog(
        context,
        state.error,
        isRetryable: state.isRetryable,
        onRetry: state.isRetryable
            ? () {
                _isDialogShowing = false;
                register();
              }
            : null,
      );
    } else if (state is RegisterValidationError) {
      _isDialogShowing = true;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'تحذير',
        text: state.message,
        confirmBtnText: 'حسناً',
        confirmBtnColor: ColorManager.blue2563EB,
      ).then((_) {
        _isDialogShowing = false;
      });
    } else if (state is RegisterOfflineWarning) {
      _isDialogShowing = true;
      _showOfflineWarning(context, state.message).then((_) {
        _isDialogShowing = false;
      });
    } else if (state is RegisterSuccess) {
      _isDialogShowing = false;
      // Notify AuthCubit about potential pending user if needed?
      // For now, let's assume we pass data via arguments to verification screen OR we set it in AuthCubit via a method.
      // The original code set `_pendingUserData` in AuthCubit.
      // We should probably expose a method in AuthCubit to set pending user data locally if we want to keep `confirmEmailVerification` there?
      // WAIT, user wanted `confirmEmailVerification` in `EmailVerificationCubit`.
      // So `RegisterCubit` produces a user. `EmailVerificationCubit` needs that user to save it later.
      // We can pass it as argument to the route!
      Navigator.of(context).pushNamed(
        Routes.emailVerification,
        arguments:
            state.user, // Pass the whole user object instead of just email
      );
    }
  }

  void _showErrorDialog(
    BuildContext context,
    String errorMessage, {
    bool isRetryable = false,
    VoidCallback? onRetry,
  }) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'خطأ',
      text: errorMessage,
      confirmBtnText: isRetryable ? 'إعادة المحاولة' : 'حسناً',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        _isDialogShowing = false;
        if (isRetryable && onRetry != null) {
          Future.delayed(const Duration(milliseconds: 300), onRetry);
        }
      },
      onCancelBtnTap: () {
        _isDialogShowing = false;
      },
      showCancelBtn: isRetryable,
      cancelBtnText: 'إلغاء',
      confirmBtnColor: const Color(0xFF2563EB),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  Future<void> _showOfflineWarning(BuildContext context, String message) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: 'مشكلة الاتصال',
      text: message,
      confirmBtnText: 'حسناً',
      confirmBtnColor: const Color(0xFF2563EB),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    return super.close();
  }
}
