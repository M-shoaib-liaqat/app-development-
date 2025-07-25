import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'event_request_service.dart';

Future<void> sendMergedFacilityApprovalEmails(
  BuildContext context,
  List<String> recipients,
  List<String> facilities,
  String eventName,
) async {
  print('📤 Sending grouped email...');
  print('📨 Recipients: ${jsonEncode(recipients)}');
  print('🏢 Facilities: ${jsonEncode(facilities)}');
  print('🎉 Event: $eventName');

  if (recipients.isEmpty) {
    print('⚠️ No recipients provided.');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email recipients found.')),
      );
    }
    return;
  }

  try {
    final response = await http
        .post(
          Uri.parse('https://flask-smtp-email-api.onrender.com/send-facility-email/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'recipients': recipients,
            'facilities': facilities,
            'event': eventName,
          }),
        )
        .timeout(const Duration(seconds: 25));

    print('📬 Server response: ${response.statusCode} ${response.body}');

    final result = jsonDecode(response.body);
    if (response.statusCode == 200 && result['status'] == 'success') {
      print('✅ Grouped email successfully sent.');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grouped email sent for $eventName')),
        );
      }
    } else {
      print('❌ Failed to send grouped email: ${response.body}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send grouped email.')),
        );
      }
    }
  } on TimeoutException {
    print('⏱️ Timeout occurred.');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email request timed out')),
      );
    }
  } catch (e) {
    print('🔥 Exception while sending email: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending email: $e')),
      );
    }
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void addTestEventRequest(BuildContext context) async {
    print('🧪 Adding test event request...');
    await FirebaseFirestore.instance.collection('event_requests').add({
      'eventId': 'vkoDmds7nuL7I5my6M3C',
      'collection': 'events',
      'facilities': ['catering', 'audio'], // use real facility names here
      'created_at': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test event request added!')),
      );
    }
  }

  Future<void> approveEvent(
    String requestId,
    String collection,
    BuildContext context,
  ) async {
    print('✅ Approving event request: $requestId');
    try {
      final requestSnap = await FirebaseFirestore.instance
          .collection('event_requests')
          .doc(requestId)
          .get();
      final requestData = requestSnap.data();
      if (requestData == null || !requestData.containsKey('eventId')) {
        throw Exception('Event ID not found for request.');
      }

      final eventId = requestData['eventId'];

      await FirebaseFirestore.instance.collection(collection).doc(eventId).update({
        'approved': true,
        'status': 'allowed',
      });

      await EventRequestService.updateRequestStatus(requestId, 'approved');

      final eventDoc =
          await FirebaseFirestore.instance.collection(collection).doc(eventId).get();
      final eventName = eventDoc.data()?['event_name'] ?? 'Unknown Event';

      final facilities = List<String>.from(eventDoc.data()?['facilities'] ?? []);
      final Set<String> allRecipients = {};

      for (final facilityName in facilities) {
        final queryName = facilityName.toLowerCase();
        print('🔍 Querying for facility: $queryName');
        final providerQuery = await FirebaseFirestore.instance
            .collection('facilities')
            .where('facility', isEqualTo: queryName)
            .get();
        print('🔍 Found ${providerQuery.docs.length} providers for $queryName');

        final recipients = providerQuery.docs
            .map((doc) => doc['email'] as String?)
            .where((email) => email != null && email.contains('@'))
            .cast<String>();

        print('🔍 Recipients for $queryName: $recipients');
        allRecipients.addAll(recipients);
      }

      print('📧 Recipients collected: $allRecipients');

      if (allRecipients.isNotEmpty) {
        await sendMergedFacilityApprovalEmails(
          context,
          allRecipients.toList(),
          facilities,
          eventName,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Event approved and provider emails sent.')),
        );
      }
    } catch (e) {
      print('❌ Error approving event: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving event: $e')),
        );
      }
    }
  }

  Future<void> rejectEvent(
    String requestId,
    String collection,
    BuildContext context,
  ) async {
    print('❌ Rejecting event request: $requestId');
    try {
      final requestSnap = await FirebaseFirestore.instance
          .collection('event_requests')
          .doc(requestId)
          .get();

      final requestData = requestSnap.data();
      if (requestData == null || !requestData.containsKey('eventId')) {
        throw Exception('Event ID not found for request.');
      }

      final eventId = requestData['eventId'];

      await FirebaseFirestore.instance.collection(collection).doc(eventId).update({
        'approved': false,
        'status': 'rejected',
      });

      await EventRequestService.updateRequestStatus(requestId, 'rejected');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event rejected.')),
        );
      }
    } catch (e) {
      print('❌ Error rejecting event: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard', style: GoogleFonts.poppins())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Facility Management button removed
          const SizedBox(height: 16),
          Text(
            'Pending Event Approvals',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('event_requests')
                .where('status', isEqualTo: 'pending')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final requests = snapshot.data!.docs
                  .where((doc) => doc['created_at'] != null)
                  .toList();

              if (requests.isEmpty) return const Text('No pending event requests.');

              return Column(
                children: requests.map((reqDoc) {
                  final req = reqDoc.data() as Map<String, dynamic>;
                  final requestId = reqDoc.id;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection(req['collection'])
                        .doc(req['eventId'])
                        .get(),
                    builder: (context, eventSnap) {
                      if (!eventSnap.hasData || !eventSnap.data!.exists) {
                        return const SizedBox.shrink();
                      }

                      final event = eventSnap.data!.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(event['event_name'] ?? '', style: GoogleFonts.poppins()),
                          subtitle: Text(
                            'Date: ${event['date'] ?? ''}\nStatus: ${event['status'] ?? 'pending'}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Approve Event'),
                                      content: const Text('Are you sure you want to approve this event?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Approve'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await approveEvent(requestId, req['collection'], context);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Reject Event'),
                                      content: const Text('Are you sure you want to reject this event?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await rejectEvent(requestId, req['collection'], context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Users', style: GoogleFonts.poppins(fontSize: 18)),
          const Text('User management coming soon...'),
          const SizedBox(height: 32),
          Text('Analytics', style: GoogleFonts.poppins(fontSize: 18)),
          const Text('Analytics charts coming soon...'),
        ],
      ),
    );
  }
}
