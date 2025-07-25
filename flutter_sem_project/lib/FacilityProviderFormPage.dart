import 'package:flutter/material.dart';

class FacilityProviderFormPage extends StatefulWidget {
  @override
  _FacilityProviderFormPageState createState() => _FacilityProviderFormPageState();
}

class _FacilityProviderFormPageState extends State<FacilityProviderFormPage> {
  final TextEditingController _facilityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _sendRequest() {
    final facility = _facilityController.text.trim();
    final email = _emailController.text.trim();

    if (facility.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    // TODO: Call your backend API to send email request here
    // For example:
    // await sendFacilityRequest(facility, email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent to $email')),
    );

    _facilityController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Facility Provider')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _facilityController,
              decoration: InputDecoration(
                labelText: 'Facility Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Provider Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _sendRequest,
              child: Text('Send Facility Request'),
            ),
          ],
        ),
      ),
    );
  }
}
