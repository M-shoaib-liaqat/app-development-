import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({super.key});

  @override
  _AddSubjectPageState createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  String? _selectedSubject;
  final TextEditingController _marksController = TextEditingController();
  final TextEditingController _creditHoursController = TextEditingController();
  Database? _database;

  final List<String> _subjects = ['Math', 'Physics', 'Chemistry', 'English', 'Biology'];

  List<Map<String, dynamic>> _subjectRecords = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'subjects.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE subjects(id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT, marks INTEGER, grade TEXT, gradePoint INTEGER, creditHours INTEGER)",
        );
      },
    );

    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    if (_database == null) return;
    final List<Map<String, dynamic>> records = await _database!.query('subjects');
    setState(() {
      _subjectRecords = records;
    });
  }

  Future<void> _submitData() async {
    final marks = int.tryParse(_marksController.text.trim());
    final creditHours = int.tryParse(_creditHoursController.text.trim());

    if (_selectedSubject == null || marks == null || creditHours == null) {
      _showMessage("Please fill all fields", isError: true);
      return;
    }
    if (marks < 0 || marks > 100) {
      _showMessage("Marks should be between 0 and 100", isError: true);
      return;
    }

    // Calculate grade and grade point
    String grade;
    int gradePoint;
    if (marks > 90) {
      grade = "A";
      gradePoint = 4;
    } else if (marks >= 70) {
      grade = "B";
      gradePoint = 3;
    } else if (marks >= 60) {
      grade = "C";
      gradePoint = 2;
    } else if (marks >= 49) {
      grade = "D";
      gradePoint = 1;
    } else {
      grade = "F";
      gradePoint = 0;
    }

    // Store data in SQLite
    await _database!.insert(
      'subjects',
      {
        "subject": _selectedSubject!,
        "marks": marks,
        "grade": grade,
        "gradePoint": gradePoint,
        "creditHours": creditHours
      },
    );

    _showMessage("Subject Added Successfully!");
    _loadSubjects(); // Refresh the list

    // Clear fields after submission
    _marksController.clear();
    _creditHoursController.clear();
    setState(() {
      _selectedSubject = null;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subject')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(labelText: 'Select Subject'),
              items: _subjects.map((subject) {
                return DropdownMenuItem(value: subject, child: Text(subject));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Marks (0-100)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _creditHoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credit Hours'),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                child: const Text('Submit'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Added Subjects:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _subjectRecords.length,
                itemBuilder: (context, index) {
                  final item = _subjectRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(item['subject']),
                      subtitle: Text("Marks: ${item['marks']}, Grade: ${item['grade']}, Grade Point: ${item['gradePoint']}"),
                      trailing: Text("${item['creditHours']} Credit Hours"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
