import 'package:flutter/foundation.dart';
import '../core/auth_sdk.dart';
import '../core/auth_state.dart';
import '../core/auth_config.dart';


class AuthProvider extends ChangeNotifier {
  final FirebaseAuthSDK _sdk;
  AuthStatus _status;

  AuthProvider({AuthConfig? config})
      : _sdk = FirebaseAuthSDK(config: config ?? const AuthConfig()),
        _status = const AuthStatus(state: AuthState.unauthenticated) {
    _initialize();
  }

  void _initialize() {
    _sdk.authStatusStream.listen((status) {
      _status = status;
      notifyListeners();
    });
  }

  AuthStatus get status => _status;
  AuthState get state => _status.state;
  AuthUser? get user => _status.user;
  Exception? get error => _status.error;
  bool get isAuthenticated => _status.isAuthenticated;
  bool get isLoading => _status.isLoading;

  Future<void> signInWithEmail(String email, String password) =>
      _sdk.signInWithEmail(email, password);

  Future<void> signUpWithEmail(String email, String password) =>
      _sdk.signUpWithEmail(email, password);

  Future<void> signInWithGoogle() => _sdk.signInWithGoogle();

  Future<void> signInWithApple() => _sdk.signInWithApple();

  Future<void> signOut() => _sdk.signOut();

  AuthUser? getCurrentUser() => _sdk.getCurrentUser();

  @override
  void dispose() {
    _sdk.dispose();
    super.dispose();
  }
}