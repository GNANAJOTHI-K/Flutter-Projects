import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  bool _loading = false;
  String? _error;

  Future<void> _submitEmailPassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();

    setState(() {
      _loading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final errorMessage = await authProvider.signInWithEmail(_email, _password);

    if (errorMessage != null) {
      setState(() {
        _loading = false;
        _error = errorMessage;
      });
      return;
    }

    setState(() {
      _loading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final errorMessage = await authProvider.signInWithGoogle();

    if (errorMessage != null) {
      setState(() {
        _loading = false;
        _error = errorMessage;
      });
      return;
    }

    setState(() {
      _loading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pokémon hero image at top center
                Center(
                  child: Image.network(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png', // Pikachu
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Welcome Back!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your account',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.blue,  // Changed from purple to blue
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade700),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!.trim(),
                      ),

                      const SizedBox(height: 24),

                      // Password Field
                      TextFormField(
                        obscureText: true,
                        cursorColor: Colors.blue,  // Changed from purple to blue
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade700),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onSaved: (value) => _password = value!.trim(),
                      ),

                      const SizedBox(height: 16),

                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submitEmailPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.blue.shade200,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.blue.shade200,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Google Sign-In Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Text(
                            '🅖',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          label: Text(
                            'Sign in with Google',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading ? null : _signInWithGoogle,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Signup Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(color: Colors.blue.shade800),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignupScreen()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
