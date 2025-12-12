/// HNG Firebase Auth SDK
///
/// A comprehensive Firebase authentication SDK for Flutter applications
/// that provides both pre-built UI components and headless authentication methods.
///
/// ## Quick Start
///
/// ### Using the Pre-built UI Widget
/// ```dart
/// import 'package:hng_firebase_auth/hng_firebase_auth.dart';
///
/// AuthWidget(
///   onSuccess: () => print('Logged in!'),
///   onError: (error) => print('Error: ${error.message}'),
/// )
/// ```
///
/// ### Using the Headless Provider
/// ```dart
/// import 'package:hng_firebase_auth/hng_firebase_auth.dart';
///
/// final provider = AuthProvider();
///
/// try {
///   await provider.signInWithEmail('email@example.com', 'password');
/// } on InvalidCredentialsException {
///   print('Wrong email or password');
/// } on UserNotFoundException {
///   print('Account does not exist');
/// } on AuthException catch (e) {
///   print('Auth error: ${e.message}');
/// }
/// ```
library;

// Core exports
export 'src/core/auth_config.dart';
export 'src/core/auth_state.dart' show AuthState, AuthStatus, AuthUser;

// Provider exports
export 'src/providers/auth_provider.dart';

// UI exports
export 'src/ui/auth_widget.dart';

// Exception exports - All exception types for error handling
export 'src/exceptions/auth_exceptions.dart'
    show
        AuthException,
        InvalidCredentialsException,
        UserNotFoundException,
        EmailAlreadyInUseException,
        WeakPasswordException,
        TokenExpiredException,
        NetworkException,
        SignInCancelledException,
        InvalidEmailException,
        TooManyRequestsException,
        AccountDisabledException,
        OperationNotAllowedException,
        AppleSignInException,
        GoogleSignInException;
