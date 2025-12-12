import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../exceptions/auth_exceptions.dart';
import 'auth_state.dart';
import 'auth_config.dart';

class FirebaseAuthSDK {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthConfig config;

  final _statusController = StreamController<AuthStatus>.broadcast();

  AuthStatus _currentStatus = const AuthStatus(
    state: AuthState.unauthenticated,
  );

  Timer? _tokenRefreshTimer;

  FirebaseAuthSDK({this.config = const AuthConfig()}) {
    _initialize();
  }

  Stream<AuthStatus> get authStatusStream => _statusController.stream;

  AuthStatus get currentStatus => _currentStatus;

  void _initialize() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _updateStatus(AuthStatus(
          state: AuthState.authenticated,
          user: AuthUser.fromFirebaseUser(user, 'email'),
        ));

        if (config.autoRefreshToken) {
          _scheduleTokenRefresh();
        }
      } else {
        _updateStatus(const AuthStatus(
          state: AuthState.unauthenticated,
        ));
        _cancelTokenRefresh();
      }
    });
  }

  void _updateStatus(AuthStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void _scheduleTokenRefresh() {
    _cancelTokenRefresh();
    _tokenRefreshTimer = Timer(
      Duration(milliseconds: config.tokenRefreshInterval),
      _refreshToken,
    );
  }

  void _cancelTokenRefresh() {
    _tokenRefreshTimer?.cancel();
  }

  Future<void> _refreshToken() async {
    try {
      await _auth.currentUser?.getIdToken(true);
      _scheduleTokenRefresh();
    } catch (e) {
      _updateStatus(AuthStatus(
        state: AuthState.tokenexpired,
        error: TokenExpiredException(),
      ));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _updateStatus(_currentStatus.copyWith(state: AuthState.loading));

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      final error = e is AuthException ? e : mapFirebaseError(e);
      _updateStatus(AuthStatus(
        state: AuthState.unauthenticated,
        error: error,
      ));
      throw error;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _updateStatus(_currentStatus.copyWith(state: AuthState.loading));

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      final error = e is AuthException ? e : mapFirebaseError(e);
      _updateStatus(AuthStatus(
        state: AuthState.unauthenticated,
        error: error,
      ));
      throw error;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _updateStatus(_currentStatus.copyWith(state: AuthState.loading));

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        const error = SignInCancelledException('Google sign-in was cancelled');
        _updateStatus(AuthStatus(
          state: AuthState.unauthenticated,
          error: error,
        ));
        throw error;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on SignInCancelledException {
      rethrow;
    } catch (e) {
      final error = e is AuthException ? e : mapFirebaseError(e);
      _updateStatus(AuthStatus(
        state: AuthState.unauthenticated,
        error: error,
      ));
      throw error;
    }
  }

  Future<void> signInWithApple() async {
    try {
      _updateStatus(_currentStatus.copyWith(state: AuthState.loading));

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);
    } on SignInCancelledException {
      rethrow;
    } catch (e) {
      // Check for Apple Sign-In cancellation (AuthorizationErrorCode.canceled)
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('authorizationerrorcode.canceled') ||
          errorString.contains('user canceled') ||
          errorString.contains('cancelled')) {
        const error = SignInCancelledException('Apple sign-in was cancelled');
        _updateStatus(AuthStatus(
          state: AuthState.unauthenticated,
          error: error,
        ));
        throw error;
      }

      final error = e is AuthException ? e : mapFirebaseError(e);
      _updateStatus(AuthStatus(
        state: AuthState.unauthenticated,
        error: error,
      ));
      throw error;
    }
  }

  Future<void> signOut() async {
    try {
      _cancelTokenRefresh();
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw mapFirebaseError(e);
    }
  }

  AuthUser? getCurrentUser() {
    final user = _auth.currentUser;
    return user != null ? AuthUser.fromFirebaseUser(user, 'email') : null;
  }

  void dispose() {
    _cancelTokenRefresh();
    _statusController.close();
  }
}
