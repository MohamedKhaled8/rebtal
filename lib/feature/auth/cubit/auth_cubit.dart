import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/error/firebase_error_handler.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/feature/auth/repository/auth_repository.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    _loadSavedViewMode(); // ✅ Load saved view mode first
    _checkCurrentUser(); // ✅ Then check current user
  }
  final AuthRepository authRepository = AuthRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool obscurePassword = true;
  String selectedRole = "user";

  String? currentViewRole;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(AuthInitial());
  }

  void setRole(String role) {
    selectedRole = role;
    emit(RoleChanged(role));
  }

  /// Returns the role that should be used for UI rendering
  String getCurrentRole() {
    if (currentViewRole != null) {
      return currentViewRole!;
    }

    if (state is AuthSuccess) {
      final authSuccess = state as AuthSuccess;
      final user = authSuccess.user;
      final originalRole = user.role;
      final normalizedRole = originalRole.toLowerCase().trim();

      // Initialize currentViewRole if not set
      currentViewRole = normalizedRole;
      return normalizedRole;
    }

    return 'guest';
  }

  /// Load saved view mode from local storage
  Future<void> _loadSavedViewMode() async {
    final savedViewMode = getIt<CacheHelper>().getDataString(
      key: 'currentViewRole',
    );
    if (savedViewMode != null && savedViewMode.isNotEmpty) {
      currentViewRole = savedViewMode;
      debugPrint('🔄 Loaded saved view mode: $currentViewRole');
    }
  }

  /// Toggles the view mode for Owners between 'owner' and 'user'
  void toggleViewMode() async {
    if (state is AuthSuccess) {
      final user = (state as AuthSuccess).user;
      final actualRole = user.role.toLowerCase().trim();

      // Only owners can switch modes
      if (actualRole == 'owner') {
        if (currentViewRole == 'owner') {
          currentViewRole = 'user';
        } else {
          currentViewRole = 'owner';
        }

        // ✅ Save the new view mode to local storage
        await getIt<CacheHelper>().saveData(
          key: 'currentViewRole',
          value: currentViewRole!,
        );
        debugPrint('💾 Saved view mode: $currentViewRole');

        // Emit success again to trigger UI rebuilds in listeners
        emit(AuthSuccess(user));
      }
    }
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

          // ✅ Skip email verification for admin
          final isAdmin = user.role.toLowerCase().trim() == 'admin';

          // ✅ Check if email is verified (skip for admin)
          if (!isAdmin) {
            await currentUser.reload(); // Ensure fresh status

            // Only redirect to verification if user just registered
            // Don't force verification on every app restart
            final isJustRegistered = getIt<CacheHelper>().getDataString(
              key: 'justRegistered',
            );

            if (!currentUser.emailVerified && isJustRegistered == 'true') {
              // ⚠️ User just registered but not verified -> Redirect to verification
              debugPrint('⚠️ User not verified, redirecting to verification');
              emit(AuthRegistrationSuccess(user: user, phoneNumber: ''));
              return;
            }

            // Clear the flag after first check
            await getIt<CacheHelper>().removeData(key: 'justRegistered');
          }

          // ✅ Save role locally
          await getIt<CacheHelper>().saveData(
            key: 'userRole',
            value: user.role,
          );

          // ✅ Restore saved view mode for owners
          if (user.role.toLowerCase().trim() == 'owner') {
            final savedViewMode = getIt<CacheHelper>().getDataString(
              key: 'currentViewRole',
            );
            if (savedViewMode != null && savedViewMode.isNotEmpty) {
              currentViewRole = savedViewMode;
              debugPrint('🔄 Restored view mode: $currentViewRole');
            } else {
              // Default to owner mode if no saved preference
              currentViewRole = 'owner';
            }
          }

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

      // ✅ Emit registration success to trigger OTP verification
      emit(AuthRegistrationSuccess(user: user, phoneNumber: phone.trim()));

      // ✅ Save role locally
      await getIt<CacheHelper>().saveData(key: 'userRole', value: user.role);

      // ✅ Mark as just registered to enforce email verification
      await getIt<CacheHelper>().saveData(key: 'justRegistered', value: 'true');
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

  // ✅ New method to verify email status manually
  Future<void> confirmEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload(); // Reload to get fresh data
        if (user.emailVerified) {
          // Find user in Firestore collections
          DocumentSnapshot? doc;
          for (String col in ["Users", "Owners", "Admin"]) {
            try {
              doc = await FirebaseFirestore.instance
                  .collection(col)
                  .doc(user.uid)
                  .get();
              if (doc.exists) {
                break;
              }
            } catch (e) {
              continue;
            }
          }

          if (doc != null && doc.exists) {
            final userModel = UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
            );
            // ✅ Save role locally
            await getIt<CacheHelper>().saveData(
              key: 'userRole',
              value: userModel.role,
            );

            // ✅ Clear the just registered flag
            await getIt<CacheHelper>().removeData(key: 'justRegistered');

            // ✅ Restore view mode for owners if needed
            if (userModel.role.toLowerCase().trim() == 'owner') {
              // ... handle view mode restoration if needed
            }

            emit(AuthSuccess(userModel));
          }
        }
      }
    } catch (e) {
      debugPrint("Error confirming email verification: $e");
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

      // ✅ Save FCM token to Firestore
      await NotificationService().saveFCMToken(user.uid);

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
      // ✅ Delete FCM token from Firestore before logout (Best effort, don't block)
      final currentUser = getCurrentUser();
      if (currentUser != null) {
        try {
          await NotificationService()
              .deleteFCMToken(currentUser.uid)
              .timeout(const Duration(seconds: 2));
        } catch (e) {
          debugPrint("FCM Token deletion skipped or timed out: $e");
        }
      }

      // Attempt Firebase SignOut
      try {
        await FirebaseAuth.instance.signOut().timeout(
          const Duration(seconds: 3),
        );
      } catch (e) {
        debugPrint("Firebase SignOut failed or timed out: $e");
      }

      // ✅ Always clear local data and navigate
      clearControllers();
      await getIt<CacheHelper>().removeData(key: 'userRole');
      await getIt<CacheHelper>().removeData(
        key: 'currentViewRole',
      ); // ✅ Clear saved view mode
      currentViewRole = null; // ✅ Reset in-memory view mode
      emit(AuthInitial());
    } catch (e) {
      // Fallback for any unexpected errors
      debugPrint("Logout error: $e");
      emit(AuthInitial());
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
