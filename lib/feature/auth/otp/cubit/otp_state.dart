part of 'otp_cubit.dart';

abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpSending extends OtpState {}

class OtpSent extends OtpState {
  final String verificationId;
  final String phoneNumber;

  OtpSent({required this.verificationId, required this.phoneNumber});
}

class OtpVerifying extends OtpState {}

class OtpVerified extends OtpState {
  final String uid;
  final String phoneNumber;

  OtpVerified({required this.uid, required this.phoneNumber});
}

class OtpError extends OtpState {
  final String message;
  final bool canResend;

  OtpError({required this.message, this.canResend = true});
}

class OtpResendAvailable extends OtpState {
  final int remainingSeconds;

  OtpResendAvailable(this.remainingSeconds);
}

class OtpAutoVerified extends OtpState {
  final String uid;
  final String phoneNumber;

  OtpAutoVerified({required this.uid, required this.phoneNumber});
}
