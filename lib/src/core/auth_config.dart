class AuthConfig {
  final Map<String, bool> providers;

  final bool autoRefreshToken;

  final int tokenRefreshInterval;

  const AuthConfig({
    this.providers = const {
      'email': true,
      'google': true,
      'apple': false,
    },
    this.autoRefreshToken = true,
    this.tokenRefreshInterval = 3000000,
  });

  bool isProviderEnabled(String provider) {
    return providers[provider] ?? false;
  }
}
