import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rebtal/core/utils/error/failure.dart';
import 'package:rebtal/core/utils/error/firebase_error_handler.dart';
import 'package:rebtal/core/utils/model/user_model.dart';
import 'package:rebtal/core/utils/validators/auth_validator.dart';

import 'package:rebtal/feature/auth/repository/base_auth_repository.dart';

class AuthRepository implements BaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (!FirebaseErrorHandler.isRetryableError(e) ||
            attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(_retryDelay * (1 << (attempt - 1)));
      }
    }
    throw Exception('Max retries exceeded');
  }

  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final emailError = AuthValidator.validateEmail(email);
      if (emailError != null) {
        return Left(ValidationFailure(emailError));
      }

      final passwordError = AuthValidator.validatePassword(password);
      if (passwordError != null) {
        return Left(ValidationFailure(passwordError));
      }

      final UserCredential userCredential = await _retryWithBackoff(() async {
        return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      });

      final user = userCredential.user;
      if (user == null) {
        return Left(ServerFailure('فشل إنشاء الحساب'));
      }

      // Wait a bit to ensure user is fully created before sending verification
      await Future.delayed(const Duration(milliseconds: 500));

      if (!user.emailVerified) {
        try {
          debugPrint(
            '📧 Attempting to send email verification to: ${user.email}',
          );
          await user.sendEmailVerification();
          debugPrint(
            '✅ Email verification sent successfully to: ${user.email}',
          );
        } catch (e) {
          // Log but don't fail registration if email sending fails
          FirebaseErrorHandler.logError(
            e,
            context: 'SendEmailVerificationDuringRegister',
          );
          debugPrint('❌ Failed to send email verification: $e');
          if (e is FirebaseAuthException) {
            debugPrint('❌ Firebase Auth Error Code: ${e.code}');
            debugPrint('❌ Firebase Auth Error Message: ${e.message}');
          }
        }
      } else {
        debugPrint('ℹ️ User email is already verified: ${user.email}');
      }

      // Don't save to Firestore yet - wait for email verification
      // Return UserModel for temporary use only
      final normalizedRole = role.toLowerCase().trim();
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name.trim(),
        role: normalizedRole,
        password: password,
        createdAt: DateTime.now(),
        phone: phone.trim(),
      );

      return Right(userModel);
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'Register');
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      final isOffline = FirebaseErrorHandler.isOfflineError(e);

      if (isOffline) {
        return Left(NetworkFailure('تحقق من اتصالك بالإنترنت'));
      }
      return Left(AuthFailure(errorMessage));
    }
  }

  Future<Either<Failure, UserModel>> saveUserToFirestore(
    UserModel userModel,
  ) async {
    try {
      late String collectionName;
      final normalizedRole = userModel.role.toLowerCase().trim();
      if (normalizedRole == "user") {
        collectionName = "Users";
      } else if (normalizedRole == "owner") {
        collectionName = "Owners";
      } else if (normalizedRole == "admin") {
        collectionName = "Admin";
      } else {
        collectionName = "Users";
      }

      await _retryWithBackoff(() async {
        await _firestore
            .collection(collectionName)
            .doc(userModel.uid)
            .set(userModel.toMap());
      });

      return Right(userModel);
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'SaveUserToFirestore');
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      final isOffline = FirebaseErrorHandler.isOfflineError(e);

      if (isOffline) {
        return Left(NetworkFailure('تحقق من اتصالك بالإنترنت'));
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final emailError = AuthValidator.validateEmail(email);
      if (emailError != null) {
        return Left(ValidationFailure(emailError));
      }

      final UserCredential userCredential = await _retryWithBackoff(() async {
        return await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      });

      final uid = userCredential.user?.uid;
      if (uid == null) {
        return Left(ServerFailure('فشل تسجيل الدخول'));
      }

      DocumentSnapshot? foundDoc;

      await _retryWithBackoff(() async {
        final futures = ["Users", "Owners", "Admin"].map((col) async {
          try {
            final doc = await _firestore.collection(col).doc(uid).get();
            return doc.exists ? doc : null;
          } catch (e) {
            return null;
          }
        });

        final results = await Future.wait(futures);
        foundDoc = results.firstWhere((doc) => doc != null, orElse: () => null);
      });

      if (foundDoc == null || !foundDoc!.exists) {
        return Left(AuthFailure('الحساب غير موجود'));
      }

      final docData = foundDoc!.data();
      if (docData == null) {
        return Left(ServerFailure('بيانات المستخدم غير موجودة'));
      }

      return Right(UserModel.fromMap(docData as Map<String, dynamic>));
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'Login');
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      final isOffline = FirebaseErrorHandler.isOfflineError(e);

      if (isOffline) {
        return Left(NetworkFailure('تحقق من اتصالك بالإنترنت'));
      }
      return Left(AuthFailure(errorMessage));
    }
  }

  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      final emailError = AuthValidator.validateEmail(email);
      if (emailError != null) {
        return Left(ValidationFailure(emailError));
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'SendPasswordReset');
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      final isOffline = FirebaseErrorHandler.isOfflineError(e);

      if (isOffline) {
        return Left(NetworkFailure('تحقق من اتصالك بالإنترنت'));
      }
      return Left(AuthFailure(errorMessage));
    }
  }

  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ No current user found');
        return Left(AuthFailure('لا يوجد مستخدم مسجل دخول'));
      }

      debugPrint('📧 Attempting to send email verification to: ${user.email}');
      debugPrint('📧 User UID: ${user.uid}');
      debugPrint('📧 Email verified status: ${user.emailVerified}');

      // Wait a bit to ensure user is fully created
      await Future.delayed(const Duration(milliseconds: 500));

      await user.sendEmailVerification();
      debugPrint('✅ Email verification sent successfully to: ${user.email}');
      return const Right(null);
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'SendEmailVerification');
      final errorMessage = FirebaseErrorHandler.getErrorMessage(e);
      debugPrint('❌ Failed to send email verification: $e');
      if (e is FirebaseAuthException) {
        debugPrint('❌ Firebase Auth Error Code: ${e.code}');
        debugPrint('❌ Firebase Auth Error Message: ${e.message}');
      }
      return Left(AuthFailure(errorMessage));
    }
  }
}
