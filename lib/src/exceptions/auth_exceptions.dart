/// Base exception class for all authentication-related errors.
///
/// The [message] provides a user-friendly error description, while
/// the [code] is a machine-readable error identifier for programmatic handling.
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, this.code);

  @override
  String toString() => 'AuthException($code): $message';

  /// Returns a user-friendly message suitable for displaying in the UI.
  String get userMessage => message;
}

/// Thrown when the email or password is incorrect during sign-in.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? message])
      : super(message ?? 'The email or password is incorrect',
            'INVALID_CREDENTIALS');
}

/// Thrown when no user account exists for the given email.
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? message])
      : super(message ?? 'No account found with this email', 'USER_NOT_FOUND');
}

/// Thrown when attempting to create an account with an email that's already registered.
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException([String? message])
      : super(message ?? 'An account already exists with this email',
            'EMAIL_IN_USE');
}

/// Thrown when the provided password doesn't meet security requirements.
class WeakPasswordException extends AuthException {
  const WeakPasswordException([String? message])
      : super(message ?? 'Password must be at least 6 characters',
            'WEAK_PASSWORD');
}

/// Thrown when the user's authentication token has expired.
class TokenExpiredException extends AuthException {
  const TokenExpiredException([String? message])
      : super(message ?? 'Your session has expired. Please sign in again',
            'TOKEN_EXPIRED');
}

/// Thrown when there's a network connectivity issue.
class NetworkException extends AuthException {
  const NetworkException([String? message])
      : super(
            message ??
                'Unable to connect. Please check your internet connection',
            'NETWORK_ERROR');
}

/// Thrown when the user cancels a sign-in operation (e.g., closing the Google sign-in popup).
class SignInCancelledException extends AuthException {
  const SignInCancelledException([String? message])
      : super(message ?? 'Sign in was cancelled', 'SIGN_IN_CANCELLED');
}

/// Thrown when the provided email address format is invalid.
class InvalidEmailException extends AuthException {
  const InvalidEmailException([String? message])
      : super(message ?? 'Please enter a valid email address', 'INVALID_EMAIL');
}

/// Thrown when there are too many failed authentication attempts.
class TooManyRequestsException extends AuthException {
  const TooManyRequestsException([String? message])
      : super(message ?? 'Too many attempts. Please try again later',
            'TOO_MANY_REQUESTS');
}

/// Thrown when the user's account has been disabled by an administrator.
class AccountDisabledException extends AuthException {
  const AccountDisabledException([String? message])
      : super(message ?? 'This account has been disabled', 'ACCOUNT_DISABLED');
}

/// Thrown when a sign-in method is not enabled in the Firebase console.
class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException([String? message])
      : super(message ?? 'This sign-in method is not enabled',
            'OPERATION_NOT_ALLOWED');
}

/// Thrown when there's an issue with the Apple Sign-In configuration or process.
class AppleSignInException extends AuthException {
  const AppleSignInException([String? message])
      : super(message ?? 'Apple Sign-In failed. Please try again',
            'APPLE_SIGN_IN_ERROR');
}

/// Thrown when there's an issue with the Google Sign-In configuration or process.
class GoogleSignInException extends AuthException {
  const GoogleSignInException([String? message])
      : super(message ?? 'Google Sign-In failed. Please try again',
            'GOOGLE_SIGN_IN_ERROR');
}

/// Maps Firebase error codes to typed [AuthException] instances.
///
/// This function handles all known Firebase Auth error codes and returns
/// appropriate typed exceptions for each case.
AuthException mapFirebaseError(dynamic error) {
  // Handle null errors
  if (error == null) {
    return const AuthException('An unknown error occurred', 'UNKNOWN_ERROR');
  }

  // Try to get the error code
  String code;
  String? message;

  try {
    code = error.code?.toString() ?? '';
    message = error.message?.toString();
  } catch (_) {
    // If we can't access the error properties, treat it as a generic error
    return AuthException(
      error.toString(),
      'UNKNOWN_ERROR',
    );
  }

  switch (code) {
    // Credential errors
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return const InvalidCredentialsException();

    // User errors
    case 'user-not-found':
      return const UserNotFoundException();
    case 'user-disabled':
      return const AccountDisabledException();

    // Email errors
    case 'email-already-in-use':
      return const EmailAlreadyInUseException();
    case 'invalid-email':
      return const InvalidEmailException();

    // Password errors
    case 'weak-password':
      return const WeakPasswordException();

    // Token errors
    case 'id-token-expired':
    case 'user-token-expired':
    case 'session-expired':
      return const TokenExpiredException();

    // Network errors
    case 'network-request-failed':
    case 'timeout':
      return const NetworkException();

    // Rate limiting
    case 'too-many-requests':
      return const TooManyRequestsException();

    // Sign-in method errors
    case 'operation-not-allowed':
      return const OperationNotAllowedException();

    // Social sign-in cancellation
    case 'popup-closed-by-user':
    case 'cancelled':
    case 'sign_in_canceled':
      return const SignInCancelledException();

    // Default case
    default:
      return AuthException(
        message ?? 'An unexpected error occurred',
        code.isNotEmpty
            ? code.toUpperCase().replaceAll('-', '_')
            : 'UNKNOWN_ERROR',
      );
  }
}
