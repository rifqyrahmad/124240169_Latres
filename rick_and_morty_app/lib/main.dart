import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/character_provider.dart';
import 'providers/favorite_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RickAndMortyApp());
}

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: MaterialApp(
        title: 'Rick & Morty Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1419),
          primaryColor: const Color(0xFF97CE4C),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F1419),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF97CE4C),
            surface: Color(0xFF171E26),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<void> _authCheck;

  @override
  void initState() {
    super.initState();
    _authCheck = context.read<AuthProvider>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF97CE4C)),
            ),
          );
        }

        final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
        return isLoggedIn ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
