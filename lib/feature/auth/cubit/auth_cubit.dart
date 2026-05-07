import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/error/firebase_error_handler.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/helper/cash_helper.dart';
import 'package:rebtal/core/utils/dependency/get_it.dart';
import 'package:rebtal/core/utils/services/notification_service.dart';
import 'package:rebtal/core/utils/services/onesignal_service.dart';

import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepository) : super(AuthLoading()) {
    _initializeAuth();
  }

  final BaseAuthRepository authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  String? currentViewRole;

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

  /// Release/cold-start can emit a transient `null` user before persistence
  /// restores; keep this comfortably above typical slow devices + disk I/O.
  static const Duration _authGracePeriod = Duration(seconds: 15);
  Timer? _authGraceTimer;

  /// Initialize authentication by listening to auth state changes
  void _initializeAuth() {
    debugPrint('🔥 AuthCubit: Starting auth initialization');
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        debugPrint('🔥 AuthCubit: authStateChanges emitted user: ${user?.uid}');
        if (user != null) {
          // Cancel any pending grace timer - user is authenticated
          _authGraceTimer?.cancel();
          await _loadSavedViewMode();
          await _restoreUserFromFirestore(user);
        } else {
          // User is null - could be truly logged out or Firebase still restoring
          // Wait a grace period before concluding unauthenticated
          _authGraceTimer?.cancel();
          _authGraceTimer = Timer(_authGracePeriod, () {
            debugPrint(
              '🔥 AuthCubit: Grace period ended, emitting AuthUnauthenticated',
            );
            emit(AuthUnauthenticated());
          });
        }
      },
      onError: (error) {
        debugPrint('❌ Auth state stream error: $error');
        _authGraceTimer?.cancel();
        emit(AuthUnauthenticated());
      },
    );
  }

  /// Restore user data from Firestore after auth state is confirmed
  Future<void> _restoreUserFromFirestore(User firebaseUser) async {
    debugPrint(
      '🔥 AuthCubit: Restoring user from Firestore: ${firebaseUser.uid}',
    );
    try {
      DocumentSnapshot? doc;

      // 2. Parallelize Firestore lookups
      final futures = ["Users", "Owners", "Admin"].map((col) async {
        try {
          final d = await FirebaseFirestore.instance
              .collection(col)
              .doc(firebaseUser.uid)
              .get()
              .timeout(const Duration(seconds: 20));
          return d.exists ? d : null;
        } catch (e) {
          return null;
        }
      });

      final results = await Future.wait(futures);
      doc = results.firstWhere((d) => d != null, orElse: () => null);

      if (doc != null && doc.exists) {
        debugPrint('🔥 AuthCubit: Found user doc in Firestore');
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        debugPrint('🔥 AuthCubit: User role: ${user.role}');

        // ✅ Save role locally
        await getIt<CacheHelper>().saveData(key: 'userRole', value: user.role);
        // Keep OneSignal user alias synced for targeted pushes by userId.
        await OneSignalService().login(user.uid);
        await NotificationService().saveFCMToken(user.uid);

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

        debugPrint('🔥 AuthCubit: Emitting AuthSuccess');
        emit(AuthSuccess(user));
      } else {
        debugPrint('🔥 AuthCubit: No user doc found in Firestore');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('❌ AuthCubit: Error restoring user: $e');
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

      FirebaseErrorHandler.logError(e, context: 'RestoreUserFromFirestore');
    }
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

  @override
  Future<void> close() {
    _authGraceTimer?.cancel();
    _authStateSubscription?.cancel();
    return super.close();
  }

  // يمكنك إضافة method للحصول على UserModel كامل إذا needed
  UserModel? getCurrentUser() {
    return (state is AuthSuccess) ? (state as AuthSuccess).user : null;
  }

  // Reload user data from Firestore
  Future<void> reloadUserData() async {
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
            continue;
          }
        }

        if (doc != null && doc.exists) {
          final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);

          // Save role locally
          await getIt<CacheHelper>().saveData(
            key: 'userRole',
            value: user.role,
          );

          emit(AuthSuccess(user));
        }
      } catch (e) {
        debugPrint('Error reloading user data: $e');
      }
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
        try {
          await OneSignalService().logout();
        } catch (e) {
          debugPrint("OneSignal logout skipped: $e");
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
      await getIt<CacheHelper>().removeData(key: 'userRole');
      await getIt<CacheHelper>().removeData(
        key: 'currentViewRole',
      ); // ✅ Clear saved view mode
      currentViewRole = null; // ✅ Reset in-memory view mode
      emit(AuthUnauthenticated());
    } catch (e) {
      // Fallback for any unexpected errors
      debugPrint("Logout error: $e");
      emit(AuthInitial());
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    if (state is AuthSuccess) {
      final user = (state as AuthSuccess).user;
      final result = await authRepository.updateProfile(
        uid: user.uid,
        name: name,
        phone: phone,
        role: user.role,
        profileImageUrl: profileImageUrl,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (updatedUser) => emit(AuthSuccess(updatedUser)),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final result = await authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => null, // Success handled by UI showing snackbar
    );
  }
}
