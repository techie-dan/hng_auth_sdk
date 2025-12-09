
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, this.code);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Wrong email or password', 'INVALID_CREDENTIALS');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('Account does not exist', 'USER_NOT_FOUND');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('Email already registered', 'EMAIL_IN_USE');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Password must be 6+ characters', 'WEAK_PASSWORD');
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException()
      : super('Session expired, please login again', 'TOKEN_EXPIRED');
}

class NetworkException extends AuthException {
  const NetworkException()
      : super('Check your internet connection', 'NETWORK_ERROR');
}

AuthException mapFirebaseError(dynamic error) {
  final code = error.code?.toString() ?? '';

  switch (code) {
    case 'wrong-password':
    case 'invalid-credential':
      return const InvalidCredentialsException();
    case 'user-not-found':
      return const UserNotFoundException();
    case 'email-already-in-use':
      return const EmailAlreadyInUseException();
    case 'weak-password':
      return const WeakPasswordException();
    case 'id-token-expired':
      return const TokenExpiredException();
    case 'network-request-failed':
      return const NetworkException();
    default:
      return AuthException(
        error.message ?? 'Unknown error',
        'UNKNOWN_ERROR',
      );
  }
}