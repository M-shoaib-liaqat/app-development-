import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_db_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'display_data_page.dart'; // Make sure this import points to your actual file
// import 'location_picker.dart'; // Removed unused import
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';
import 'event_request_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  Future<void> sendOneSignalNotification(String eventName) async {
    // ...existing code...
    const String oneSignalAppId = '467a5557-c80c-47d4-b142-9f003547db13';
    const String restApiKey = 'os_v2_app_iz5fkv6ibrd5jmkct4adkr63cp4hn7hl55vexn4qrzwlgdbnca6cbowodgva4a6adrcmml5kxxmv5id2gcsihucnogwh2mgokgeueza'; // Replace with your REST API Key
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');
    final payload = {
      'app_id': oneSignalAppId,
      'included_segments': ['All'],
      'headings': {'en': 'New Event Created!'},
      'contents': {'en': 'A new event "$eventName" has been added.'},
    };
    final headers = {
      'Authorization': 'Basic $restApiKey',
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.post(url, headers: headers, body: json.encode(payload));
      if (response.statusCode == 200) {
        print('OneSignal notification sent!');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? _selectedTime;
  // Location fields removed
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _organizerController.dispose();
    _eventNameController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  // Location picker removed

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      String? createdByRole;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          createdByRole = AppUser.roleFromString(doc['role'] ?? 'student').name;
        }
      }
      final Map<String, dynamic> eventData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'organizer': _organizerController.text,
        'event_name': _eventNameController.text,
        'venue': _venueController.text,
        'description': _descriptionController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'created_at': DateTime.now().toIso8601String(),
        'createdByRole': createdByRole ?? 'student',
        'approved': false,
        'status': 'pending',
        'synced': 0,
      };

      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        dynamic docRef;
        if (connectivityResult == ConnectivityResult.none) {
          // Offline: Save to local DB only
          await LocalDbHelper.insertEvent(eventData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved locally. Will sync when online.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Online: Save to Firestore and local DB
          final collection = (createdByRole == 'faculty') ? 'faculty_events' : 'events';
          docRef = await FirebaseFirestore.instance.collection(collection).add(eventData);
          await LocalDbHelper.insertEvent(eventData);
          await EventRequestService.createEventRequest(
            eventId: docRef.id,
            collection: collection,
            eventName: _eventNameController.text,
            createdBy: user?.uid ?? '',
            type: (createdByRole == 'faculty') ? 'faculty' : 'general',
          );
          // Send OneSignal notification to all users
          await sendOneSignalNotification(_eventNameController.text);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Event Registered Successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        // Clear form fields
        _organizerController.clear();
        _eventNameController.clear();
        _venueController.clear();
        _descriptionController.clear();
        _dateController.clear();
        setState(() {
          _selectedDate = null;
        });

        // Delay to show snackbar before navigating
        await Future.delayed(const Duration(seconds: 2));

        // Navigate to DisplayDataPage to add facilities
        if (mounted) {
          String eventId;
          if (connectivityResult == ConnectivityResult.none || docRef == null) {
            eventId = eventData['id'];
          } else {
            eventId = docRef.id;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayDataPage(documentId: eventId),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error saving event: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to save event: $e'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Organizer'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter organizer' : null,
              ),
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter event name' : null,
              ),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter venue' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter description' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: _pickDate,
                validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time'),
                readOnly: true,
                onTap: _pickTime,
                validator: (value) => value == null || value.isEmpty ? 'Please select a time' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}