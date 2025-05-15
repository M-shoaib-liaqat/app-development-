import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Text Saver',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TextSaverPage(),
    );
  }
}

class TextSaverPage extends StatefulWidget {
  @override
  _TextSaverPageState createState() => _TextSaverPageState();
}

class _TextSaverPageState extends State<TextSaverPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _savedTexts = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'text_saver.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE texts(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)',
        );
      },
    );
    _fetchTexts();
  }

  Future<void> _fetchTexts() async {
    final List<Map<String, dynamic>> maps =
    await _database!.query('texts', orderBy: 'id DESC');
    setState(() {
      _savedTexts = maps.map((e) => e['content'] as String).toList();
    });
  }

  Future<void> _saveText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _database!.insert('texts', {'content': text});
    _controller.clear();
    _fetchTexts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite Text Saver')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter some text'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveText,
              child: Text('Save to SQLite'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _savedTexts.isEmpty
                  ? Center(child: Text('No records yet.'))
                  : ListView.builder(
                itemCount: _savedTexts.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.note),
                      title: Text(_savedTexts[index]),
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
