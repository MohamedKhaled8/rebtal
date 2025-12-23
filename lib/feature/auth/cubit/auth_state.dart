// auth_state.dart
part of 'auth_cubit.dart';

// ✅ Auth States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

class AuthRegistrationSuccess extends AuthState {
  final UserModel user;
  final String phoneNumber;

  AuthRegistrationSuccess({required this.user, required this.phoneNumber});
}

/// Comprehensive error state with error type and retry capability
class AuthFailure extends AuthState {
  final String error;
  final String? errorCode;
  final bool isRetryable;
  final bool isOffline;

  AuthFailure(
    this.error, {
    this.errorCode,
    this.isRetryable = false,
    this.isOffline = false,
  });
}

class AuthValidationError extends AuthState {
  final String message;
  AuthValidationError(this.message);
}

class AuthNavigate extends AuthState {
  final String route;
  AuthNavigate(this.route);
}

class RoleChanged extends AuthState {
  final String role;
  RoleChanged(this.role);
}

/// Network/Offline warning state
class AuthOfflineWarning extends AuthState {
  final String message;
  AuthOfflineWarning(this.message);
}
