import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  /// Initialize SQLite Database
  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'users.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)',
        );
      },
    );
  }

  /// Store User Data in SQLite
  Future<void> _storeUserData() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email and Password are required", isError: true);
      return;
    }

    try {
      if (_database == null) {
        await _initializeDatabase();
      }

      await _database!.insert(
        'users',
        {'email': email, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _showMessage("User data stored successfully!");

      // Navigate to Profile Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );

      // Clear input fields
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      _showMessage("Error storing data: $e", isError: true);
    }
  }

  /// Show a Snackbar Message
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
      appBar: AppBar(title: const Text('User Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _storeUserData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
