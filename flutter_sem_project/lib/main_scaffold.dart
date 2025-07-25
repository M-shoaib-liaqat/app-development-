import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';

typedef BodyBuilder = Widget Function(BuildContext context);

class MainScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavTap;
  final BodyBuilder bodyBuilder;

  const MainScaffold({
    super.key,
    required this.selectedIndex,
    required this.onNavTap,
    required this.bodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home,
      Icons.request_page, // Requests
      Icons.calendar_today,
      Icons.notifications,
    ];

    const labels = [
      'Home',
      'Requests',
      'Calendar',
      'Alerts',
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF60A5FA)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          'University Events',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(child: bodyBuilder(context)),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (i) {
            final active = selectedIndex == i;
            return GestureDetector(
              onTap: () => onNavTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF1E3A8A) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icons[i],
                      size: active ? 30 : 24,
                      color: active ? Colors.white : const Color(0xFF60A5FA),
                    ),
                  ),
                  if (active)
                    Text(
                      labels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
