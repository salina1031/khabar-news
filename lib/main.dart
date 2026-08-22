import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BirtaKhabarApp());
}

class BirtaKhabarApp extends StatelessWidget {
  const BirtaKhabarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: MaterialApp(
        title: 'BirtaKhabar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepOrange,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 1,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

// AuthGate checks whether Firebase already has a signed-in user (e.g. the
// app was reopened) and, if so, loads their profile before deciding whether
// to show the login screen or the main app.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // A session already exists - try to load the matching profile.
      await context.read<AuthProvider>().loadCurrentSession();
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const MainNavigation() : const LoginScreen();
  }
}
