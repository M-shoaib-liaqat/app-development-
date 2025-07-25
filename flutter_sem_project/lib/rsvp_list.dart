import 'package:flutter/material.dart';

class RSVPListPage extends StatelessWidget {
  const RSVPListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch and display RSVP'd events for the user
    return Scaffold(
      appBar: AppBar(title: const Text('My RSVPs')),
      body: const Center(
        child: Text('List of events you have RSVP’d to will appear here.'),
      ),
    );
  }
}
