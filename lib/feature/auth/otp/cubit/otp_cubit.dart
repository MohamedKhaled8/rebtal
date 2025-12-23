import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rebtal/core/utils/services/otp_service.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpInitial());

  final OtpService _otpService = OtpService();

  Timer? _resendTimer;
  int _resendCountdown = 60;
  String? _currentPhoneNumber;
  String? _currentVerificationId;

  /// Sends OTP to the provided phone number
  Future<void> sendOtp(String phoneNumber) async {
    emit(OtpSending());
    _currentPhoneNumber = phoneNumber;

    await _otpService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _currentVerificationId = verificationId;
        emit(OtpSent(verificationId: verificationId, phoneNumber: phoneNumber));
        _startResendTimer();
      },
      onError: (error) {
        emit(OtpError(message: error));
      },
      onAutoVerified: (credential) async {
        // Handle auto-verification (Android only)
        try {
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          emit(
            OtpAutoVerified(
              uid: userCredential.user!.uid,
              phoneNumber: phoneNumber,
            ),
          );
        } catch (e) {
          emit(OtpError(message: 'Auto-verification failed: ${e.toString()}'));
        }
      },
    );
  }

  /// Verifies the OTP code entered by user
  Future<void> verifyOtp(String otpCode) async {
    if (otpCode.length != 6) {
      emit(OtpError(message: 'Please enter a 6-digit code'));
      return;
    }

    emit(OtpVerifying());

    try {
      final userCredential = await _otpService.verifyOtp(
        otpCode: otpCode,
        verificationId: _currentVerificationId,
      );

      if (userCredential.user != null) {
        _cancelResendTimer();
        emit(
          OtpVerified(
            uid: userCredential.user!.uid,
            phoneNumber: _currentPhoneNumber ?? '',
          ),
        );
      } else {
        emit(OtpError(message: 'Verification failed. Please try again'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP code. Please try again';
          break;
        case 'session-expired':
          errorMessage = 'OTP expired. Please request a new code';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification session. Please resend OTP';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed';
      }

      emit(OtpError(message: errorMessage));
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      emit(OtpError(message: 'Failed to verify OTP. Please try again'));
    }
  }

  /// Resends OTP to the current phone number
  Future<void> resendOtp() async {
    if (_currentPhoneNumber == null) {
      emit(OtpError(message: 'Phone number not found'));
      return;
    }

    _cancelResendTimer();
    emit(OtpSending());

    await _otpService.resendOtp(
      phoneNumber: _currentPhoneNumber!,
      onCodeSent: (verificationId) {
        _currentVerificationId = verificationId;
        emit(
          OtpSent(
            verificationId: verificationId,
            phoneNumber: _currentPhoneNumber!,
          ),
        );
        _startResendTimer();
      },
      onError: (error) {
        emit(OtpError(message: error));
      },
      onAutoVerified: (credential) async {
        try {
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          emit(
            OtpAutoVerified(
              uid: userCredential.user!.uid,
              phoneNumber: _currentPhoneNumber!,
            ),
          );
        } catch (e) {
          emit(OtpError(message: 'Auto-verification failed: ${e.toString()}'));
        }
      },
    );
  }

  /// Starts the resend countdown timer (60 seconds)
  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendCountdown--;

      if (_resendCountdown <= 0) {
        timer.cancel();
        emit(OtpResendAvailable(0));
      } else {
        emit(OtpResendAvailable(_resendCountdown));
      }
    });
  }

  /// Cancels the resend timer
  void _cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  /// Gets remaining seconds for resend
  int get remainingSeconds => _resendCountdown;

  /// Checks if resend is available
  bool get canResend => _resendCountdown <= 0;

  @override
  Future<void> close() {
    _cancelResendTimer();
    _otpService.clear();
    return super.close();
  }
}
