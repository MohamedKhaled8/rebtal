import 'package:firebase_auth/firebase_auth.dart';

/// Centralized error handler for Firebase Authentication and Firestore errors
class FirebaseErrorHandler {
  /// Maps Firebase Auth exceptions to localization keys
  static String handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          return 'auth_error_wrong_password';

        case 'user-not-found':
          return 'auth_error_user_not_found';

        case 'email-already-in-use':
          return 'auth_error_email_already_in_use';

        case 'weak-password':
          return 'auth_error_weak_password';

        case 'invalid-email':
          return 'auth_error_invalid_email';

        case 'user-disabled':
          return 'auth_error_user_disabled';

        case 'too-many-requests':
          return 'auth_error_too_many_requests';

        case 'operation-not-allowed':
          return 'auth_error_operation_not_allowed';

        case 'requires-recent-login':
          return 'auth_error_requires_recent_login';

        case 'invalid-credential':
          return 'auth_error_invalid_credential';

        case 'invalid-verification-code':
          return 'auth_error_invalid_verification_code';

        case 'invalid-verification-id':
          return 'auth_error_invalid_verification_id';

        case 'session-expired':
          return 'auth_error_session_expired';

        case 'network-request-failed':
          return 'auth_error_network';

        case 'internal-error':
          return 'auth_error_internal';

        default:
          return 'auth_error_unknown';
      }
    }

    return _handleGenericError(error);
  }

  /// Maps Firestore exceptions to localization keys
  static String handleFirestoreException(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return 'db_error_unavailable';

        case 'permission-denied':
          return 'db_error_permission_denied';

        case 'not-found':
          return 'db_error_not_found';

        case 'already-exists':
          return 'db_error_already_exists';

        case 'failed-precondition':
          return 'db_error_failed_precondition';

        case 'aborted':
          return 'db_error_aborted';

        case 'out-of-range':
          return 'db_error_out_of_range';

        case 'unimplemented':
          return 'db_error_unimplemented';

        case 'deadline-exceeded':
          return 'db_error_deadline_exceeded';

        case 'resource-exhausted':
          return 'db_error_resource_exhausted';

        case 'cancelled':
          return 'db_error_cancelled';

        case 'data-loss':
          return 'db_error_data_loss';

        case 'unauthenticated':
          return 'db_error_unauthenticated';

        case 'internal':
          return 'db_error_internal';

        default:
          return 'db_error_unknown';
      }
    }

    return _handleGenericError(error);
  }

  /// Handles generic exceptions and network errors (localization keys)
  static String _handleGenericError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return 'auth_error_network';
    }

    // Firestore unavailable errors
    if (errorString.contains('unavailable') ||
        errorString.contains('backend didn\'t respond') ||
        errorString.contains('could not reach')) {
      return 'db_error_unavailable';
    }

    // Format errors
    if (errorString.contains('format') || errorString.contains('invalid')) {
      return 'common_error_invalid_data';
    }

    // Permission errors
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'common_error_permission_denied';
    }

    // Default fallback
    return 'common_error_generic';
  }

  /// Determines if an error is retryable (network issues, timeouts, etc.)
  static bool isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.code == 'deadline-exceeded' ||
          error.code == 'network-request-failed' ||
          error.code == 'internal';
    }
    
    if (error is FirebaseAuthException) {
      return error.code == 'network-request-failed' ||
          error.code == 'internal-error';
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('unavailable') ||
        errorString.contains('connection');
  }

  /// Determines if the error indicates offline mode
  static bool isOfflineError(dynamic error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' ||
          error.message?.toLowerCase().contains('offline') == true;
    }
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('offline') ||
        errorString.contains('could not reach') ||
        errorString.contains('backend didn\'t respond');
  }

  /// Gets a user-friendly error message for any Firebase-related error
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthException(error);
    }
    
    if (error is FirebaseException) {
      return handleFirestoreException(error);
    }
    
    return _handleGenericError(error);
  }

  /// Logs error for debugging (can be extended to use a logging service)
  static void logError(dynamic error, {String? context, StackTrace? stackTrace}) {
    final errorMessage = getErrorMessage(error);
    print('❌ Firebase Error [${context ?? 'Unknown'}]: $errorMessage');
    print('   Original error: $error');
    if (stackTrace != null) {
      print('   Stack trace: $stackTrace');
    }
  }
}

