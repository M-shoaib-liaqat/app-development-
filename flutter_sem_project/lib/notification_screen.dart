import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_scaffold.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  int selectedIndex = 3;

  void _onNavTap(int idx) {
    setState(() => selectedIndex = idx);
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/requests');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/calendar');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: selectedIndex,
      onNavTap: _onNavTap,
      bodyBuilder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('approved', isEqualTo: true)
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            final filtered = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final eventDateStr = data['date'] as String?;
              if (eventDateStr == null) return false;

              final eventDate = DateTime.tryParse(eventDateStr);
              if (eventDate == null) return false;

              final diff = eventDate.difference(today).inDays;

              // Only include upcoming events: today to 7 days later
              return diff >= 0 && diff <= 7;
            }).toList();

            Widget buildGroup(String label, List<QueryDocumentSnapshot> items) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  ...items.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final eventName = data['event_name'] ?? 'Event';
                    final createdAtRaw = data['created_at'];
                    DateTime createdAt;
                    if (createdAtRaw is Timestamp) {
                      createdAt = createdAtRaw.toDate();
                    } else if (createdAtRaw is String) {
                      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
                    } else {
                      createdAt = DateTime.now();
                    }
                    final eventDateStr = data['date'] as String?;
                    final eventDate =
                        DateTime.tryParse(eventDateStr ?? '');

                    final isNew = createdAt.year == today.year &&
                        createdAt.month == today.month &&
                        createdAt.day == today.day;

                    int daysLeft = eventDate != null
                        ? eventDate.difference(today).inDays
                        : -1;

                    Color? badgeColor;
                    String? badgeText;

                    if (daysLeft <= 2) {
                      badgeColor = Colors.red;
                      badgeText = 'Soon';
                    } else if (isNew) {
                      badgeColor = Colors.blue;
                      badgeText = 'New';
                    } else if (daysLeft <= 7) {
                      badgeColor = Colors.grey;
                      badgeText = 'Upcoming';
                    }

                    return Stack(
                      children: [
                        _NotificationTile(
                          message: eventName,
                          read: false,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(eventName,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Date: ${data['date'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins()),
                                      Text(
                                          'Description: ${data['description'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins()),
                                      Text('Type: ${data['type'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins()),
                                      Text('Venue: ${data['venue'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins()),
                                      Text(
                                          'Organizer: ${data['organizer'] ?? 'N/A'}',
                                          style: GoogleFonts.poppins()),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        if (badgeColor != null)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(badgeText ?? '',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 10)),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        if (filtered.isNotEmpty)
                          buildGroup('Upcoming Events', filtered),
                        if (filtered.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text('No upcoming events',
                                  style: GoogleFonts.poppins()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String message;
  final bool read;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.message,
    required this.read,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: read ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: ListTile(
        leading:
            Icon(Icons.notifications, color: Color(0xFF1E3A8A), size: 28),
        title: Text(message,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text('Tap to view details',
            style: GoogleFonts.poppins(
                fontSize: 12, color: Color(0xFF93C5FD))),
        onTap: onTap,
      ),
    );
  }
}
