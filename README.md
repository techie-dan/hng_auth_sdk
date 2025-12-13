# 🔐 HNG Firebase Auth SDK

A comprehensive, production-ready Firebase Authentication SDK for Flutter with pre-built UI and headless mode support.

[![Flutter](https://img.shields.io/badge/Flutter-3.6.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Compatible-orange.svg)](https://firebase.google.com/)

## ✨ Features

### 🔑 Authentication Providers
- ✅ **Email/Password** - Traditional authentication
- ✅ **Google Sign-In** - One-tap Google authentication
- ✅ **Apple Sign-In** - Native Apple authentication (iOS)
- 🔧 **Expandable** - Easy to add other Firebase providers

### 📊 State Management
Automatically tracks and exposes three core authentication states:
- `Authenticated` - User is signed in
- `Unauthenticated` - User is signed out
- `TokenExpired` - Session expired, re-authentication needed
- `Loading` - Authentication operation in progress

### ⚙️ Configuration System
Flexible configuration object to enable/disable specific login methods:
```dart
AuthConfig(
  providers: {
    'email': true,
    'google': true,
    'apple': true,
  },
  autoRefreshToken: true,
  tokenRefreshInterval: 3000000,
)
```

### 🛡️ Error Handling & Logging
Unified error handling layer with custom exception types:
- `InvalidCredentialsException` - Wrong password/email combination
- `UserNotFoundException` - Account does not exist
- `EmailAlreadyInUseException` - Sign-up conflict
- `WeakPasswordException` - Password doesn't meet requirements
- `TokenExpiredException` - Session expired
- `NetworkException` - Network connectivity issues

All Firebase errors are automatically mapped to these custom types.

### 🎨 UI Flexibility

#### Default Mode (Plug-and-Play)
Pre-built widget that renders a complete login form based on configuration:
```dart
AuthWidget(
  onSuccess: () => print('Login successful!'),
  onError: (error) => print('Error: ${error.message}'),
)
```

#### Headless Mode (Custom UI)
Expose methods and streams for complete UI control:
```dart
final authProvider = Provider.of<AuthProvider>(context);

// Methods
await authProvider.signInWithEmail(email, password);
await authProvider.signInWithGoogle();
await authProvider.signInWithApple();
await authProvider.signOut();

// State access
final user = authProvider.user;
final isAuthenticated = authProvider.isAuthenticated;
final state = authProvider.state;

// Stream access (via SDK)
final authStream = firebaseAuthSDK.authStatusStream;
```

## 📦 Installation

### 1. Add Dependencies

Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.32.0
  firebase_auth: ^4.20.0
  google_sign_in: ^6.1.5
  sign_in_with_apple: ^5.0.0
  provider: ^6.1.1
```

Run:
```bash
flutter pub get
```

### 2. Configure Firebase

#### Generate Firebase Options
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Initialize Firebase in `main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 3. Platform-Specific Setup

#### iOS Configuration
1. Add `GoogleService-Info.plist` to `ios/Runner/`
2. Configure URL schemes in `Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

3. For Sign In with Apple, ensure `Runner.entitlements` includes:
```xml
<key>com.apple.developer.applesignin</key>
<array>
  <string>Default</string>
</array>
```

#### Android Configuration
1. Add `google-services.json` to `android/app/`
2. Update `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

3. Update `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Secrets Configuration
This project uses a secrets file to keep sensitive keys out of source control.

1. Create a new file `lib/firebase_secrets.dart`
2. Add your Firebase keys (found in your `GoogleService-Info.plist` or Firebase Console):

```dart
class FirebaseSecrets {
  static const String iosApiKey = 'YOUR_IOS_API_KEY';
  static const String iosAppId = 'YOUR_IOS_APP_ID';
  static const String iosMessagingSenderId = 'YOUR_IOS_SENDER_ID';
  static const String iosProjectId = 'YOUR_PROJECT_ID';
  static const String iosStorageBucket = 'YOUR_STORAGE_BUCKET';
  static const String iosBundleId = 'YOUR_BUNDLE_ID';
}
```
*Note: This file is ignored by git to protect your credentials.*

## 🚀 Quick Start

### Using Default Mode (Pre-built UI)

```dart
import 'package:provider/provider.dart';
import 'package:hng_firebase_auth/src/providers/auth_provider.dart';
import 'package:hng_firebase_auth/src/ui/auth_widget.dart';
import 'package:hng_firebase_auth/src/core/auth_config.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(
        config: AuthConfig(
          providers: {
            'email': true,
            'google': true,
            'apple': true,
          },
        ),
      ),
      child: MaterialApp(
        home: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AuthWidget(
          onSuccess: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.message)),
            );
          },
        ),
      ),
    );
  }
}
```

### Using Headless Mode (Custom UI)

```dart
import 'package:provider/provider.dart';
import 'package:hng_firebase_auth/src/providers/auth_provider.dart';

class CustomLoginScreen extends StatefulWidget {
  @override
  _CustomLoginScreenState createState() => _CustomLoginScreenState();
}

class _CustomLoginScreenState extends State<CustomLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Custom Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Display current user
            if (authProvider.isAuthenticated)
              Text('Logged in as: ${authProvider.user?.email}'),
            
            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            
            // Password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            
            SizedBox(height: 16),
            
            // Sign in button
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : () async {
                try {
                  await authProvider.signInWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: authProvider.isLoading
                  ? CircularProgressIndicator()
                  : Text('Sign In'),
            ),
            
            // Google Sign In
            ElevatedButton.icon(
              onPressed: () => authProvider.signInWithGoogle(),
              icon: Icon(Icons.g_mobiledata),
              label: Text('Sign in with Google'),
            ),
            
            // Apple Sign In (iOS only)
            if (Platform.isIOS)
              ElevatedButton.icon(
                onPressed: () => authProvider.signInWithApple(),
                icon: Icon(Icons.apple),
                label: Text('Sign in with Apple'),
              ),
            
            // Sign out button
            if (authProvider.isAuthenticated)
              ElevatedButton(
                onPressed: () => authProvider.signOut(),
                child: Text('Sign Out'),
              ),
          ],
        ),
      ),
    );
  }
}
```

## 📖 API Reference

### AuthProvider

The main provider class for managing authentication state.

#### Properties
```dart
AuthStatus status          // Current authentication status
AuthState state            // Current state (authenticated/unauthenticated/etc)
AuthUser? user             // Current user object (null if not authenticated)
Exception? error           // Last error that occurred
bool isAuthenticated       // True if user is signed in
bool isLoading             // True if operation in progress
```

#### Methods
```dart
Future<void> signInWithEmail(String email, String password)
Future<void> signUpWithEmail(String email, String password)
Future<void> signInWithGoogle()
Future<void> signInWithApple()
Future<void> signOut()
AuthUser? getCurrentUser()
```

### AuthConfig

Configuration object for the SDK.

```dart
AuthConfig({
  Map<String, bool> providers = const {
    'email': true,
    'google': true,
    'apple': true,
  },
  bool autoRefreshToken = true,
  int tokenRefreshInterval = 3000000, // milliseconds
})
```

### AuthState Enum

```dart
enum AuthState {
  authenticated,      // User is signed in
  unauthenticated,   // User is signed out
  tokenexpired,      // Session expired
  loading,           // Operation in progress
}
```

### AuthUser

User information object.

```dart
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String provider;  // 'email', 'google', or 'apple'
}
```

## 🚨 Error Code Documentation

All authentication errors are mapped to custom exception types:

| Error Code | Exception Class | Message | Common Cause |
|------------|----------------|---------|--------------|
| `INVALID_CREDENTIALS` | `InvalidCredentialsException` | Wrong email or password | Incorrect login credentials |
| `USER_NOT_FOUND` | `UserNotFoundException` | Account does not exist | Email not registered |
| `EMAIL_IN_USE` | `EmailAlreadyInUseException` | Email already registered | Sign-up with existing email |
| `WEAK_PASSWORD` | `WeakPasswordException` | Password must be 6+ characters | Password too short |
| `TOKEN_EXPIRED` | `TokenExpiredException` | Session expired, please login again | Auth token expired |
| `NETWORK_ERROR` | `NetworkException` | Check your internet connection | No network connectivity |
| `UNKNOWN_ERROR` | `AuthException` | Custom error message | Other Firebase errors |

### Error Handling Example

```dart
try {
  await authProvider.signInWithEmail(email, password);
} on InvalidCredentialsException catch (e) {
  print('Wrong password: ${e.message}');
} on UserNotFoundException catch (e) {
  print('User not found: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on AuthException catch (e) {
  print('Auth error (${e.code}): ${e.message}');
}
```

## 📁 Project Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── auth_config.dart      # Configuration class
│   │   ├── auth_sdk.dart         # Core SDK implementation
│   │   └── auth_state.dart       # State & user models
│   ├── exceptions/
│   │   └── auth_exceptions.dart  # Custom exception types
│   ├── providers/
│   │   └── auth_provider.dart    # ChangeNotifier provider
│   └── ui/
│       └── auth_widget.dart      # Pre-built UI component
├── firebase_options.dart         # Firebase configuration
└── main.dart                     # Example app
```

## ⚠️ Important Notes

### Sign In with Apple - iOS Simulator Limitation
**Sign In with Apple DOES NOT work on iOS Simulators!** This is an Apple limitation.

- ❌ **Simulator**: Will fail (expected behavior)
- ✅ **Real Device**: Works correctly

To test Sign In with Apple, you must use a physical iOS device.

See `APPLE_SIGNIN_NOTES.md` for detailed information.

### Firebase Console Setup
Ensure you've enabled authentication providers in Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication → Sign-in method**
4. Enable **Email/Password**, **Google**, and **Apple** providers

## 🧪 Testing

Run the example app:
```bash
flutter run
```

The example demonstrates both Default (pre-built UI) and Headless modes in a tabbed interface.

## 📝 Example App

The example app (`lib/main.dart`) demonstrates:
- ✅ Default mode with `AuthWidget`
- ✅ Headless mode with custom UI
- ✅ Stream-based state management
- ✅ Error handling
- ✅ All three authentication providers

## 🤝 Contributing

This SDK is designed to be expandable. To add new Firebase providers:

1. Add the provider package to `pubspec.yaml`
2. Add sign-in method to `FirebaseAuthSDK` class
3. Add provider method to `AuthProvider`
4. Update `AuthConfig` to include the new provider
5. Update UI components as needed

## 📄 License

This project is part of the HNG internship task.

## 🔗 Resources

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [Sign In with Apple Plugin](https://pub.dev/packages/sign_in_with_apple)

## ✅ Implementation Checklist

- [x] Email/Password authentication
- [x] Google Sign-In integration
- [x] Apple Sign-In integration
- [x] State management (Authenticated, Unauthenticated, TokenExpired)
- [x] Configuration system for providers
- [x] Custom error handling with all required exception types
- [x] Default mode (plug-and-play UI)
- [x] Headless mode (exposed methods and streams)
- [x] Example app with both modes
- [x] Complete README with API reference
- [x] Error code documentation
- [x] Platform-specific setup instructions
- [x] Firebase integration
- [x] Automatic token refresh
- [x] Stream-based state updates

## HOSTING LINK
- https://pub.dev/packages/hng_firebase_auth

---

**Made with ❤️ for HNG Internship**
