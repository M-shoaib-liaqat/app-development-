import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer Dashboard', style: GoogleFonts.poppins()),
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
              Text('My Events', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...events.map((doc) {
                final event = doc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(event['event_name'] ?? '', style: GoogleFonts.poppins()),
                    subtitle: Text('Date: ${event['date'] ?? ''}', style: GoogleFonts.poppins(fontSize: 12)),
                    trailing: Icon((event['approved'] == true) ? Icons.check_circle : Icons.hourglass_empty, color: (event['approved'] == true) ? Colors.green : Colors.orange),
                    onTap: () {
                      // Show event details
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(event['event_name'] ?? ''),
                            content: Text('Venue: ${event['venue'] ?? ''}\nDescription: ${event['description'] ?? ''}\nDate: ${event['date'] ?? ''}\nTime: ${event['time'] ?? ''}'),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
