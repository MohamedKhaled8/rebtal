import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rebtal/core/utils/error/firebase_error_handler.dart';
import 'package:rebtal/core/utils/model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Retry helper with exponential backoff
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
        // Exponential backoff: 2s, 4s, 8s
        await Future.delayed(_retryDelay * (1 << (attempt - 1)));
      }
    }
    throw Exception('Max retries exceeded');
  }

  // Register
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role, // user / owner / admin
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email format',
        );
      }

      // Validate password strength
      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password must be at least 6 characters',
        );
      }

      // 1- Create user in FirebaseAuth with retry
      final UserCredential userCredential = await _retryWithBackoff(() async {
        return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      });

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // ✅ Send Email Verification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      // ✅ Normalize role to lowercase
      final normalizedRole = role.toLowerCase().trim();

      // 2- Determine collection based on role
      late String collectionName;
      if (normalizedRole == "user") {
        collectionName = "Users";
      } else if (normalizedRole == "owner") {
        collectionName = "Owners";
      } else if (normalizedRole == "admin") {
        collectionName = "Admin";
      } else {
        collectionName = "Users"; // default
      }

      // 3- Build user model
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name.trim(),
        role: normalizedRole,
        password: password, // ⚠️ Note: Storing plain password (not secure)
        createdAt: DateTime.now(),
        phone: phone.trim(),
      );

      // 4- Save to Firestore with retry
      await _retryWithBackoff(() async {
        await _firestore
            .collection(collectionName)
            .doc(user.uid)
            .set(userModel.toMap());
      });

      return userModel;
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'Register');
      rethrow; // Let the cubit handle the error message
    }
  }

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email format',
        );
      }

      // 1- Sign in with FirebaseAuth with retry
      final UserCredential userCredential = await _retryWithBackoff(() async {
        return await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      });

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to sign in: User ID is null');
      }

      // 2- Find user in Firestore collections with retry
      DocumentSnapshot? foundDoc;

      await _retryWithBackoff(() async {
        for (String col in ["Users", "Owners", "Admin"]) {
          try {
            final snapshot = await _firestore.collection(col).doc(uid).get();
            if (snapshot.exists) {
              foundDoc = snapshot;
              break;
            }
          } catch (e) {
            // If one collection fails, try the next
            continue;
          }
        }
      });

      if (foundDoc == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User account not found in database',
        );
      }

      final doc = foundDoc!;
      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User account not found in database',
        );
      }

      final docData = doc.data();
      if (docData == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User data is null',
        );
      }

      return UserModel.fromMap(docData as Map<String, dynamic>);
    } catch (e) {
      FirebaseErrorHandler.logError(e, context: 'Login');
      rethrow; // Let the cubit handle the error message
    }
  }

  /// Validates email format
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }
}
