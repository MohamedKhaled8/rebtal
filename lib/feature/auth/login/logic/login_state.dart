part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserModel user;
  LoginSuccess(this.user);
}

class LoginFailure extends LoginState {
  final String error; // Renaming message to error to match usage
  final String? errorCode;
  final bool isRetryable;
  final bool isOffline;

  LoginFailure(
    this.error, {
    this.errorCode,
    this.isRetryable = false,
    this.isOffline = false,
  });
}

class LoginValidationError extends LoginState {
  final String message;
  LoginValidationError(this.message);
}

class LoginOfflineWarning extends LoginState {
  final String message;
  LoginOfflineWarning(this.message);
}
