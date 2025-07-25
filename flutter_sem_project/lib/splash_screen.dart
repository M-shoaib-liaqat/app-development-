import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore import
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // ✅ Start animations after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });

    // ✅ Firebase Firestore connection test
    _testFirebaseConnection();

    // ✅ After 3 seconds, go to dashboard
    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final isVerified = prefs.getBool('is_verified') ?? false;

      if (mounted) {
        if (isVerified) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    });
  }

  Future<void> _testFirebaseConnection() async {
    try {
      await FirebaseFirestore.instance.collection('connection_test').add({
        'message': 'Hello from SplashScreen!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Firebase Firestore connection successful.");
    } catch (e) {
      debugPrint("❌ Firebase connection failed: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo.png', width: 200, height: 200),
                      const SizedBox(height: 25),
                      Text(
                        'University Events',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF93C5FD).withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Your Hub for Campus Life',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: const Color(0xFF93C5FD),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
