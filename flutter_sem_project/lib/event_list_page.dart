// lib/pages/event_list_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  Stream<QuerySnapshot> getEventsStream() {
    return FirebaseFirestore.instance.collection('events').orderBy('created_at', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Registered Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream: getEventsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Organizer')),
                DataColumn(label: Text('Event Name')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Venue')),
                DataColumn(label: Text('Description')),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['organizer'] ?? '')),
                  DataCell(Text(data['event_name'] ?? '')),
                  DataCell(Text(data['date'] ?? '')),
                  DataCell(Text(data['venue'] ?? '')),
                  DataCell(Text(data['description'] ?? '')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
