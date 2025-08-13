import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/pokemon_provider.dart';
import 'providers/favorites_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const PokeApp());
}

class PokeApp extends StatelessWidget {
  const PokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(AuthProvider()),
          update: (_, authProvider, previous) =>
              FavoritesProvider(authProvider),
        ),
        ChangeNotifierProvider<PokemonProvider>(
          create: (_) => PokemonProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pokémon App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade900,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                border: const OutlineInputBorder(),
                prefixIconColor: Colors.blue,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) =>
                  auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
