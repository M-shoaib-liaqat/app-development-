import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard', style: GoogleFonts.poppins()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final events = snapshot.data!.docs;
          if (events.isEmpty) return const Center(child: Text('No events found.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Upcoming Events', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...events.map((doc) {
                final event = doc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(event['event_name'] ?? '', style: GoogleFonts.poppins()),
                    subtitle: Text('Date: ${event['date'] ?? ''}', style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // TODO: Register for event (Firestore)
                      },
                      child: const Text('Register'),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              Text('My Registered Events', style: GoogleFonts.poppins(fontSize: 18)),
              // TODO: List registered events from backend
            ],
          );
        },
      ),
    );
  }
}
