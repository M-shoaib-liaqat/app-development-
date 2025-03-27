import 'dart:convert';
import 'package:flutter/material.dart';

class JsonDataScreen extends StatefulWidget {
  const JsonDataScreen({super.key});

  @override
  _JsonDataScreenState createState() => _JsonDataScreenState();
}

class _JsonDataScreenState extends State<JsonDataScreen> {
  final String jsonData = '''
  [
    {"name": "Ahmed Ali", "age": 28, "city": "Cairo"},
    {"name": "Fatima Zahra", "age": 25, "city": "Istanbul"},
    {"name": "Omar Farooq", "age": 35, "city": "Dubai"},
    {"name": "Aisha Siddiqua", "age": 30, "city": "Kuala Lumpur"}
  ]
  ''';

  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  void loadJsonData() {
    try {
      data = json.decode(jsonData);
      setState(() {});
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON Data')),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(child: Text('${item['age']}')),
              title: Text(item['name']),
              subtitle: Text('City: ${item['city']}'),
            ),
          );
        },
      ),
    );
  }
}
