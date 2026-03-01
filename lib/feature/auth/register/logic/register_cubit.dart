import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/validators/auth_validator.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/utils/helper/helper_image.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
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

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
        emit(RegisterInitial()); // Rebuild UI to show image
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
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

    String? profileImageUrl;
    if (profileImage != null) {
      try {
        // Use HelperImage to upload
        profileImageUrl = await HelperImage().uploadToCloudinary(profileImage!);
      } catch (e) {
        emit(RegisterFailure("فشل رفع الصورة الشخصية: $e"));
        return;
      }
    }

    final result = await _registerUseCase.call(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      profileImageUrl: profileImageUrl,
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
        await getIt<CacheHelper>().saveData(
          key: 'justRegistered',
          value: 'true',
        );

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
      SnackBarHelper.showWarning(context, state.message);
      _isDialogShowing = false;
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
    SnackBarHelper.showError(context, errorMessage);
    _isDialogShowing = false;

    if (isRetryable && onRetry != null) {
      // For retryable errors, we just allow the user to click the button again
    }
  }

  Future<void> _showOfflineWarning(BuildContext context, String message) async {
    SnackBarHelper.showWarning(context, message);
    _isDialogShowing = false;
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
