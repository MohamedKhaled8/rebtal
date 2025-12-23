import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rebtal/core/utils/validators/phone_validator.dart';

class OtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  /// Sends OTP to the provided phone number
  /// Returns a Future that completes when OTP is sent or auto-verified
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerified,
    int timeoutSeconds = 60,
  }) async {
    try {
      // Format phone number to E.164
      final formattedPhone = PhoneValidator.formatToE164(phoneNumber);

      if (formattedPhone == null) {
        onError('Invalid phone number format');
        return;
      }

      debugPrint('📱 Sending OTP to: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: Duration(seconds: timeoutSeconds),

        // Auto-verification (Android only, instant verification)
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto-verification completed');
          if (onAutoVerified != null) {
            onAutoVerified(credential);
          } else {
            // Auto sign-in if no handler provided
            await _auth.signInWithCredential(credential);
          }
        },

        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.code} - ${e.message}');

          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later';
              break;
            case 'network-request-failed':
              errorMessage = 'Network error. Please check your connection';
              break;
            default:
              errorMessage = e.message ?? 'Failed to send OTP';
          }

          onError(errorMessage);
        },

        // Code sent successfully
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('📨 Code sent. Verification ID: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },

        // Auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
            '⏱️ Auto-retrieval timeout. Verification ID: $verificationId',
          );
          _verificationId = verificationId;
        },

        // Use resend token if available
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('❌ Send OTP error: $e');
      onError('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verifies the OTP code entered by user
  Future<UserCredential> verifyOtp({
    required String otpCode,
    String? verificationId,
  }) async {
    try {
      final vid = verificationId ?? _verificationId;

      if (vid == null) {
        throw FirebaseAuthException(
          code: 'missing-verification-id',
          message: 'Verification ID not found. Please resend OTP',
        );
      }

      debugPrint('🔐 Verifying OTP code...');

      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otpCode,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint('✅ OTP verified successfully');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification failed: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'invalid-verification-code':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Invalid OTP code. Please try again',
          );
        case 'session-expired':
          throw FirebaseAuthException(
            code: e.code,
            message: 'OTP expired. Please request a new code',
          );
        case 'invalid-verification-id':
          throw FirebaseAuthException(
            code: e.code,
            message: 'Invalid verification session. Please resend OTP',
          );
        default:
          rethrow;
      }
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      throw FirebaseAuthException(
        code: 'verification-failed',
        message: 'Failed to verify OTP: ${e.toString()}',
      );
    }
  }

  /// Resends OTP to the same phone number
  Future<void> resendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    debugPrint('🔄 Resending OTP...');

    await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified,
    );
  }

  /// Clears stored verification data
  void clear() {
    _verificationId = null;
    _resendToken = null;
  }

  /// Gets current verification ID
  String? get verificationId => _verificationId;
}
