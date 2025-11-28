import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/error/firebase_error_handler.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/repository/auth_repository.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _checkCurrentUser(); // ✅ أول ما يتبني الكيوبت
  }
  final AuthRepository authRepository = AuthRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool obscurePassword = true;
  String selectedRole = "user";

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(AuthInitial());
  }

  void setRole(String role) {
    selectedRole = role;
    emit(RoleChanged(role));
  }

  String getCurrentRole() {
    if (state is AuthSuccess) {
      final authSuccess = state as AuthSuccess;
      final user = authSuccess.user;
      final originalRole = user.role;
      final normalizedRole = originalRole.toLowerCase().trim();

      return normalizedRole;
    }

    return 'guest';
  }

  Future<void> _checkCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        DocumentSnapshot? doc;
        for (String col in ["Users", "Owners", "Admin"]) {
          try {
            doc = await FirebaseFirestore.instance
                .collection(col)
                .doc(currentUser.uid)
                .get()
                .timeout(const Duration(seconds: 10));
            if (doc.exists) {
              break;
            }
          } catch (e) {
            // Continue to next collection if one fails
            continue;
          }
        }

        if (doc != null && doc.exists) {
          final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          // ✅ Save role locally
          await getIt<CacheHelper>().saveData(
            key: 'userRole',
            value: user.role,
          );
          emit(AuthSuccess(user));
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
        final isOffline = FirebaseErrorHandler.isOfflineError(e);

        if (isOffline) {
          emit(
            AuthOfflineWarning(
              'Working in offline mode. Some features may be limited.',
            ),
          );
        } else {
          emit(
            AuthFailure(
              errorMessage,
              errorCode: e is FirebaseException ? e.code : null,
              isRetryable: FirebaseErrorHandler.isRetryableError(e),
              isOffline: isOffline,
            ),
          );
        }

        FirebaseErrorHandler.logError(e, context: 'CheckCurrentUser');
      }
    } else {
      emit(AuthInitial());
    }
  }

  // يمكنك إضافة method للحصول على UserModel كامل إذا needed
  UserModel? getCurrentUser() {
    return (state is AuthSuccess) ? (state as AuthSuccess).user : null;
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    // Input validation
    if (name.trim().isEmpty) {
      emit(AuthValidationError("Please enter your name"));
      return;
    }
    if (email.trim().isEmpty) {
      emit(AuthValidationError("Please enter your email"));
      return;
    }
    if (password.isEmpty) {
      emit(AuthValidationError("Please enter a password"));
      return;
    }
    if (password.length < 6) {
      emit(AuthValidationError("Password must be at least 6 characters long"));
      return;
    }
    if (phone.trim().isEmpty) {
      emit(AuthValidationError("Please enter your phone number"));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await authRepository.register(
        email: email.trim(),
        password: password,
        name: name.trim(),
        role: role,
        phone: phone.trim(),
      );

      emit(AuthSuccess(user));
      // ✅ Save role locally
      await getIt<CacheHelper>().saveData(key: 'userRole', value: user.role);
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      final isOffline = FirebaseErrorHandler.isOfflineError(e);
      final isRetryable = FirebaseErrorHandler.isRetryableError(e);

      if (isOffline) {
        emit(
          AuthOfflineWarning(
            'Unable to create account. Please check your internet connection.',
          ),
        );
      } else {
        emit(
          AuthFailure(
            errorMessage,
            errorCode: e is FirebaseException || e is FirebaseAuthException
                ? (e as dynamic).code
                : null,
            isRetryable: isRetryable,
            isOffline: isOffline,
          ),
        );
      }

      FirebaseErrorHandler.logError(e, context: 'Register');
    }
  }

  Future<void> login({required String email, required String password}) async {
    // Input validation
    if (email.trim().isEmpty) {
      emit(AuthValidationError("Please enter your email"));
      return;
    }
    if (password.isEmpty) {
      emit(AuthValidationError("Please enter your password"));
      return;
    }

    emit(AuthLoading());

    try {
      // ✅ Special admin login handling
      if (email.trim().toLowerCase() == "admin@admin.com" &&
          password == "admin123") {
        try {
          // Sign in with FirebaseAuth
          final userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: email.trim(),
                password: password,
              )
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
            // If Firestore fails, create admin user
            if (FirebaseErrorHandler.isOfflineError(e)) {
              throw Exception('Cannot create admin account in offline mode');
            }
          }

          if (doc != null && doc.exists) {
            final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
            // ✅ Save role locally
            await getIt<CacheHelper>().saveData(
              key: 'userRole',
              value: user.role,
            );
            emit(AuthSuccess(user));
          } else {
            // Create admin user if not exists
            final adminUser = UserModel(
              uid: uid,
              name: "Admin",
              email: email.trim(),
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
            // ✅ Save role locally
            await getIt<CacheHelper>().saveData(
              key: 'userRole',
              value: adminUser.role,
            );
            emit(AuthSuccess(adminUser));
          }
          return;
        } catch (e) {
          final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
          final isOffline = FirebaseErrorHandler.isOfflineError(e);

          if (isOffline) {
            emit(
              AuthOfflineWarning(
                'Unable to sign in. Please check your internet connection.',
              ),
            );
          } else {
            emit(
              AuthFailure(
                errorMessage,
                errorCode: e is FirebaseException || e is FirebaseAuthException
                    ? (e as dynamic).code
                    : null,
                isRetryable: FirebaseErrorHandler.isRetryableError(e),
                isOffline: isOffline,
              ),
            );
          }

          FirebaseErrorHandler.logError(e, context: 'AdminLogin');
          return;
        }
      }

      // ✅ Regular users (Users & Owners)
      final user = await authRepository.login(
        email: email.trim(),
        password: password,
      );
      // ✅ Save role locally
      await getIt<CacheHelper>().saveData(key: 'userRole', value: user.role);
      emit(AuthSuccess(user));
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      final isOffline = FirebaseErrorHandler.isOfflineError(e);
      final isRetryable = FirebaseErrorHandler.isRetryableError(e);

      if (isOffline) {
        emit(
          AuthOfflineWarning(
            'Unable to sign in. Please check your internet connection.',
          ),
        );
      } else {
        emit(
          AuthFailure(
            errorMessage,
            errorCode: e is FirebaseException || e is FirebaseAuthException
                ? (e as dynamic).code
                : null,
            isRetryable: isRetryable,
            isOffline: isOffline,
          ),
        );
      }

      FirebaseErrorHandler.logError(e, context: 'Login');
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 5));
      clearControllers();
      // ✅ Clear role locally
      await getIt<CacheHelper>().removeData(key: 'userRole');
      emit(AuthInitial());
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      emit(
        AuthFailure(
          'Logout failed: $errorMessage',
          errorCode: e is FirebaseException ? e.code : null,
          isRetryable: FirebaseErrorHandler.isRetryableError(e),
        ),
      );
      FirebaseErrorHandler.logError(e, context: 'Logout');
    }
  }

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
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
