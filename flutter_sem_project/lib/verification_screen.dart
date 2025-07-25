import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool _isVerified = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    await user?.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _isVerified = refreshedUser?.emailVerified ?? false;
      _isChecking = false;
    });

    if (_isVerified) {
      // If verified, update Firestore and sign out, then go to login
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'verified': true});
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isChecking
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isVerified
                  ? 'Email Verified! Redirecting...'
                  : 'Please verify your email.',
              style: GoogleFonts.poppins(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkVerification,
              child: Text('Refresh', style: GoogleFonts.poppins()),
            ),
            if (!_isVerified)
              TextButton(
                onPressed: () async {
                  await user?.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verification email resent.', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Resend Verification Email', style: GoogleFonts.poppins()),
              ),
          ],
        ),
      ),
    );
  }
}
