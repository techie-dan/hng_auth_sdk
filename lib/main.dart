import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'src/providers/auth_provider.dart';
import 'src/ui/auth_widget.dart';
import 'src/core/auth_config.dart';
import 'src/core/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(
        config: const AuthConfig(
          providers: {
            'email': true,
            'google': true,
            'apple': true,
          },
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth SDK Demo (Default + Headless)',
        theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
        home: const MainDemoScreen(),
      ),
    );
  }
}

class MainDemoScreen extends StatefulWidget {
  const MainDemoScreen({super.key});

  @override
  State<MainDemoScreen> createState() => _MainDemoScreenState();
}

class _MainDemoScreenState extends State<MainDemoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth SDK — Default + Headless'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pre-built UI'),
            Tab(text: 'Headless UI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PrebuiltUiExample(),
          HeadlessUiExample(),
        ],
      ),
    );
  }
}

/// Default Mode: Plug-and-play pre-built UI (uses `AuthWidget`)
class PrebuiltUiExample extends StatelessWidget {
  const PrebuiltUiExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AuthWidget(
              onSuccess: () {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login successful (pre-built)!')),
                  );
                }
              },
              onError: (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pre-built UI error: ${error.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Headless Mode: shows how to call provider methods and expose a stream
class HeadlessUiExample extends StatefulWidget {
  const HeadlessUiExample({super.key});

  @override
  State<HeadlessUiExample> createState() => _HeadlessUiExampleState();
}

class _HeadlessUiExampleState extends State<HeadlessUiExample> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late final Stream<AuthUser?> _userStream;
  Stream<AuthUser?> createAuthUserStream(AuthProvider provider) {
    // Creates a Stream that emits the provider.user whenever the provider changes.
    late final StreamController<AuthUser?> controller;

    void _listener() {
      if (!controller.isClosed) {
        controller.add(provider.user);
      }
    }

    controller = StreamController<AuthUser?>.broadcast(
      onListen: () {
        controller.add(provider.user);
        provider.addListener(_listener);
      },
      onCancel: () {
        try {
          provider.removeListener(_listener);
        } catch (_) {}
        controller.close();
      },
    );

    // For safety, return a stream that emits current value and subsequent updates.
    // Note: provider listener will be attached when the stream is listened to.
    return controller.stream;
  }

  // We keep a no-op placeholder; actual listener is created inside `createAuthUserStream`.
  void _listener() {}

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuthProvider>(context, listen: false);
    // Create the stream using provider; stream attaches listeners when observed.
    _userStream = createAuthUserStream(provider);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    final provider = context.read<AuthProvider>();
    try {
      await provider.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sign-in error: $e')),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final provider = context.read<AuthProvider>();
    try {
      await provider.signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in error: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final provider = context.read<AuthProvider>();
    try {
      await provider.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-out error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // StreamBuilder demonstrates how a developer can listen to auth state updates
          StreamBuilder<AuthUser?>(
            stream: _userStream,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Waiting for auth state...'),
                );
              }

              if (user == null) {
                return const ListTile(
                  leading: Icon(Icons.person_off),
                  title: Text('Not signed in'),
                  subtitle: Text('Use the form below to sign in (headless).'),
                );
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? Text(user.email?.substring(0, 1).toUpperCase() ?? 'U') : null,
                ),
                title: Text(user.displayName ?? user.email ?? 'User'),
                subtitle: Text('ID: ${user.uid}\nProvider: ${user.provider}'),
                isThreeLine: true,
                trailing: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  onPressed: _signOut,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Custom sign-in form (headless) — uses provider methods directly
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _signInWithEmail,
                          child: const Text('Sign in (email)'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const Icon(Icons.login),
                          label: const Text('Sign in (Google)'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Demonstration: read provider state directly (fallback to notify UI)
                    Consumer<AuthProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const LinearProgressIndicator();
                        }
                        if (provider.isAuthenticated) {
                          return Text('Provider reports: authenticated', style: TextStyle(color: Colors.green[700]));
                        }
                        return const Text('Provider reports: unauthenticated');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // A short note to developers
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Headless mode: call the provider methods (e.g., signInWithEmail, signInWithGoogle, signOut) and listen to auth updates via ChangeNotifier or a stream as shown.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}