import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart' as auth;
import 'user_model.dart' as userModel;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  userModel.UserRole _selectedRole = userModel.UserRole.student;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        bool obscure = false,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter your $hint';
        if (hint == 'Email' && !value.contains('@')) return 'Enter a valid email';
        if (hint == 'Password' && value.length < 6) return 'Password too short';
        return null;
      },
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<userModel.UserRole>(
      value: _selectedRole,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: userModel.UserRole.values.map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(role.name[0].toUpperCase() + role.name.substring(1)),
        );
      }).toList(),
      onChanged: (role) {
        if (role != null) setState(() => _selectedRole = role);
      },
    );
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await auth.AuthService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent. Please check your inbox.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamed(context, '/verify', arguments: {
        'email': _emailController.text.trim(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 120),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(_nameController, 'Name'),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email', keyboard: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Password', obscure: true),
                    const SizedBox(height: 16),
                    _buildRoleDropdown(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Sign Up', style: GoogleFonts.poppins(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Already have an account? Login',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
