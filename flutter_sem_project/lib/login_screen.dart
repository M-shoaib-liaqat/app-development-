import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth imports with alias
import 'auth_service.dart' as auth;
import 'user_model.dart' as auth;

import 'biometric_auth_helper.dart';
import 'pin_auth_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final ok = await auth.AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_verified', true);

        final auth.UserRole role = await auth.AuthService.getCurrentUserRole();
        _navigateToDashboard(role);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email/Password incorrect or not verified'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await auth.AuthService.signInWithGoogle();
      if (userCredential != null) {
        final email = userCredential.user?.email ?? '';
        if (!email.endsWith('@bgnu.edu')) {
          await auth.AuthService.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only university (@bgnu.edu) emails are allowed'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_verified', true);
        final auth.UserRole role = await auth.AuthService.getCurrentUserRole();
        _navigateToDashboard(role);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard(auth.UserRole role) {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _loginWithBiometrics() async {
    setState(() => _isLoading = true);
    final canCheck = await BiometricAuthHelper.canCheckBiometrics();
    if (!canCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No biometric hardware found'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
      return;
    }
    final authenticated = await BiometricAuthHelper.authenticate();
    if (authenticated) {
      _navigateToDashboard(await auth.AuthService.getCurrentUserRole());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loginWithPin() async {
    setState(() => _isLoading = true);
    final pin = await _showPinDialog();
    if (pin == null) {
      setState(() => _isLoading = false);
      return;
    }
    final savedPin = await PinAuthHelper.getPin();
    if (savedPin != null && savedPin == pin) {
      _navigateToDashboard(await auth.AuthService.getCurrentUserRole());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<String?> _showPinDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        final pinController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'PIN'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, pinController.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  obscure: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Login', style: GoogleFonts.poppins(fontSize: 18)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithBiometrics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Login with Fingerprint', style: GoogleFonts.poppins(fontSize: 18)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Login with PIN', style: GoogleFonts.poppins(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                  child: Text(
                    'Don’t have an account? Sign Up',
                    style: GoogleFonts.poppins(color: const Color(0xFF1E3A8A)),
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
