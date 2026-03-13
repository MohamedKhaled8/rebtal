import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/Router/routes.dart';
import 'package:rebtal/core/app/cubit/app_cubit.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/helper/snack_bar_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rebtal/core/utils/error/firebase_error_handler.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/feature/auth/domain/usecases/login_usecase.dart';
import 'package:rebtal/core/utils/validators/auth_validator.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginUseCase) : super(LoginInitial());

  final LoginUseCase _loginUseCase;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(LoginInitial()); // Refresh UI
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Input validation
    final emailError = AuthValidator.validateEmail(email);
    if (emailError != null) {
      emit(LoginValidationError(emailError));
      return;
    }

    final passwordError = AuthValidator.validatePassword(password);
    if (passwordError != null) {
      emit(LoginValidationError(passwordError));
      return;
    }

    emit(LoginLoading());

    try {
      // ✅ Special admin login handling
      if (email.toLowerCase() == "admin@admin.com" && password == "admin123") {
        await _loginAdmin(email, password);
        return;
      }

      // ✅ Regular users (Users & Owners)
      final result = await _loginUseCase
          .call(email: email.trim(), password: password)
          .timeout(const Duration(seconds: 20));

      result.fold(
        (failure) {
          final isOffline = failure is NetworkFailure;
          if (isOffline) {
            emit(
              LoginOfflineWarning(
                'Unable to sign in. Please check your internet connection.',
              ),
            );
          } else {
            emit(
              LoginFailure(
                failure.message,
                errorCode: failure.code,
                // Auth errors (wrong password, etc.) are NOT retryable with same credentials
                isRetryable: false,
                isOffline: isOffline,
              ),
            );
          }
        },
        (user) async {
          await getIt<CacheHelper>().saveData(
            key: 'userRole',
            value: user.role,
          );
          await NotificationService().saveFCMToken(user.uid);

          debugPrint('🔥 LoginCubit: Login success for ${user.uid}');

          // Note: AuthCubit reload should be handled by the UI listener
          // context.read<AuthCubit>().reloadUserData() when state is Success

          emit(LoginSuccess(user));
        },
      );
    } catch (e) {
      _handleLoginError(e);
    }
  }

  Future<void> _loginAdmin(String email, String password) async {
    try {
      // Sign in with FirebaseAuth
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 10));

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to get user ID');
      }

      // Read from Firestore with timeout
      DocumentSnapshot? doc;
      try {
        doc = await FirebaseFirestore.instance
            .collection("Admin")
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        if (FirebaseErrorHandler.isOfflineError(e)) {
          throw Exception('Cannot create admin account in offline mode');
        }
      }

      if (doc != null && doc.exists) {
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        await getIt<CacheHelper>().saveData(key: 'userRole', value: user.role);

        emit(LoginSuccess(user));
      } else {
        // Create admin user if not exists
        final adminUser = UserModel(
          uid: uid,
          name: "Admin",
          email: email,
          role: "admin",
          phone: "",
          password: password,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection("Admin")
            .doc(uid)
            .set(adminUser.toMap())
            .timeout(const Duration(seconds: 10));
        await getIt<CacheHelper>().saveData(
          key: 'userRole',
          value: adminUser.role,
        );

        emit(LoginSuccess(adminUser));
      }
    } catch (e) {
      _handleLoginError(e);
    }
  }

  void _handleLoginError(dynamic e) {
    final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
    final isOffline = FirebaseErrorHandler.isOfflineError(e);

    if (isOffline) {
      emit(
        LoginOfflineWarning(
          'Unable to sign in. Please check your internet connection.',
        ),
      );
    } else {
      emit(
        LoginFailure(
          errorMessage,
          errorCode: e is FirebaseException || e is FirebaseAuthException
              ? (e as dynamic).code
              : null,
          isRetryable: FirebaseErrorHandler.isRetryableError(e),
          isOffline: isOffline,
        ),
      );
    }
    FirebaseErrorHandler.logError(e, context: 'Login');
  }

  bool _isDialogShowing = false;
  bool _isNavigating = false;
  bool _successMessageShown = false;

  void handleLoginState(BuildContext context, LoginState state) {
    if (_isDialogShowing) return;

    if (state is LoginFailure) {
      _isDialogShowing = true;
      _showErrorDialog(
        context,
        state.error,
        isRetryable: state.isRetryable,
        onRetry: state.isRetryable
            ? () {
                _isDialogShowing = false;
                login();
              }
            : null,
      );
    } else if (state is LoginValidationError) {
      _isDialogShowing = true;
      SnackBarHelper.showWarning(context, state.message);
      _isDialogShowing = false;
    } else if (state is LoginOfflineWarning) {
      _isDialogShowing = true;
      _showOfflineWarning(context, state.message).then((_) {
        _isDialogShowing = false;
      });
    } else if (state is LoginSuccess) {
      _isDialogShowing = false;

      // Prevent multiple navigations and success messages
      if (_isNavigating || _successMessageShown) return;
      _isNavigating = true;
      _successMessageShown = true;

      // Reload AuthCubit data since we essentially logged in
      try {
        context.read<AppCubit>().authCubit.reloadUserData();
      } catch (e) {
        debugPrint('Failed to reload AuthCubit: $e');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!Navigator.of(context).mounted) {
          _isNavigating = false;
          _successMessageShown = false;
          return;
        }

        // Show success message first - only once
        SnackBarHelper.showSuccess(
          context,
          'تم تسجيل الدخول بنجاح',
          icon: Icons.check_circle,
        );

        // Wait a bit to ensure role is saved to cache and show message
        await Future.delayed(const Duration(milliseconds: 200));

        // Get role from state and cache (fallback)
        final userRole = state.user.role.toLowerCase().trim();
        String? cachedRole;

        // Try to get cached role multiple times if needed
        for (int i = 0; i < 3; i++) {
          cachedRole = getIt<CacheHelper>()
              .getDataString(key: 'userRole')
              ?.toLowerCase()
              .trim();

          if (cachedRole != null && cachedRole.isNotEmpty) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Determine final role - prioritize admin if either source says admin
        final finalRole = (userRole == 'admin' || cachedRole == 'admin')
            ? 'admin'
            : (userRole.isNotEmpty ? userRole : (cachedRole ?? 'user'));

        // Wait a bit more to let user see the success message
        await Future.delayed(const Duration(milliseconds: 1200));

        if (!Navigator.of(context).mounted) {
          _isNavigating = false;
          _successMessageShown = false;
          return;
        }

        // Navigate based on role - only once
        try {
          if (finalRole == 'admin') {
            Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
          } else {
            Navigator.pushReplacementNamed(
              context,
              Routes.bottomNavigationBarScreen,
            );
          }
        } catch (e) {
          debugPrint('Navigation error: $e');
        } finally {
          // Reset flags after a delay to allow for navigation
          Future.delayed(const Duration(milliseconds: 500), () {
            _isNavigating = false;
            _successMessageShown = false;
          });
        }
      });
    } else {
      _isDialogShowing = false;
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
      // In a real app, you might want more complex retry logic, but per user request, we use SnackBarHelper
    }
  }

  Future<void> _showOfflineWarning(BuildContext context, String message) async {
    SnackBarHelper.showWarning(context, message);
    _isDialogShowing = false;
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
