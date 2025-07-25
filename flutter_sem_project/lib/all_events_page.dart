import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_db_helper.dart';
import 'display_data_page.dart'; // So we can tap to view event details
import 'user_model.dart';
import 'auth_service.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    AuthService.getCurrentUserRole().then((role) {
      setState(() {
        _userRole = role;
      });
    });
  }

  Future<void> _deleteEvent(String docId) async {
    if (_userRole != UserRole.admin) return;
    await FirebaseFirestore.instance.collection('events').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted.')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Events')),
      body: _userRole == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('approved', isEqualTo: true)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data!.docs;
                if (events.isEmpty) {
                  return const Center(child: Text('No events found.'));
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final data = events[index].data() as Map<String, dynamic>;
                    final docId = events[index].id;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(data['event_name'] ?? 'Unnamed Event'),
                        subtitle: Text('Organized by: ${data['organizer'] ?? 'Unknown'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_userRole == UserRole.admin)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Event',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Event'),
                                      content: const Text('Are you sure you want to delete this event?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _deleteEvent(docId);
                                  }
                                },
                              ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DisplayDataPage(documentId: docId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
