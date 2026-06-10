import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rebtal/core/utils/helper/image_clean/helper_image_contract.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:rebtal/core/utils/services/device_info_service.dart';
import 'package:rebtal/feature/auth/domain/usecases/register_usecase.dart';
import 'package:rebtal/core/utils/validators/auth_validator.dart';
import 'package:rebtal/core/utils/localization/translation_extension.dart';

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
  String? selectedOwnerType; // 'direct_owner' or 'broker'

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(RegisterInitial()); // Rebuild UI to show/hide password
  }

  void setRole(String role) {
    selectedRole = role;
    // Reset owner type when switching away from owner
    if (role != 'owner') selectedOwnerType = null;
    emit(RegisterRoleChanged(role));
  }

  void setOwnerType(String ownerType) {
    selectedOwnerType = ownerType;
    emit(RegisterRoleChanged(selectedRole));
  }

  File? profileImage;
  File? idCardImage;
  final ImagePicker _picker = ImagePicker();

  void setProfileImage(File? file) {
    if (file != null) {
      profileImage = file;
      emit(RegisterInitial());
    }
  }

  void setIdCardImage(File? file) {
    if (file != null) {
      idCardImage = file;
      emit(RegisterInitial());
    }
  }

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

  /// Used by register UI when wrapped in a `Form`.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final role = selectedRole;

    // NOTE: Register UI uses custom `WanderlyField` widgets, so there is no `Form`
    // and `formKey.currentState?.validate()` would always be false.
    // Validate manually here instead.

    // If the UI is using a Form (e.g. CustomInputField/TextFormField),
    // trigger it first to show red borders and per-field validation.
    // (Safe even if no Form exists.)
    final isFormValid = formKey.currentState?.validate() ?? true;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty) {
      emit(RegisterValidationError("auth_fill_empty_fields"));
      return;
    }

    if (!isFormValid) {
      emit(RegisterValidationError("auth_fill_fields_correctly"));
      return;
    }

    // Lightweight format checks (we keep app-specific Arabic messages).
    if (AuthValidator.validateEmail(email) != null ||
        AuthValidator.validatePassword(password) != null ||
        AuthValidator.validatePhone(phone) != null) {
      emit(RegisterValidationError("auth_fill_fields_correctly"));
      return;
    }

    // Input validation for images
    if (profileImage == null) {
      emit(RegisterValidationError("auth_profile_image_required"));
      return;
    }

    // Validate owner type when role is owner
    if (selectedRole == 'owner' && (selectedOwnerType == null || selectedOwnerType!.isEmpty)) {
      emit(RegisterValidationError("auth_owner_type_required"));
      return;
    }

    emit(RegisterLoading());

    String? profileImageUrl;
    String? idCardUrl;

    if (profileImage != null) {
      try {
        profileImageUrl = await getIt<HelperImageContract>().uploadToCloudinary(
          profileImage!,
        );
      } catch (e) {
        emit(RegisterFailure("فشل رفع الصورة الشخصية: $e"));
        return;
      }
    }

    if (idCardImage != null) {
      try {
        idCardUrl = await getIt<HelperImageContract>().uploadToCloudinary(
          idCardImage!,
        );
      } catch (e) {
        emit(RegisterFailure("فشل رفع صورة البطاقة: $e"));
        return;
      }
    }

    final deviceTypeStr = await DeviceInfoService.getDeviceType();

    final result = await _registerUseCase.call(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      profileImageUrl: profileImageUrl,
      idCardUrl: idCardUrl,
      deviceType: deviceTypeStr,
      ownerType: role == 'owner' ? selectedOwnerType : null,
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
        emit(RegisterSuccess(user: user, phoneNumber: phone));
      },
    );
  }

  bool _isDialogShowing = false;

  Future<void> handleRegisterState(BuildContext context, RegisterState state) async {
    if (_isDialogShowing) return;

    if (state is RegisterFailure) {
      _isDialogShowing = true;
      _showErrorDialog(
        context,
        context.tr(state.error),
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
      SnackBarHelper.showWarning(context, context.tr(state.message));
      _isDialogShowing = false;
    } else if (state is RegisterOfflineWarning) {
      _isDialogShowing = true;
      _showOfflineWarning(context, context.tr(state.message)).then((_) {
        _isDialogShowing = false;
      });
    } else if (state is RegisterSuccess) {
      _isDialogShowing = false;
      // Save role locally
      await getIt<CacheHelper>().saveData(
        key: 'userRole',
        value: state.user.role,
      );

      if (!context.mounted) return;

      // Reload auth state
      try {
        final authCubit = context.read<AppCubit>().authCubit;
        await authCubit.reloadUserData();
      } catch (e) {
        debugPrint('Failed to reload AuthCubit: $e');
      }

      if (!context.mounted) return;

      // Show success and navigate to main screen
      SnackBarHelper.showSuccess(
        context,
        context.tr('auth_register_success'),
      );

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.bottomNavigationBarScreen,
          (route) => false,
        );
      });
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
