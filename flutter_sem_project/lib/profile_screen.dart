import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<AppUser?> _fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins()),
      ),
      body: FutureBuilder<AppUser?>(
        future: _fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(user.email, style: GoogleFonts.poppins(fontSize: 16)),
                        Text('Role: ${user.role.name}', style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
