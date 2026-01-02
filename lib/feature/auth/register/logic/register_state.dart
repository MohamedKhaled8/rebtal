part of 'register_cubit.dart';

// Since this is a part file, imports should handle themselves via the parent usually,
// BUT if the parent has the import, the part file can see classes if they are in the parent.
// However, the previous error `Undefined class 'UserModel'` suggests it might not be visible or I need to import it in the parent `register_cubit.dart` (which I did in Step 48).
// Wait, `register_state.dart` is `part of 'register_cubit.dart'`.
// If `register_cubit.dart` imports `UserModel`, `register_state.dart` should see it.
// Let's check if I imported it in `register_cubit.dart`.
// Yes: `import 'package:rebtal/core/utils/model/user_model.dart';` was added.
// Maybe the analyzer is just slow or confused.
// OR, `register_state.dart` needs ITSELF to have the import if it's not strictly depending on the parent's imports (Dart behavior varies slightly depending on how it's analyzed sometimes, but usually part files see what parent sees).
// Actually, it's better if `register_state.dart` doesn't have imports if it's a part file.
// Let's assume the previous error was because I hadn't updated `register_cubit.dart` yet when the state file was written? No, state was written first.
// Ah, the state file was written in Step 46. `register_cubit.dart` was updated in Step 48.
// The lint error came from Step 48's output which showed lints "related to your recent edits".
// So `UserModel` should be available now.

// I will verify `register_cubit.dart` imports again.

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserModel user;
  final String phoneNumber;
  RegisterSuccess({required this.user, required this.phoneNumber});
}

class RegisterFailure extends RegisterState {
  final String error;
  final String? errorCode;
  final bool isRetryable;
  final bool isOffline;

  RegisterFailure(
    this.error, {
    this.errorCode,
    this.isRetryable = false,
    this.isOffline = false,
  });
}

class RegisterValidationError extends RegisterState {
  final String message;
  RegisterValidationError(this.message);
}

class RegisterOfflineWarning extends RegisterState {
  final String message;
  RegisterOfflineWarning(this.message);
}

class RegisterRoleChanged extends RegisterState {
  final String role;
  RegisterRoleChanged(this.role);
}
