enum AuthState {
  authenticated,
  unauthenticated,
  tokenexpired,
  loading,
}

class AuthStatus {
  final AuthState state;
  final AuthUser? user;
  final Exception? error;

  const AuthStatus({
    required this.state,
    this.user,
    this.error,
  });

  bool get isAuthenticated => state == AuthState.authenticated;
  bool get isLoading => state == AuthState.loading;
  bool get hasError => error != null;

  AuthStatus copyWith({
    AuthState? state,
    AuthUser? user,
    Exception? error,
  }) {
    return AuthStatus(
      state: state ?? this.state,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String provider;
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
  });
  factory AuthUser.fromFirebaseUser(dynamic firebaseUser, String provider) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      provider: provider,
    );
  }
}
