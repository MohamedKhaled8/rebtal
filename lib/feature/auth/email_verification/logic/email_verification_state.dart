part of 'email_verification_cubit.dart';

abstract class EmailVerificationState {}

class EmailVerificationInitial extends EmailVerificationState {}

class EmailVerificationChecking extends EmailVerificationState {}

class EmailVerificationVerified extends EmailVerificationState {}

class EmailVerificationResendCooldown extends EmailVerificationState {
  final int countdown;
  EmailVerificationResendCooldown(this.countdown);
}

class EmailVerificationCanResend extends EmailVerificationState {}

class EmailVerificationEmailSent extends EmailVerificationState {}

class EmailVerificationError extends EmailVerificationState {
  final String message;
  EmailVerificationError(this.message);
}

