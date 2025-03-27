import 'package:flutter/material.dart';

class DynamicPage extends StatelessWidget {
  const DynamicPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of Muslim students
    final List<Map<String, String>> students = [
      {'name': 'Shoaib Liaqat', 'enrollment': 'BGNU101'},
      {'name': 'Fatima Sheikh', 'enrollment': 'BGNU102'},
      {'name': 'Mohammed Ali', 'enrollment': 'BGNU103'},
      {'name': 'Aisha Siddiqui', 'enrollment': 'BGNU104'},
      {'name': 'Omar Farooq', 'enrollment': 'BGNU105'},
      {'name': 'Hafsa Noor', 'enrollment': 'BGNU106'},
      {'name': 'Abdullah', 'enrollment': 'BGNU107'},
      {'name': 'Riasat ali', 'enrollment': 'BGNU108'},
      {'name': 'Waqar ahmad', 'enrollment': 'BGNU109'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muslim Students - BGNU'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: students.length, // Using the list length
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.person, size: 40, color: Colors.green),
              title: Text(
                students[index]['name']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Enrollment: ${students[index]['enrollment']}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
