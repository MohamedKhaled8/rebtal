import 'package:firebase_auth/firebase_auth.dart';

/// Centralized error handler for Firebase Authentication and Firestore errors
class FirebaseErrorHandler {
  /// Maps Firebase Auth exceptions to user-friendly messages
  static String handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          return 'The password you entered is incorrect. Please try again.';
        
        case 'user-not-found':
          return 'No account found with this email address. Please check your email or sign up.';
        
        case 'email-already-in-use':
          return 'An account with this email already exists. Please sign in or use a different email.';
        
        case 'weak-password':
          return 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
        
        case 'invalid-email':
          return 'The email address is invalid. Please enter a valid email address.';
        
        case 'user-disabled':
          return 'This account has been disabled. Please contact support for assistance.';
        
        case 'too-many-requests':
          return 'Too many failed login attempts. Please wait a few minutes before trying again.';
        
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        
        case 'requires-recent-login':
          return 'This operation requires recent authentication. Please sign in again.';
        
        case 'invalid-credential':
          return 'The email or password is incorrect. Please check your credentials and try again.';
        
        case 'invalid-verification-code':
          return 'The verification code is invalid. Please request a new code.';
        
        case 'invalid-verification-id':
          return 'The verification ID is invalid. Please try again.';
        
        case 'session-expired':
          return 'Your session has expired. Please sign in again.';
        
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        
        case 'internal-error':
          return 'An internal error occurred. Please try again later.';
        
        default:
          return 'Authentication failed: ${error.message ?? error.code}. Please try again.';
      }
    }
    
    return _handleGenericError(error);
  }

  /// Maps Firestore exceptions to user-friendly messages
  static String handleFirestoreException(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return 'The service is currently unavailable. This is likely a temporary issue. Please check your internet connection and try again.';
        
        case 'permission-denied':
          return 'You don\'t have permission to perform this action. Please contact support.';
        
        case 'not-found':
          return 'The requested data was not found.';
        
        case 'already-exists':
          return 'This record already exists.';
        
        case 'failed-precondition':
          return 'The operation was rejected because the system is not in a required state.';
        
        case 'aborted':
          return 'The operation was aborted. Please try again.';
        
        case 'out-of-range':
          return 'The operation was attempted past the valid range.';
        
        case 'unimplemented':
          return 'This operation is not implemented.';
        
        case 'deadline-exceeded':
          return 'The operation timed out. Please check your internet connection and try again.';
        
        case 'resource-exhausted':
          return 'The system has exhausted resources. Please try again later.';
        
        case 'cancelled':
          return 'The operation was cancelled.';
        
        case 'data-loss':
          return 'Unrecoverable data loss or corruption occurred.';
        
        case 'unauthenticated':
          return 'The request does not have valid authentication credentials.';
        
        case 'internal':
          return 'An internal error occurred. Please try again later.';
        
        default:
          return 'Database error: ${error.message ?? error.code}. Please try again.';
      }
    }
    
    return _handleGenericError(error);
  }

  /// Handles generic exceptions and network errors
  static String _handleGenericError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Network-related errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    
    // Firestore unavailable errors
    if (errorString.contains('unavailable') || 
        errorString.contains('backend didn\'t respond') ||
        errorString.contains('could not reach')) {
      return 'Unable to connect to the server. The service may be temporarily unavailable. Please check your internet connection and try again.';
    }
    
    // Format errors
    if (errorString.contains('format') || errorString.contains('invalid')) {
      return 'Invalid data format. Please check your input and try again.';
    }
    
    // Permission errors
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Permission denied. Please contact support if you believe this is an error.';
    }
    
    // Default fallback
    return 'An unexpected error occurred: ${error.toString()}. Please try again or contact support if the problem persists.';
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

