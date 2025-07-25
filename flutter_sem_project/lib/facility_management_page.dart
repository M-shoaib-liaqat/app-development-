import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacilityManagementPage extends StatefulWidget {
  FacilityManagementPage(); // Removed eventId
  @override
  _FacilityManagementPageState createState() => _FacilityManagementPageState();
}

class _FacilityManagementPageState extends State<FacilityManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _facilityController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFacility() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final facilityData = {
        'facility': _facilityController.text.trim(),
        'provider': _providerController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        // Removed eventId
      };
      await FirebaseFirestore.instance.collection('facilities').add(facilityData);
      // Send email to provider after adding facility
      try {
        final response = await http.post(
          Uri.parse('https://shoaib1010.pythonanywhere.com/send-facility-email/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to': _emailController.text.trim(),
            'facility': _facilityController.text.trim(),
            'provider': _providerController.text.trim(),
          }),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Facility added and email sent!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Facility added, but failed to send email.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facility added, but error sending email: $e')),
        );
      }
      _facilityController.clear();
      _providerController.clear();
      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Facilities Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _facilityController,
                decoration: InputDecoration(labelText: 'Facility Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter facility name' : null,
              ),
              TextFormField(
                controller: _providerController,
                decoration: InputDecoration(labelText: 'Provider Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter provider name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Provider Email'),
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFacility,
                child: _isSubmitting ? CircularProgressIndicator() : Text('Add Facility'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
