import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Dashboard', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Event',
            onPressed: () => Navigator.pushNamed(context, '/event_form'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faculty_events')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!.docs;
          if (events.isEmpty) {
            return const Center(child: Text('No faculty events found.\nCreate one using the + button above.', textAlign: TextAlign.center));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('My Events', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...events.map((doc) {
                final event = doc.data() as Map<String, dynamic>;
                final feedback = event['feedback'] as String?;
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(event['event_name'] ?? '', style: GoogleFonts.poppins()),
                        subtitle: Text('Date: ${event['date'] ?? ''}', style: GoogleFonts.poppins(fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.feedback),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final controller = TextEditingController();
                                    return AlertDialog(
                                      title: const Text('Leave Feedback'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(hintText: 'Enter feedback'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await doc.reference.update({
                                              'feedback': controller.text,
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Submit'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // TODO: Implement event editing (open event form with data)
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Event'),
                                    content: const Text('Are you sure you want to delete this event?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await doc.reference.delete();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      if (feedback != null && feedback.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.feedback, size: 18, color: Colors.blueGrey),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Feedback: $feedback', style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.blueGrey))),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              Text('Feedback & Ratings', style: GoogleFonts.poppins(fontSize: 18)),
              // TODO: List feedback from backend
            ],
          );
        },
      ),
    );
  }
}
